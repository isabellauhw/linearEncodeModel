function eventTimes = getEventTimes(expRef, eventName, varargin)
%   eventTimes = getEventTimes(expRef, eventName) gets the time of different
%   events from Timeline for a session defined by expRef. eventName can be
%   of the following types
%   photoDiode, reward_echo, waterValve, sound_echo, photometry_strobe,
%   face_camera_strobe, eye_camera_strobe
%
%   for sound_echo, you must also supply a knownSoundTimes (see below), which is a
%   column vector of expected sound times. The first sound detected after
%   this time will be used. This is useful for detecting different kinds of
%   sound onset: go cue, punish sound, etc.
%
%   eventTimes = getEventTimes(...,Name,Value) specifies options using one or more
%   Name,Value pair arguments.
%
%     'knownSoundTimes'  - column vector of known sound times
%     'plotFlag' - true/false indicating whether to plot the voltage trace
%                   with events marked.

p = inputParser;
addRequired(p,'expRef',@ischar);
addRequired(p,'eventName',@ischar);
addParameter(p,'knownSoundTimes',[],@iscolumn);
addParameter(p,'plotFlag',false,@islogical);
parse(p,expRef,eventName,varargin{:})

%Get voltage data from Timeline
[v,t] = getTimelineVoltageTrace(expRef, eventName);

b = dat.loadBlock(expRef); %load Block file
expectedEventNumber = []; %expected number of events

%Change detection depends on the data type
switch(eventName)  
    case {'reward_echo','waterValve'} %reward times
        TL = 10; %Tolerance (%) within each state level
        PRL = [40 60];  %Reference levels (%) of the fall detection
        [~,eventTimes] = risetime(v, t,'Tolerance',TL,'PercentReferenceLevels',PRL);
        if isfield(b,'events') %signals experiment
            expectedEventNumber = length(b.outputs.rewardValues(b.outputs.rewardValues>0));
        else %choiceworld experiment
            expectedEventNumber = length(b.rewardDeliveryTimes);
        end

    case 'eye_camera_strobe'
        [~,eventTimes] = risetime(v, t);
        vid = VideoReader(dat.expFilePath(expRef, 'eye-video','master'));
        expectedEventNumber = vid.FrameRate*vid.Duration;
        
    case 'face_camera_strobe'
        [~, eventTimes] = risetime(v, t);
        vid = VideoReader(dat.expFilePath(expRef, 'face-video', 'master'));
        
        % Compute expected number of frames (rounded to avoid float mismatch)
        expectedEventNumber = round(vid.FrameRate * vid.Duration);
        actualEventNumber = numel(eventTimes);
        diffEvents = actualEventNumber - expectedEventNumber;
    
        % Define a tolerance (1–2 events is usually okay)
        tolerance = 2;
    
        if abs(diffEvents) > tolerance
            warning('Session %s: %d events found, %d expected (diff = %+d)', ...
                    expRef, actualEventNumber, expectedEventNumber, diffEvents);
        end
    
        % Optionally: Trim or pad eventTimes to match expected number
        if actualEventNumber > expectedEventNumber
            eventTimes = eventTimes(1:expectedEventNumber); % trim extras
        elseif actualEventNumber < expectedEventNumber
            % pad with NaN or repeat last value (less common)
            eventTimes(end+1:expectedEventNumber) = NaN;
        end

        
    case 'eyeCameraStrobe'
        %eye camera strobe used for older choiceworld data
        [~,eventTimes] = risetime(v, t);
%         %remove extreme inter-strobe-intervals > 40msec
%         idx = diff(eventTimes) > 40/1000;
%         eventTimes(idx) = [];
        
        %get video frame timestamps
        vidInfoFile = strrep(dat.expFilePath(expRef, 'eye-video','master'),'.mp4','.mat');
        warning('off');
        vid = load(vidInfoFile,'eyeLog');
        warning('on');
        vidTimestamps = [vid.eyeLog.TriggerData.Time]';
        
        expectedEventNumber = length(vidTimestamps);
        if length(vidTimestamps) < length(eventTimes)
            %probably caused by dropped frames. Identify dropped frames
            %from video timestamps, and then remove the corresponding
            %strobe events
            num_strobes_to_remove = length(eventTimes) - length(vidTimestamps);
            [~,idx] = findpeaks(diff(vidTimestamps),'MinPeakProminence',5/1000,'NPeaks',num_strobes_to_remove,'SortStr','descend');
            idx = sort(idx);
            strobeIdxToRemove = idx + (1:length(idx))'; %convert dropped fframe idx to strobe idx
            eventTimes(strobeIdxToRemove) = [];
            
        elseif length(vidTimestamps) > length(eventTimes)
            warning('Missing strobes, hard to fix this. %d frames, %d strobes, expref %s',length(vidTimestamps),length(eventTimes),expRef);
            expectedEventNumber=[];
        end
        
    case {'photoDiode','photodiode'} %stimulus time
        if isfield(b,'events') %signals experiment
            TL = 9; %Tolerance %
            [~,eventTimes] = risetime(v,t,'Tolerance',TL);
            
        else %choiceworld experiment
            %flatten the first second of voltage as for some reason this
            %look weird in some sessions
            v(t<1)=0;
            
            %get all flip times that are immediately after a known stimulus
            %onset
            photodiode_fliptimes=midcross(v,t,'tolerance',15);
            trial = [b.trial];
            block_stimOnTimes = [trial.stimulusCueStartedTime]';
            num_trials = length([trial.responseMadeTime]);
            eventTimes = nan(num_trials,1);
            for n = 1:num_trials
                eventTimes(n) = photodiode_fliptimes(find(photodiode_fliptimes > block_stimOnTimes(n),1,'first'));
            end
            
        end
        
    case {'sound_echo','audioMonitor'} %sound output
        assert(~isempty(p.Results.knownSoundTimes),'Must provide knownSoundTimes');

        %normalise sound 
        v = v - mean(v); 
        v = abs(v);

        %Filter with 6th-order Butterworth lowpass filter 
        %to filter out the white noise bursts
        fs = 1/mean(diff(t));
        cutoff = 20; %Hz
        [f1,f2] = butter(6,cutoff/(fs/2));
        v_smoothed = filtfilt(f1,f2,v);
        
        %get first sound after each known time
        num_known_times = length(p.Results.knownSoundTimes);
        eventTimes = nan(num_known_times,1);
        knownSoundTimes = p.Results.knownSoundTimes;
        for i = 1:num_known_times
        	t_idx = knownSoundTimes(i) <= t & t <= knownSoundTimes(i)+0.2;
            ti = t(t_idx);
            vi = v_smoothed(t_idx); vi = vi/max(vi);
            eventTimes(i) = ti(find(vi>0.2,1,'first'));
        end

    case 'photometry_strobe' %photometry times
        [v2,t2] = getTimelineVoltageTrace(expRef,'photometrylive_echo'); %also get acqLive TTL
        acqLiveTimes = midcross(v2, t2); 
        
        %clean up voltage signal a bit...
        v = -v + 0.1;
        v(t<acqLiveTimes(1)) = 0;
        v(t>(acqLiveTimes(2)+0.5)) = 0;
        
        %get risetimes
        PRL = [45 55]; %Reference levels (%) of the fall detection
        TL = 40; %Tolerance (%) within each state level
        SL = [0 0.1]; %Expected state levels (Volts) between states.
        [~,eventTimes,~]=risetime( v, t, 'PercentReferenceLevels',PRL,'Tolerance',TL,'StateLevels',SL);

        %remove bad strobes based on too-small interval
        ISI = 1000*diff(eventTimes); %intervals in msec
        [~, LOCS] = findpeaks(-ISI,'MinPeakProminence',2);
        if ~isempty(LOCS)
            eventTimes(LOCS+1) = [];
            fprintf('\tRemoved %d strobes whose ISI was too small\n',length(LOCS));
        end
        
        %remove bad strobes based on possible Bonsai dropped frames
        photometry = readmatrix(dat.expFilePath(expRef, 'photometry','master'));
        photometry_numFrames = size(photometry,1);
        if length(eventTimes) > photometry_numFrames
            num_missing_frames = length(eventTimes) - photometry_numFrames;
            IFI = diff(photometry(:,1));
            [PKS, LOCS] = findpeaks(IFI,'MinPeakProminence',5,'NPeaks',num_missing_frames,'SortStr','descend'); %Edit the 0.05 threshold based on plot of IFI. Finds skipped frames
            eventTimes(LOCS)=[]; %deletes skipped frames' strobes
            fprintf('\tRemoved %d strobes based on potential dropped frames\n',length(LOCS));
        elseif length(eventTimes) < photometry_numFrames
            error('Fewer strobes than frames. Not addressed');
        end
        
        %When running the validateAlignment.m test using a fibre presented to the monitor, the timing of
        %the photometry strobes was about 30msec too late relative to the timing of
        %the stimulus onset via the photodiode. This offset compensates for that
        %timing error.
        eventTimes = eventTimes + 30/1000;
        
    case 'photometrylive_echo' %onset and offset of photometry recording
        eventTimes = midcross(v,t);
        expectedEventNumber = 2;
        
    case {'laser_echo'} %laser echo time ONSET and OFFSET
        [~,onsetTimes,~]=risetime( v, t);
        [~,offsetTimes,~]=falltime( v, t);
        
        assert( length(onsetTimes) == length(offsetTimes), 'Laser onset and offset times are not equal lengths');
        eventTimes = [onsetTimes, offsetTimes];



    case {'lickDetector','lickdetector'} %reward times
        % obtain time of first lick post-stim and post-reward
        % obtain time of first lick post-stim and post-reward
        threshold = 4.6; %threshold based on python code
        thresh_signal = v > threshold;
        thresh_signal(2:end) = thresh_signal(2:end) & ~thresh_signal(1:end-1);
        lickEventTimes_idx = find(thresh_signal);
        lickEventTimes = t(lickEventTimes_idx);




       block_stimOnTimes = [b.events.stimulusOnTimes]';
       block_rewardTimes = [b.outputs.rewardTimes]';
       block_trialEnd = [b.events.endTrialTimes]';
       num_trials = length([b.events.totalRewardTimes]);
       lick_eventTimes_stim = nan(num_trials,1);
       lick_eventTimes_reward = nan(num_trials,1);
       for n = 1:num_trials
           try     
                lick_eventTimes_stim(n) = lickEventTimes(find(lickEventTimes > block_stimOnTimes(n) & lickEventTimes< block_rewardTimes(n), 1, 'first'));
           catch
                lick_eventTimes_stim(n) = NaN; %if no lick between stim and rew, return Nan
               continue
           end
           try 
               lick_eventTimes_reward(n) = lickEventTimes(find(lickEventTimes > (block_rewardTimes(n)+0.01) & lickEventTimes < (block_trialEnd(n)) ,1,'first')); %obtain time of first 10ms post-reward
           catch
               lick_eventTimes_reward(n) = NaN;%if no lick between rew and trial end, return Nan
               continue
           end
          
       eventTimes = [lick_eventTimes_stim, lick_eventTimes_reward];    

       end
       
end

%Check against expected number of events.
if ~isempty(expectedEventNumber)
    assert(size(eventTimes,1)==expectedEventNumber, '%d events does not match %d expected',length(eventTimes),expectedEventNumber);
end

%If plotflag enabled, then plot voltage trace with event times overlaid
if p.Results.plotFlag
    figure;
    plot(t,v); xlabel('Time (sec)'); ylabel('Voltage');
    arrayfun(@(x) xline(x,'r-'),eventTimes);
end

end

function [volts,time] = getTimelineVoltageTrace(expRef, inputName)
% This function returns the voltage trace for a given channel stored in the
% Timeline file.

% Load timeline file
t = load(dat.expFilePath(expRef, 'timeline','master')); t = t.Timeline; 
assert(~isempty(t), 'No timeline data for %s',expRef);

%Define time variable
time = t.rawDAQTimestamps';

%Define voltage variable
assert(ismember(inputName, {t.hw.inputs.name}), '%s channel is not found in the Timeline file. Options are %s',inputName,strjoin({t.hw.inputs.name}, ', '));
idx = strcmp({t.hw.inputs.name},inputName);
volts = t.rawDAQData(:,t.hw.inputs(idx).arrayColumn);
end
