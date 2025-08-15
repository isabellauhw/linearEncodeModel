function photometry = photometryAlign(expRef,varargin)
%   photometry = photometryAlign(expRef,...) returns the aligned 
%   and preprocessed fluorescence for all channels and timestamps for photometry data 
%   associated with a single expRef. If interleaved 470/415 frames are
%   detected, then it automatically deinterleaves and subtracts.  
%   Parameters:
%   'numSecToDetrend' - number of seconds for a movmean sliding window to
%   remove slow trends in the data. Default 25 seconds.
%   'alignWithRewards' - true/false indicating whether to align using
%   reward echos, or instead use photometryLive.
%   'plot' - true/false for plotting some useful things

p = inputParser;
addRequired(p,'expRef',@isstr); %expRef
addParameter(p,'numSecToDetrend',25,@isnumeric); %Number of seconds to detrend
addParameter(p,'alignWithRewards',true,@islogical); %whether to align using reward echos & Photometry
addParameter(p,'plot',false,@islogical); %whether to plot
parse(p,expRef,varargin{:})

%% Load and preprocess photometry data
%Check that the photometry file exists
photometryFilepath = dat.expFilePath(expRef, 'photometry','master');
assert( exist(photometryFilepath,'file')==2, sprintf('Photometry file %s does not exist',photometryFilepath));

%Load photometry data
% photometry = readmatrix(photometryFilepath);
photometry = readtable(photometryFilepath,'delimiter',',');

%Remove any entries which have NaNs
badIdx = any(isnan(photometry.channel1_0G),2);
photometry(badIdx,:) = [];

%Get timestamps and reward echo, and fluorescence channels
%if dt is 20+, then time must be in miliseconds, let's put it in seconds
if median(diff(photometry.Timestamp)) > 0.1
    photometry.Timestamp = photometry.Timestamp/1000;
end

%Check if isosbestic correction is needed: if so, do this:
if ismember('exciteWavelength',fieldnames(photometry)) && length(unique(photometry.exciteWavelength)) > 1
    photometry = correctIsosbestic(photometry, p.Results.plot);
end

%Detrend and z-score signal
photometry = removeSlowTrendAndZScore(photometry,p.Results.numSecToDetrend, p.Results.plot);

%% Align photometry timestamps with behavioural data
% Using two different methods:
tlFileExists = exist(dat.expFilePath(expRef,'Timeline','master'),'file');
isCW = isChoiceWorldExpt(expRef);
if p.Results.alignWithRewards %Align using arduino reward echos
    %Get timestamps of reward echo
    RE = diff(diff( photometry.rewardEcho )); RE(1)=0;
    RE = RE/max(RE(5:end));

    [~,p_rewardTimes] = findpeaks( RE,photometry.Timestamp(3:end),...
        'MinPeakHeight', 0.1,...
        'MinPeakDistance', 250/1000);
    
    %Get timestamps of reward from Timeline or Block file
    if tlFileExists && ~isCW
        b_rewardTimes = getEventTimes(expRef,'reward_echo');
    elseif tlFileExists && isCW
        b_rewardTimes = getEventTimes(expRef,'waterValve');
    elseif ~tlFileExists && ~isCW
        bl = dat.loadBlock(expRef);
        b_rewardTimes = bl.outputs.rewardTimes;
    elseif ~tlFileExists && isCW
        bl = dat.loadBlock(expRef);
        b_rewardTimes = bl.rewardDeliveryTimes';
    end

    %check that this matches the number of reward echos. Allow for
    %difference of 1
    assert( abs( length(b_rewardTimes) - length(p_rewardTimes)) <= 1, sprintf('Large unequal reward echos. B=%d P=%d',length(b_rewardTimes),length(p_rewardTimes) ));

    %Correct photometry timestamps to match behavioural timestamps
    [~,b] = makeCorrection(b_rewardTimes, p_rewardTimes, false);
    photometry.Timestamp = applyCorrection(photometry.Timestamp,b);
    
else %Align using timeline photoM live signal
    if tlFileExists && ~isCW
        photoM_live = getEventTimes(expRef, 'photometrylive_echo');
        %HARD-CODED ESTIMATES
        driftRate = 0.0001186875;
        offset = -0.0766517689;
        fprintf('Using hard-coded drift rate = %0.10f and offset = %0.10f\n', driftRate, offset);
        t = photometry.Timestamp;
        t = (t - t(1))*(1-driftRate) + photoM_live(1) - offset;
        photometry.Timestamp = t;
        b_rewardTimes = getEventTimes(expRef,'reward_echo');

    elseif tlFileExists && isCW
        error('TODO: code photometry alignment using photometry live for Choiceworld experiments');
    elseif ~tlFileExists
        error('Cannot align using the photometry live signal because no Timeline file');
    end

end

if p.Results.plot
    %quickly plot channels aligned to reward.
    t_sample = linspace(-1, 1, 200);
    
    chan = fieldnames(photometry); chan = chan(startsWith(chan,'channel'));

    figure;
    ha = tight_subplot(1, length(chan));
    for i = 1:length(chan)

        x = interp1(photometry.Timestamp,photometry.(chan{i}),b_rewardTimes+t_sample);
        imagesc(ha(i),t_sample,[],x);
        title(ha(i),chan{i},'interpreter','none');
        xline(ha(i),0); 
    end
    set(ha,'clim',[-1 1]*2,'box','off');
    set(ha(2:end),'ytick','','ycolor','none');
     colorbar;
     xlabel(ha(1),'Reward onset (sec)'); ylabel(ha(1),'Reward number');
     
end

% Check correlation between 415 and 470
if sum(photometry.channel1_0G) > 0
    channel1_corr = corrcoef(photometry.channel1_0G_415, photometry.channel1_0G);
    channel3_corr = corrcoef(photometry.channel3_4G_415, photometry.channel3_4G);
    fprintf('The isosbestic correlation in channel 1 is %f\n', channel1_corr(2,1))
    fprintf('The isosbestic correlation in channel 3 is %f\n', channel3_corr(2,1))
else
    channel2_corr = corrcoef(photometry.channel2_2G_415, photometry.channel2_2G);
    channel4_corr = corrcoef(photometry.channel4_6G_415, photometry.channel4_6G);
    fprintf('The isosbestic correlation in channel 2 is %f\n', channel2_corr(2,1))
    fprintf('The isosbestic correlation in channel 4 is %f\n', channel4_corr(2,1))
end

end

function photometry = correctIsosbestic(photometry, plotFlag)
%This function deinterleaves 470 & 415nm frames, and corrects the 470 by the 415
idx_470 = photometry.exciteWavelength==470;
idx_415 = photometry.exciteWavelength==415;

chan = fieldnames(photometry); chan = chan(startsWith(chan,'channel'));
F = photometry(:,chan).Variables;

excite470 = F(idx_470,:); %gcamp/dlight/grabda excitation frame
excite470t = photometry.Timestamp(idx_470);
excite415 = F(idx_415,:); %isosbestic excitation frame 
excite415t = photometry.Timestamp(idx_415);

if plotFlag
    figure();
    if sum(excite470(:, 1)) > 0
        disp('photometryAlign is assuming channels 1 and 3 were used.')
        plot(excite470t, excite470(:,1), 'g-', excite415t, excite415(:,1),'k-');
    else
        disp('photometryAlign is assuming channels 2 and 4 were used.')
        plot(excite470t, excite470(:,3), 'g-', excite415t, excite415(:,3),'k-');
    end
    legend('470nm','415nm'); xlabel('frame'); ylabel('F');
end

%interpolate each to have the full timestamps
excite470 = interp1(excite470t, excite470, photometry.Timestamp);
excite415 = interp1(excite415t, excite415, photometry.Timestamp);

%Remove isosbestic signal from main signal
F = excite470-excite415;
photometry(:,chan).Variables = F;
photometry(:, {'channel1_0G_415', 'channel1_1R_415', 'channel2_2G_415', 'channel2_3R_415', 'channel3_4G_415', 'channel3_5R_415', 'channel4_6G_415', 'channel4_7R_415'}) = array2table(excite415);

badIdx = any(isnan(photometry.Variables),2);
photometry(badIdx,:) = [];
photometry.exciteWavelength=[];

end

function photometry = removeSlowTrendAndZScore(photometry,numSecToDetrend, plotFlag)
%This function removes slow trend in the fluorescence signal
Fs = 1/median(diff(photometry.Timestamp));
numSamplesSmoothing = round(numSecToDetrend*Fs);

if plotFlag
    figure;
    if sum(photometry.channel1_0G) > 0
        plot(photometry.Timestamp,photometry.channel1_0G,'k-'); hold on;
    else
        plot(photometry.Timestamp,photometry.channel2_2G,'k-'); hold on;
    end
end

channels = fieldnames(photometry); channels = channels(startsWith(channels,'channel'));
for chan = 1:length(channels)
    photometry.(channels{chan}) = photometry.(channels{chan}) - movmean( photometry.(channels{chan}), numSamplesSmoothing);
end

if plotFlag
    if sum(photometry.channel1_0G) > 0
        plot(photometry.Timestamp,photometry.channel1_0G,'r-');
        title('channel1_0G detrending');
    else
        plot(photometry.Timestamp, photometry.channel2_2G, 'r-');
        title('channel2_2G detrending');
    end
    xlabel('Time'); ylabel('F');
    
    legend('470nm-415nm',sprintf('%d sec detrend', numSecToDetrend));
end

%zscore
photometry(:,channels).Variables = zscore(photometry(:,channels).Variables); 

end