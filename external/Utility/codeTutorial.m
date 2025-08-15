% This script outlines example uses of various functions Peter has written.

%% 1. loadProjectDataset(): Load project session lists 
% This function is useful for loading a standard set of sessions associated
% with different projects. For now we only have 2 projects defined: 
%1. GCaMP_LearningGrating2AFC: ~150 sessions of recording Dopamine cell
%activity in VTA, DMS, NAc during learning of the Grating2AFC task
p = loadProjectDataset('LearningGrating2AFC');

% 2. Neuropix_Grating2AFC: 22 ephys recordings (spike sorted) in PFC using
% Neuropixels probes while mice performed the Grating2AFC task.
p = loadProjectDataset('Neuropix_Grating2AFC');

%% 2. getEventTimes() : Used to get the timings of various events
expRef = '2020-11-23_1_DAP015';

%Get stimulus onset using 'photoDiode'
stimulusOnsetTime = getEventTimes(expRef,'photodiode');

%Get reward onset using 'reward_echo'
rewardOnsetTime = getEventTimes(expRef,'reward_echo');

%Get frame times of camera
cameraFrameTimes = getEventTimes(expRef,'face_camera_strobe');

%Get the time of go cue
b = dat.loadBlock(expRef);
expectedSoundTime = b.events.interactiveOnTimes';
goCueTime = getEventTimes(expRef,'sound_echo','knownSoundTimes',expectedSoundTime);

%% 3. getBehavData() : Used to automatically compile behavioural values and times into a big table
expRef = '2020-11-23_1_DAP015';
dataProfile = 'Grating2AFC'; %a label indicating the type of experiment
% dataProfile = 'Grating2AFC_noTimeline'; %..same as above but not using Timeine timings

behav = getBehavData(expRef,dataProfile);
disp(head(behav));

behav = getBehavData('2021-04-27_1_DAP031','Pavlov1_noTimeline');
disp(head(behav));

behav = getBehavData('2021-04-21_1_AMR008','Value2AFC_noTimeline');
disp(head(behav));

%% 4a. ephysAlign(): Aligning ephys data involving ONE PROBE AND ONE SESSION
% In this situation, the ephys data is aligned to the single behavioural
% session by using the reward echos present in both the behavioural dataset
% and ephys dataset. The spike times of the ephys data are corrected to the
% behavioural data timebase.

%Specify data directory for ephys
ephys_dir = '\\QNAP-AL001.dpag.ox.ac.uk\Data\AMR007\2021-05-15\ephys';
expRef = '2021-05-15_1_AMR007'; %session file associated with ephys data

%get weights to convert from probe to behavioural timebase
probe2block = ephysAlign('OneProbeToOneSession',ephys_dir,expRef);

%Load ephys data and align spike times to behavioural timebase
ephys_data = getEphysData('\\QNAP-AL001.dpag.ox.ac.uk\Data\AMR007\2021-05-15\ephys');
ephys.spike.time = applyCorrection(ephys.st, probe2block);


%load behavioural data
behav = getBehavData(expRef,'Value2AFC');

%% 4b. ephysAlign(): Aligning ephys data involving ONE PROBE AND MULTIPLE SESSIONS
% In this situation, one probe's data is recorded continuously as the
% experimenter runs multiple sessions one another another. This kind of
% alignment is done between the behavioural sessions: the timestamps for
% each behavioural session are each aligned to the timebase of the ephys
% probe.

%Specify data directory for ephys as well as set of expRefs
ephys_dir = '\\QNAP-AL001.dpag.ox.ac.uk\Data\AMR007\2021-05-15\ephys_g0';
expRefs = {'2021-05-15_1_AMR007'};

%Get weights to convert from each session's timebase to the probe timebase
behav2probe = ephysAlign('OneProbeToOneSession',ephys_dir,expRef);

%Load data for each session, then correct all time variables to the probe timebase. Then concatenate
% data across sessions 
behav = [];
for sess = 1:length(expRefs)
    b = getBehavData(expRefs{sess},'Grating2AFC_choiceWorld');
    b.sessionID = ones(size(b.choice))*sess;
    
    fields = fieldnames(b);
    for f = 1:length(fields)
        if contains(fields(f),'Time')
            b.(fields{f}) = applyCorrection( b.(fields{f}), behav2probe{sess} );
        end
    end
    
    behav = [behav; b];
end

%Load ephys data
ephys = getEphysData(ephys_dir);

%% 5a. easy.RasterPSTH(): Easy plotting of Raster and PSTHs for one cluster

% Set of events times to align with
events = {
          %'onset cue', behav.onsetToneTime;
          'stimulus onset', behav.stimulusOnsetTime;
          'stimulus onset', behav.stimulusOnsetTime;
          'choice start time', behav.choiceStartTime;
          'reward onset', behav.rewardTime};

% Set of trial conditions to split the ephys data by
splitBy = {[], [];
          [], [];
          [], [];
          'move type', behav.choice;
          'reward volume', behav.rewardVolume};

% Set of events to sort the raster plots by
sortBy = {[],[];
           'choice start time',behav.choiceStartTime;
           'choice start time',behav.choiceStartTime;
           [],[];
           [],[]};

%Get spike times and kilosort template for one cluster
<<<<<<< Updated upstream
cluID = 742;
ephys.spike.cluID = ephys.clu
spikeTimes = ephys.spike.time(ephys.spike.cluID==cluID);
kilosortTemplate = permute( ephys.cluster.kilosortTemplate(ephys.spike.cluID == cluID,:,:),[3 2 1]); %cluID is 0-indexed. Therefore cluID+1 converts to 1-indexing.
=======
cluID = 100;
spikeTimes = ephys.spike.time(ephys.cids==cluID);
kilosortTemplate = permute( ephys.cluster.kilosortTemplate(ephys.cluster.cluID == cluID,:,:),[3 2 1]); %cluID is 0-indexed. Therefore cluID+1 converts to 1-indexing.
>>>>>>> Stashed changes

%Plot Raster and PSTHs
easy.RasterPSTH(spikeTimes, events,...
        'splitBy',splitBy,...
        'sortBy',sortBy,...
        'window',[-0.5 0.5],...
        'kilosortTemplate',kilosortTemplate);
    
%% 5b. Plot with custom colours
numStimulusConditions = length(unique(behav.contrastRight - behav.contrastLeft));

splitByColours = {[];
    [];
    0.9*RedWhiteBlue(floor(numStimulusConditions/2));
    [];
    []};

easy.RasterPSTH(spikeTimes, events,...
        'splitBy',splitBy,...
        'sortBy',sortBy,...
        'titleText',sprintf('cluster %d',cluID),...
        'window',[-0.5 0.5],...
        'kilosortTemplate',kilosortTemplate,...
        'splitByColours',splitByColours); 
    
%% 5c. easy.RasterPSTH_batch(): Automatic running for all clusters in a dataset and save to directory

easy.RasterPSTH_batch(ephys,[],'D:\test',events,splitBy,splitByColours,sortBy,...
    [-0.5 0.5],1/1000,40/1000,'My favourite session');

%% 6. easy.PSTHbyDepth(): Plotting PSTHs by depth on the probe

easy.PSTHbyDepth(ephys, events,...
    'titleText','2021-12-08_1_AMR017_new_probe');

%% 7. photometryAlign(): Easy load and align photometry data

expRef ='2018-01-23_1_ALK068';
behav = getBehavData(expRef,'Grating2AFC_choiceWorld'); %Load behavioural data
photometry = photometryAlign(expRef); %Load photometry data

%% 8a. easy.EventAlignedAverage(): Easy plotting of continuous variable (e.g. photometry, pupil size)

%Load photometry and behavioural data
expRef ='2018-01-23_1_ALK068';
behav = getBehavData(expRef,'Grating2AFC_choiceWorld'); %Load behavioural data
photometry=photometryAlign(expRef); %Load photometry data

%Define a cell array containing event times which we want to align
%photometry data to
events = {'onset cue', behav.onsetToneTime;
          'stimulus onset', behav.stimulusOnsetTime;
          'choice start time', behav.choiceStartTime;
          'reward onset', behav.rewardTime};
      
%Define a cell array containing splitting conditions
splitBy = {[], [];
          'contrast', behav.contrastRight - behav.contrastLeft;
          'move type', behav.choice;
          [], []};
      
% plot the channel containing photometry data
easy.EventAlignedAverage(photometry.channel2_2G,photometry.Timestamp, events, 'splitBy', splitBy, 'baselineSubtract', [-0.4 -0.2],'label','z-score F');

%% 8b. Plot with custom colours
numStimulusConditions = length(unique(behav.contrastRight - behav.contrastLeft));

splitByColours = {[];
                   0.9*RedWhiteBlue(floor(numStimulusConditions/2));
                   [1 0 0; 0 0 1];
                   []};
               
easy.EventAlignedAverage(photometry.channel2_2G,photometry.Timestamp, events, 'splitBy', splitBy, 'baselineSubtract', [-0.4 -0.2], 'splitByColours', splitByColours,'label','z-score F');

%% 8c. Plot with timewarping

splitBy = {'contrast', behav.contrastRight - behav.contrastLeft;
           'move type', behav.choice};
splitByColours = { 0.9*RedWhiteBlue(floor(numStimulusConditions/2));
                    [1 0.5 0; 0 0.5 1] };
easy.EventAlignedAverageTimeWarped(photometry.channel2_2G,photometry.Timestamp,events, 'splitBy', splitBy, 'splitByColours', splitByColours,'label','z-score F');

%% 9. easy.EventAlignedAverage_acrossSessions(): Easy plotting of continuous variable, grand average across mice
expRefs = {'2018-01-23_1_ALK068';
'2018-01-25_10_ALK068';
'2018-01-26_2_ALK068';
'2018-02-06_1_ALK070';
'2018-02-07_1_ALK070';
'2018-02-09_1_ALK070';
'2018-03-05_1_ALK071';
'2018-03-06_6_ALK071';
'2018-03-08_1_ALK071';
'2018-11-21_1_ALK084';
'2018-11-22_1_ALK084'};
mouseID = cellfun(@(e) e{3},cellfun(@(e) strsplit(e,'_'), expRefs, 'uni', 0),'uni',0);

%For each session, get the continuous variable and define all the
%events/splitBy conditions
events = cell(length(expRefs),1);
splitBy = cell(length(expRefs),1);
x = cell(length(expRefs),1);
t = cell(length(expRefs),1);
for sess = 1:length(expRefs)
    
    %get continuous variable for this session
    b = dat.loadBlock(expRefs{sess});
    x{sess} = b.inputSensorPositions;
    t{sess} = b.inputSensorPositionTimes;
    
    %define event times and splitting conditions
    behav = getBehavData(expRefs{sess},'Grating2AFC_choiceWorld_noTimeline');
    events{sess} = {'onset cue', behav.onsetToneTime;
        'stimulus onset', behav.stimulusOnsetTime;
        'choice start time', behav.choiceStartTime;
        'reward onset', behav.rewardTime};
    
    splitBy{sess} = {[], [];
        'contrast', behav.contrastRight - behav.contrastLeft;
        'move type', behav.choice;
        [], []};
    
end

allContrastValues = cellfun(@(s) s{2,2}, splitBy, 'UniformOutput', false);
allContrastValues = cat(1,allContrastValues{:});
numStimulusConditions = length(unique(allContrastValues));

splitByColours = {[]; 
    0.9*RedWhiteBlue(floor(numStimulusConditions/2)); 
    []; 
    []};

% plot
easy.EventAlignedAverage_acrossSessions(mouseID,x,t,events,...
    'splitBy', splitBy, 'baselineSubtract', [-0.4 -0.2],...
    'label','wheelPos','splitByColours',splitByColours);

%% 10. binaryDecoder(): Decode behavioural variables from neural activity
expRef ='2018-01-23_1_ALK068';
behav = getBehavData(expRef,'Grating2AFC_choiceWorld'); %Load behavioural data
[F,t]=photometryAlign(expRef,false); %Load photometry data

% get dF/F around the time of stimulus onset (1st channel)
t_sample = linspace(-0.5,0.5,500);
behav.DAstim = interp1(t,F(:,3),behav.stimulusOnsetTime + t_sample);

%remove baseline activity
behav.DAstim = behav.DAstim - mean(behav.DAstim(:,t_sample<0),2); 

%Define decoding
decodedLabel = behav.contrastLeft>0; %the label being decoded (whether a stimulus was present on the left)
groupSplit = {behav.choice}; %decoding will be performed within each value of the splitting and then averaged
[auROC,auROC_p] = binaryDecoder(behav.DAstim, decodedLabel, groupSplit);

%Plot decoding result, showing the Decoder performance and also indicating
%which timebins have signficant decoding
figure;
alpha = 0.01;
plot(t_sample, auROC,'b-'); hold on;
sig = auROC_p<(alpha/2) | auROC_p>(1 - (alpha/2));
plot(t_sample(sig), auROC(sig),'b.','markersize',15);
xlabel('Time from stimulus onset');
ylabel('Decoder performance');
yline(0.5);

%% 11a. stan_fitModel(): Fit hierarchical bayesian model to 2AFC data from multiple sessions and subjects
expRefs = {'2018-07-16_2_ALK076','2018-07-17_2_ALK076','2017-08-10_2_ALK052'};
mouseID = [1,1,2];
        
%Load behavioural data and concatenate, adding indicator variable for
%sessionID and subjectID
B = table;
for sess = 1:length(expRefs)
    b = getBehavData(expRefs{sess},'Grating2AFC_choiceWorld');
    
    b.sessionID = ones(size(b.choice))*sess;
    b.subjectID = ones(size(b.choice))*mouseID(sess);
    
    B = [B; b]; %concat
end

%Now compile into a struct
D = struct;
D.sessionID = B.sessionID;
D.subjectID = B.subjectID;
D.contrastLeft = B.contrastLeft;
D.contrastRight = B.contrastRight;
D.choice = double(B.choice=='Right choice'); %0=Left, 1=Right;

%Run fit
fit = stan_fitModel('Hierarchical_Logistic',D,'Z:\stanModelFits\test.mat');

%Plot posterior distribution of global parameters
stan_plotPosterior(fit.posterior);

%% 11b. Plot model fit to grand average
%Calculate average choice proportions in the data
fit.data.cDiff = fit.data.contrastRight - fit.data.contrastLeft;
[counts,~,~,labels] = crosstab(fit.data.cDiff,...
    fit.data.choice,...
    fit.data.sessionID,...
    fit.data.subjectID);
prob = counts./sum(counts,2);%Convert to probability over choices
prob_avgSess = nanmean(prob,3); %average across sessions within each subject
prob_avgSubj = nanmean(prob_avgSess,4); %average across subjects

%Get the posterior predictions
CL = [linspace(1,0,100), zeros(1,100)];
CR = [zeros(1,100), linspace(0,1,100)];
pR = stan_plotFcn_2AFC_CN(fit.posterior.bias,fit.posterior.sens,fit.posterior.sens_n_exp,CL,CR);

pR_interval = quantile(pR,[0.025 0.975]);
pR_mean = mean(pR,1);

%Plot posterior predictions and data
figure; hold on;
fx = fill([CR-CL fliplr(CR-CL)], [pR_interval(1,:) fliplr( pR_interval(2,:) ) ], 'k');
fx.FaceAlpha=0.3;
fx.EdgeAlpha=0;
plot(CR-CL, pR_mean, 'k-','linewidth',2);
plot(unique(fit.data.cDiff),prob_avgSubj(:,2),'k.','markersize',20);
xlabel('CR - CL'); ylabel('p(Right)');

%% 11c. Plot model fit to each subject
figure;
for subj = 1:max(fit.data.subjectID)
    B = fit.posterior.bias + fit.posterior.b_subj(:,1,subj);
    S = fit.posterior.sens + fit.posterior.b_subj(:,2,subj);
    
    pR = stan_plotFcn_2AFC_CN(B,S,fit.posterior.sens_n_exp,CL,CR);
    pR_interval = quantile(pR,[0.025 0.975]);
    pR_mean = mean(pR,1);
    
    subplot(1,max(fit.data.subjectID),subj); hold on;
    fx = fill([CR-CL fliplr(CR-CL)], [pR_interval(1,:) fliplr( pR_interval(2,:) ) ], 'k');
    fx.FaceAlpha=0.3;
    fx.EdgeAlpha=0;
    plot(CR-CL, pR_mean, 'k-','linewidth',2);
    plot(unique(fit.data.cDiff),prob_avgSess(:,2,1,subj),'k.','markersize',20);
    xlabel('CR - CL'); ylabel('p(Right)');
end

%% 11d. Plot model fit to each session
figure;
for sess = 1:max(fit.data.sessionID)
    subj = fit.data.subjID_session(sess);
    B = fit.posterior.bias + fit.posterior.b_subj(:,1,subj) + fit.posterior.b_sess(:,1,sess);
    S = fit.posterior.sens + fit.posterior.b_subj(:,2,subj) + fit.posterior.b_sess(:,2,sess);
    
    pR = stan_plotFcn_2AFC_CN(B,S,fit.posterior.sens_n_exp,CL,CR);
    pR_interval = quantile(pR,[0.025 0.975]);
    pR_mean = mean(pR,1);
    
    subplot(1,max(fit.data.sessionID),sess); hold on;
    fx = fill([CR-CL fliplr(CR-CL)], [pR_interval(1,:) fliplr( pR_interval(2,:) ) ], 'k');
    fx.FaceAlpha=0.3;
    fx.EdgeAlpha=0;
    plot(CR-CL, pR_mean, 'k-','linewidth',2);
    plot(unique(fit.data.cDiff),prob(:,2,sess,subj),'k.','markersize',20);
    xlabel('CR - CL'); ylabel('p(Right)');
    title(expRefs{sess},'interpreter','none');
end

%% 12. Time warp a continuous signal (e.g. firing rate)

%Load continuous signal (e.g. firing rate)
ephys_dir = '\\QNAP-AL001.dpag.ox.ac.uk\Data\ALK052\2017-07-25\ephys';
expRefs = {'2017-07-25_1_ALK052','2017-07-25_2_ALK052'};

%Get weights to convert from each session's timebase to the probe timebase
behav2probe = ephysAlign('MultipleSessionsToOneProbe',ephys_dir,expRefs);

%Load data for each session, then correct all time variables to the probe timebase. Then concatenate
% data across sessions 
behav = [];
for sess = 1:length(expRefs)
    b = getBehavData(expRefs{sess},'Grating2AFC_choiceWorld');
    b.sessionID = ones(size(b.choice))*sess;
    
    fields = fieldnames(b);
    for f = 1:length(fields)
        if contains(fields(f),'Time')
            b.(fields{f}) = applyCorrection( b.(fields{f}), behav2probe{sess} );
        end
    end
    
    behav = [behav; b];
end

%Load ephys data
ephys = loadKSdir(ephys_dir);

%Get spike times for one cluster
cluID = 106;
spikeTimes = ephys.st(ephys.clu==cluID);

%Extract spike counts at time bins across the whole session
psthBinWidth = 2/1000; %2 ms
numBins = round(max(spikeTimes)/psthBinWidth);
[spikeCounts,edges] = histcounts(spikeTimes,numBins);
timestamps = edges(1:end-1);

%smooth spike count vector using a 50ms causal Gaussian window
smoothFilt = myGaussWin(50/1000, 1/psthBinWidth);
smoothFilt(1:round(numel(smoothFilt)/2)-1) = 0;  %Truncate before 0 sec, to generate causal filter
smoothFilt = smoothFilt./sum(smoothFilt);
spikeCounts = conv2(smoothFilt,1,spikeCounts', 'same')';

%convert spike counts to firing rate
firingRate = spikeCounts./psthBinWidth;

%Add outcome time to behavioural data
numTrials = height(behav);
behav.outcomeTime = [behav.rewardTime, behav.punishSoundOnsetTime];
behav.outcomeTime = nanmean(behav.outcomeTime,2); %merge times

% Define the time stamps used for warping. For this we will define 4
% epoches:
%1. Pre-stim period
%2. Stim to choice period
%3. Choice to Outcome period
%4. Post-outcome period
%The number of time-bins within each epoch will be set so that their ratio
%reflects the real ratio of time intervals in the dataset.
warp_sizes = [50,100,20,100]; %number of elements for each epoch: pre-stim, stim-choice, choice-outcome, post-outcome
warp_samples = nan(length(behav.choice), sum(warp_sizes));
for tr = 1:numTrials
    epoch1 = linspace(behav.stimulusOnsetTime(tr)-0.5, behav.stimulusOnsetTime(tr), warp_sizes(1));
    epoch2 = linspace(behav.stimulusOnsetTime(tr), behav.choiceStartTime(tr), warp_sizes(2));
    epoch3 = linspace(behav.choiceStartTime(tr), behav.outcomeTime(tr), warp_sizes(3));
    epoch4 = linspace(behav.outcomeTime(tr), behav.outcomeTime(tr)+1, warp_sizes(4));
    warp_samples(tr,:) = [epoch1, epoch2, epoch3, epoch4];
end

%Exctact the firing rate at each of these timestamps
warped_signal = interp1(timestamps,firingRate,warp_samples);

%Remove pre-stimulus baseline from the activity
warped_signal = warped_signal - mean(warped_signal(:, 1:warp_sizes(1)), 2);

%Plot the warped signal, averaged over trials. Also mark the boundaries
%between the epoches
g = gramm('x',1:sum(warp_sizes), 'y', warped_signal, 'color', behav.choice, 'linestyle', behav.feedback);
g.stat_summary('setylim','true');
g.geom_vline('xintercept',cumsum(warp_sizes)); %mark boundaries between epoches
figure; g.draw();
