function data = getBehavData(expRef, dataProfile)
% data = GETBEHAVDATA(expRef, dataProfile)
% Compiles behvioural data into a nicely formatted table. Inputs are the
% session expRef (e.g. '2017-07-25_1_ALK052') and a string corresponding to
% the hard-coded dataProfile.
%
% For each experiment/dataset type, a dataProfile must be defined in the
% code. The code should translate the variables of interest into a
% standardised data format where possible. Please see the following notes
% for how to write your dataProfile:
%
% - Include a few sentences at the start describing the experiment/data type
% - Data should remain as low-level as possible. Don't include derived
% quantities such as reaction time. These quantities should be easily
% computable from the low-level data.
% - Variables should be given names which are self explanatory. For example
% use 'trialNumber' not 'n'.
% - Variables which take on discrete non-numeric values (e.g. choice or feedbackType)
% should be converted to categorical variables (see help categorical). For
% example feedback = categorical(feedbackType,[-1
% +1],'Unrewarded','Rewarded'). The reason for doing this is that variable
% values are self-explanatory.
% - Time variables should end with the 'Time'. For example
% 'stimulusOnsetTime' so it's obvious that this variable contains timing
% information.
% - If the Timeline file is not available, then dataProfile should end with
% '_noTimeline'. Timing variables will reflect estimates from the block file in these cases.
%  See the dataProfile 'Grating2AFC_noTimeline' for examples.
%
% Some standardised names to use (exactly the same lettering):
%   numTrials, trialNumber, repeatNumber, contrastLeft, contrastRight,
%   stimulusOnsetTime, goCueTime, feedback, rewardTime, rewardVolume,
%   punishSoundOnsetTime

blockFile = dat.loadBlock(expRef);
assert(~isempty(blockFile),'Block file empty');

data = table;
switch(dataProfile)
    case {'Grating2AFC','Grating2AFC_noTimeline','Grating2AFC_TransProb_noTimeline'}
        %This profile extracts the behavioural data for Grating2AFC. If
        %timeline is used, then it gets exact timestamps. Otherwises gives
        %estimates.
        
        %Trial and repeat number
        numTrials = length(blockFile.events.endTrialTimes);
        data.trialNumber = (1:numTrials)';
        data.repeatNumber = blockFile.events.repeatNumValues(1:numTrials)';
        
        %Block rewardContingency (which side has higher rewards)
        if blockFile.paramsValues(1).highRewardSize ~= blockFile.paramsValues(1).lowRewardSize
            highRewardSide = blockFile.events.highRewardSideValues(1:numTrials)';
        else
            highRewardSide = zeros(numTrials,1);
        end
        data.rewardContingency = categorical(highRewardSide,[-1 0 1],{'LeftHighReward','SymmetricReward','RightHighReward'});
        
        %Stimulus
        data.contrastLeft = blockFile.events.contrastLeftValues(1:numTrials)';
        data.contrastRight = blockFile.events.contrastRightValues(1:numTrials)';


        %Stimulus Orientation 0 = vertical, 90 = Horizontal 
        %Should only add orientation info to table if there are multiple
        %options
        stimulusOrientation = {blockFile.paramsValues.stimulusOrientation}.';
        strRepresentation = cellfun(@mat2str, stimulusOrientation, 'UniformOutput', false);
        uniqueStrs = unique(strRepresentation);
        
        if length((uniqueStrs))> 1      
            data.expectedRewardValue = [blockFile.paramsValues(1:numTrials).lowRewardSize]';
            for i = 1:numTrials
                  data.LeftOri(i) = stimulusOrientation{i}(1);
                  data.RightOri(i) = stimulusOrientation{i}(2);
            end
        end
        
        %Correct response
        data.correctResponse = categorical( blockFile.events.correctResponseValues(1:numTrials)', [-1 1], {'Left','Right'});
        
        %Choice completion time
        data.choice = categorical( blockFile.events.responseValues(1:numTrials)', [-1 1 0], {'Left','Right','NoGo'});
        data.choiceCompleteTime = blockFile.events.responseMadeTimes(1:numTrials)';
        data.choiceStartTime = getEstimatedChoiceStartTimes(blockFile.inputs.wheelMMValues, blockFile.inputs.wheelMMTimes, data.choiceCompleteTime, data.choice, blockFile.events.stimulusOnTimes(1:numTrials)');
        
        %Feedback
        data.feedback = categorical(blockFile.events.feedbackValues(1:numTrials)',[0 1],{'Unrewarded','Rewarded'});
        data.punishSoundOnsetTime = nan(numTrials,1);

        % Additional times
        data.trialStartTime = blockFile.events.newTrialTimes(1:numTrials)';
        data.preStimWaitTime = blockFile.events.preStimWaitTimes(1:numTrials)';
        data.interactiveOnTime = blockFile.events.interactiveOnTimes(1:numTrials)';
        data.feedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
        data.endTrialTime = blockFile.events.endTrialTimes(1:numTrials)';
        
        %Environment information
        if strcmp(dataProfile,'Grating2AFC_TransProb_noTimeline')
            data.environment = categorical(blockFile.events.repeatProbValues(1:numTrials)', [0.2 0.5 0.8], {'Alternating','Neutral','Repeating'});
        else
            data.environment = categorical(cellstr(repmat('Neutral',numTrials,1)));
        end
        
        
        %Times
        switch(dataProfile)
            case 'Grating2AFC'

                %Stimulus onset
                data.stimulusOnsetTime = nan(height(data),1);
                photoDiodeOnsetTimes = getEventTimes(expRef,'photodiode');
                expectedStimOnsetTimes = blockFile.events.stimulusOnTimes(1:numTrials)';
                data.stimulusOnsetTime = getStimOnsetTimes(photoDiodeOnsetTimes, expectedStimOnsetTimes, [-0.1 0.3]);
                
                %Go cue onset
                expectedTimes = blockFile.events.interactiveOnTimes(1:numTrials)';
                data.goCueTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedTimes);
                
                %reward times and volume
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = getEventTimes(expRef,'reward_echo');
                valveOpenVolumes = blockFile.outputs.rewardValues;
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 0.1]);
                
                %punish sound times
                expectedTime = expectedFeedbackTime( data.feedback=='Unrewarded' );
                data.punishSoundOnsetTime( data.feedback=='Unrewarded' ) = getEventTimes(expRef,'sound_echo','knownSoundTimes',expectedTime);
                
                 %laser
                if isfield(blockFile.events,'laserTTLmodeValues') && ~isempty(blockFile.events.laserTTLmodeValues) && any(blockFile.events.laserTTLmodeValues(1,:)>0)
                    laserTTLmode = blockFile.events.laserTTLmodeValues(:,1:numTrials)';
                    data.laserMode = categorical(laserTTLmode(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','RewardFixedDuration'});
                    data.laserMode(data.laserMode == 'rise' & data.feedback == 'Unrewarded') = 'Off';
                    data.laserOnsetTime = nan(numTrials,1);
                    data.laserOffsetTime = nan(numTrials,1);
                    
                    %Get laser onset and offset times from Timeline
                    laserTimes = getEventTimes(expRef,'laser_echo');
                    
                    %Iterate through each trial and get the time of the
                    %laser onset and laser offset
                    trialStartTimes = blockFile.events.newTrialTimes(1:numTrials)';
                    trialEndTimes = blockFile.events.endTrialTimes(1:numTrials)';
                    for tr = 1:height(data)
                        if data.laserMode(tr) ~= 'Off'
                            idx = find(laserTimes(:,1) > trialStartTimes(tr),1,'first');
                            data.laserOnsetTime(tr) = laserTimes(idx,1); %Onset as the first laser onset time in the trial
                            
                            idx = find(laserTimes(:,2) < trialEndTimes(tr),1,'last');
                            data.laserOffsetTime(tr) = laserTimes(idx,2); %Offset as the last laser offset time in the trial

                            %Occasionally, the laser echo is not properly
                            %detected for a given trial. This makes the
                            %onset time invalid for those trials. The code
                            %relabels these as laser off trials because
                            %it's not clear that the laser was actually on.
                            if ~( trialStartTimes(tr) < data.laserOnsetTime(tr) && data.laserOnsetTime(tr) < trialEndTimes(tr) )
                                warning('Expected laser echo was not detected for trial %d. Setting trial as a laser off trial. If this happens for many trials, something is wrong', tr);
                                data.laserOnsetTime(tr) = nan;
                                data.laserOffsetTime(tr) = nan;
                                data.laserMode(tr) = 'Off';
                            end
                            
                        end
                    end
                end
                
            case {'Grating2AFC_noTimeline','Grating2AFC_TransProb_noTimeline'}
                data.stimulusOnsetTime = blockFile.events.stimulusOnTimes(1:numTrials)';
                data.goCueTime = blockFile.events.interactiveOnTimes(1:numTrials)';
                
                %reward times and volume
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = blockFile.outputs.rewardTimes;
                valveOpenVolumes = blockFile.outputs.rewardValues;
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 0.1]);

                %punish sound times, using block time estimate
                expectedTime = expectedFeedbackTime( data.feedback=='Unrewarded' );
                data.punishSoundOnsetTime( data.feedback=='Unrewarded' ) = expectedTime;
                
                %laser
                if isfield(blockFile.events,'laserTTLmodeValues')  && ~isempty(blockFile.events.laserTTLmodeValues) && any(blockFile.events.laserTTLmodeValues(1,:)>0)
                    laserTTLmode = blockFile.events.laserTTLmodeValues(:,1:numTrials)';
                    data.laserMode = categorical(laserTTLmode(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','RewardFixedDuration'});
                    data.laserMode(data.laserMode == 'RewardFixedDuration' & data.feedback == 'Unrewarded') = 'Off';
                    data.laserOnsetTime = nan(numTrials,1);
                    data.laserOffsetTime = nan(numTrials,1);
                 
                    %Get laser onset and offset times from blockfile
                    laserOnsetTimes = blockFile.outputs.laserTTLTimes(blockFile.outputs.laserTTLValues==1)';
                    laserOnsetTimes( laserOnsetTimes > blockFile.events.endTrialTimes(numTrials) ) = []; %remove any laser onsets after last trial
                    laserOffTimes = blockFile.outputs.laserTTLTimes(blockFile.outputs.laserTTLValues==0)';
                    [~,idx]=max(laserOnsetTimes < laserOffTimes',[],2);
                    laserOffsetTimes = laserOffTimes(idx);
                    data.laserOnsetTime( data.laserMode ~= 'Off' ) = laserOnsetTimes;
                    data.laserOffsetTime( data.laserMode ~= 'Off' ) = laserOffsetTimes;
                end
        end

        case{'Grating2AFC_Reversal', 'Grating2AFC_Reversal_noTimeline'}
        %This profile extracts the behavioural data for Grating2AFC. If
        %timeline is used, then it gets exact timestamps. Otherwises gives
        %estimates.
        
        %Trial and repeat number
        numTrials = length(blockFile.events.endTrialTimes);
        data.trialNumber = (1:numTrials)';
        data.repeatNumber = blockFile.events.repeatNumValues(1:numTrials)';
        data.contrastSet = repmat(blockFile.paramsValues(1).contrastSet, numTrials, 1);
        data.blockLength = repmat(blockFile.paramsValues(1).blockLength, numTrials, 1);
        
        if blockFile.paramsValues(1).proportionLeft == 0
        data.StartCorrectChoice = repmat('Right', numTrials, 1);
        else data.StartCorrectChoice = repmat('Left', numTrials, 1);
        end
        data.trialsToBuffer = repmat(blockFile.paramsValues(1).trialsToBuffer, numTrials, 1);

        try
            data.accuracyThreshold = repmat(blockFile.paramsValues(1).accuracyThreshold, numTrials, 1);
        catch data.accuracyThreshold = repmat(0.85, numTrials, 1); %when I first ran this task accuracy threshold was hard coded to 0.85 hence why it didn't get saved
        end
        
        %Stimulus
        data.contrastLeft = blockFile.events.contrastLeftValues(1:numTrials)';
        data.contrastRight = blockFile.events.contrastRightValues(1:numTrials)';
        
          
        %Choice completion time
        data.choice = categorical( blockFile.events.responseValues(1:numTrials)', [-1 1 0], {'Left','Right','NoGo'});
        data.choiceCompleteTime = blockFile.events.responseMadeTimes(1:numTrials)';
        data.choiceStartTime = getEstimatedChoiceStartTimes(blockFile.inputs.wheelMMValues, blockFile.inputs.wheelMMTimes, data.choiceCompleteTime, data.choice, blockFile.events.stimulusOnTimes(1:numTrials)');
        
        %Feedback
        data.feedback = categorical(blockFile.events.feedbackValues(1:numTrials)',[0 1],{'Unrewarded','Rewarded'});
        data.punishSoundOnsetTime = nan(numTrials,1);

        % Additional times
        data.trialStartTime = blockFile.events.newTrialTimes(1:numTrials)';
        data.preStimWaitTime = blockFile.events.preStimWaitTimes(1:numTrials)';
        data.interactiveOnTime = blockFile.events.interactiveOnTimes(1:numTrials)';
        data.feedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
        data.endTrialTime = blockFile.events.endTrialTimes(1:numTrials)';
        
        switch(dataProfile)
            case 'Grating2AFC_Reversal'

                %Stimulus onset
                data.stimulusOnsetTime = nan(height(data),1);
                photoDiodeOnsetTimes = getEventTimes(expRef,'photodiode');
                expectedStimOnsetTimes = blockFile.events.stimulusOnTimes(1:numTrials)';
                data.stimulusOnsetTime = getStimOnsetTimes(photoDiodeOnsetTimes, expectedStimOnsetTimes, [-0.1 0.3]);
                
                %Go cue onset
                expectedTimes = blockFile.events.interactiveOnTimes(1:numTrials)';
                data.goCueTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedTimes);
                
                %reward times and volume
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = getEventTimes(expRef,'reward_echo');
                valveOpenVolumes = blockFile.outputs.rewardValues;
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 0.1]);

                %punish sound times
                expectedTime = expectedFeedbackTime( data.feedback=='Unrewarded' );
                data.punishSoundOnsetTime( data.feedback=='Unrewarded' ) = getEventTimes(expRef,'sound_echo','knownSoundTimes',expectedTime);

                %reversals parameters
                data.hitBufferValues = blockFile.events.hitBufferValues(1:numTrials)';
                data.hitBufferTimes = blockFile.events.hitBufferTimes(1:numTrials)';

                data.trialsToSwitchValues = blockFile.events.trialsToSwitchValues(1:numTrials)';
                data.trialsToSwitchTimes = blockFile.events.trialsToSwitchTimes(1:numTrials)';

                data.hitRateValues = blockFile.events.hitRateValues(1:numTrials)';
                data.hitRateTimes = blockFile.events.hitRateTimes(1:numTrials)';
                
                 %laser
                if isfield(blockFile.events,'laserTTLmodeValues') && ~isempty(blockFile.events.laserTTLmodeValues) && any(blockFile.events.laserTTLmodeValues(1,:)>0)
                    laserTTLmode = blockFile.events.laserTTLmodeValues(:,1:numTrials)';
                    data.laserMode = categorical(laserTTLmode(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','RewardFixedDuration'});
                    data.laserMode(data.laserMode == 'rise' & data.feedback == 'Unrewarded') = 'Off';
                    data.laserOnsetTime = nan(numTrials,1);
                    data.laserOffsetTime = nan(numTrials,1);
                    
                    %Get laser onset and offset times from Timeline
                    laserTimes = getEventTimes(expRef,'laser_echo');
                    
                    %Iterate through each trial and get the time of the
                    %laser onset and laser offset
                    trialStartTimes = blockFile.events.newTrialTimes(1:numTrials)';
                    trialEndTimes = blockFile.events.endTrialTimes(1:numTrials)';
                    for tr = 1:height(data)
                        if data.laserMode(tr) ~= 'Off'
                            idx = find(laserTimes(:,1) > trialStartTimes(tr),1,'first');
                            data.laserOnsetTime(tr) = laserTimes(idx,1); %Onset as the first laser onset time in the trial
                            
                            idx = find(laserTimes(:,2) < trialEndTimes(tr),1,'last');
                            data.laserOffsetTime(tr) = laserTimes(idx,2); %Offset as the last laser offset time in the trial

                            %Occasionally, the laser echo is not properly
                            %detected for a given trial. This makes the
                            %onset time invalid for those trials. The code
                            %relabels these as laser off trials because
                            %it's not clear that the laser was actually on.
                            if ~( trialStartTimes(tr) < data.laserOnsetTime(tr) && data.laserOnsetTime(tr) < trialEndTimes(tr) )
                                warning('Expected laser echo was not detected for trial %d. Setting trial as a laser off trial. If this happens for many trials, something is wrong', tr);
                                data.laserOnsetTime(tr) = nan;
                                data.laserOffsetTime(tr) = nan;
                                data.laserMode(tr) = 'Off';
                            end
                            
                        end
                    end
                end
                
            case {'Grating2AFC_Reversal_noTimeline'}
                data.stimulusOnsetTime = blockFile.events.stimulusOnTimes(1:numTrials)';
                data.goCueTime = blockFile.events.interactiveOnTimes(1:numTrials)';
                
                %reward times and volume
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = blockFile.outputs.rewardTimes;
                valveOpenVolumes = blockFile.outputs.rewardValues;
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 0.1]);
                
                %punish sound times, using block time estimate
                expectedTime = expectedFeedbackTime( data.feedback=='Unrewarded' );
                data.punishSoundOnsetTime( data.feedback=='Unrewarded' ) = expectedTime;
                
                %laser
                if isfield(blockFile.events,'laserTTLmodeValues')  && ~isempty(blockFile.events.laserTTLmodeValues) && any(blockFile.events.laserTTLmodeValues(1,:)>0)
                    laserTTLmode = blockFile.events.laserTTLmodeValues(:,1:numTrials)';
                    data.laserMode = categorical(laserTTLmode(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','RewardFixedDuration'});
                    data.laserMode(data.laserMode == 'RewardFixedDuration' & data.feedback == 'Unrewarded') = 'Off';
                    data.laserOnsetTime = nan(numTrials,1);
                    data.laserOffsetTime = nan(numTrials,1);
                 
                    %Get laser onset and offset times from blockfile
                    laserOnsetTimes = blockFile.outputs.laserTTLTimes(blockFile.outputs.laserTTLValues==1)';
                    laserOnsetTimes( laserOnsetTimes > blockFile.events.endTrialTimes(numTrials) ) = []; %remove any laser onsets after last trial
                    laserOffTimes = blockFile.outputs.laserTTLTimes(blockFile.outputs.laserTTLValues==0)';
                    [~,idx]=max(laserOnsetTimes < laserOffTimes',[],2);
                    laserOffsetTimes = laserOffTimes(idx);
                    data.laserOnsetTime( data.laserMode ~= 'Off' ) = laserOnsetTimes;
                    data.laserOffsetTime( data.laserMode ~= 'Off' ) = laserOffsetTimes;
                end
        end

    case{'Grating2AFC_reversalCT_extraTrials_pavlov'}
        %This profile extracts the behavioural data for Grating2AFC. If
        %timeline is used, then it gets exact timestamps. Otherwises gives
        %estimates.

        %Trial and repeat number
        numTrials = length(blockFile.events.endTrialTimes);
        data.trialNumber2 = (1:numTrials)';
        data.repeatNumber = blockFile.events.repeatNumValues(1:numTrials)';
        data.contrastSet = repmat(blockFile.paramsValues(1).contrastSet, numTrials, 1);
        data.blockLength = repmat(blockFile.paramsValues(1).blockLength, numTrials, 1);
        data.accuracyThreshold = repmat(blockFile.paramsValues(1).accuracyThreshold, numTrials, 1);

        if blockFile.paramsValues(1).proportionLeft == 0
            data.StartCorrectChoice = repmat('Right', numTrials, 1);
        else data.StartCorrectChoice = repmat('Left', numTrials, 1);
        end
        data.trialsToBuffer = repmat(blockFile.paramsValues(1).trialsToBuffer, numTrials, 1);
        data.extraTrials = repmat(blockFile.paramsValues(1).extraTrials, numTrials, 1);

        pavlovTrials = blockFile.paramsValues(1).pavlovTrials;
        data.TrialType = cell(height(data),1);

        data.TrialType(1:pavlovTrials,1) = {'Pavlov'};
        data.TrialType(pavlovTrials+1:end,1) = {'Instrumental'};
        data.TrialType = categorical(data.TrialType);

        %Stimulus
        data.contrastLeft = blockFile.events.contrastLeftValues(1:numTrials)';
        data.contrastRight = blockFile.events.contrastRightValues(1:numTrials)';

        data.contrastLeft(pavlovTrials+1) = data.contrastLeft(pavlovTrials+2); %this is to fix a bug whereby the trial after the last Pavlovian trial still figures as a '0' even though it's actually either -1 or 1, and it's the same as 2 trials after the last Pavlovian trial
        data.contrastRight(pavlovTrials+1) = data.contrastRight(pavlovTrials+2);

        data.trialNumber = NaN(height(data),1);
        data.trialNumber(1:pavlovTrials,1) = 1:pavlovTrials;
        data.trialNumber(pavlovTrials+1:end) = 1:height(data)-pavlovTrials;     


        %Choice completion time
        data.choice = categorical( blockFile.events.responseValues(1:numTrials)', [-1 1 0], {'Left','Right','NoGo'});
        data.choiceCompleteTime = blockFile.events.responseMadeTimes(1:numTrials)';
        data.choiceStartTime = getEstimatedChoiceStartTimes(blockFile.inputs.wheelMMValues, blockFile.inputs.wheelMMTimes, data.choiceCompleteTime, data.choice, blockFile.events.stimulusOnTimes(1:numTrials)');

        %Feedback
        data.feedback = blockFile.events.feedbackValues(1:numTrials)';
        data.feedback(data.feedback>0) = 1;
        data.feedback = categorical(data.feedback,[0 1],{'Unrewarded','Rewarded'});
        data.punishSoundOnsetTime = nan(numTrials,1);

        % Additional times
        data.trialStartTime = blockFile.events.newTrialTimes(1:numTrials)';
        data.preStimWaitTime = blockFile.events.preStimWaitTimes(1:numTrials)';
        data.interactiveOnTime = blockFile.events.interactiveOnTimes(1:numTrials)';
        data.feedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
        data.endTrialTime = blockFile.events.endTrialTimes(1:numTrials)';

        %Stimulus onset
        data.stimulusOnsetTime = nan(height(data),1);
        photoDiodeOnsetTimes = getEventTimes(expRef,'photodiode');
        expectedStimOnsetTimes = blockFile.events.stimulusOnTimes(1:numTrials)';
        data.stimulusOnsetTime = getStimOnsetTimes(photoDiodeOnsetTimes, expectedStimOnsetTimes, [-0.1 0.3]);

        %Go cue onset
        expectedTimes = blockFile.events.interactiveOnTimes(1:numTrials)';
        data.goCueTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedTimes);

        %reward times and volume
        expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
        valveOpenTimes = getEventTimes(expRef,'reward_echo');
        valveOpenVolumes = blockFile.outputs.rewardValues;
        [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 0.1]);

        %punish sound times
        expectedTime = expectedFeedbackTime( data.feedback=='Unrewarded' );
        data.punishSoundOnsetTime( data.feedback=='Unrewarded' ) = getEventTimes(expRef,'sound_echo','knownSoundTimes',expectedTime);
       
  
    case {'Grating2AFC_choiceWorld','Grating2AFC_choiceWorld_noTimeline'}
        %This profile is for old choiceworld data using Armin's task.
        %Trials start with an onset tone, followed by a left/right contrast stimulus
        %In some sessions there is a go cue. Mice make a wheel turn and a
        %reward or punish sound is given. The reward volume given can
        %either be a fixed value, or vary in blocks. Block identity
        %switches between 'LeftHighReward' and 'RightHighReward'.
        
        trial = [blockFile.trial];
        cond = [trial.condition];
        
        numTrials = length([trial.responseMadeID]);
        trial = trial(1:numTrials);
        cond = cond(1:numTrials);
        
        %Trial and repeat number
        data.trialNumber = (1:numTrials)';
        data.repeatNumber = [cond.repeatNum]';
        
        %Block identity (which side has higher rewards) IF there are 2
        %reward values possible.
        rewardDelivered = unique(blockFile.rewardDeliveredSizes(:,1))';
        if length(rewardDelivered)==2
            params = load(dat.expFilePath(expRef, 'parameters','master'));
            contrastConds = params.parameters.visCueContrast(2,:)-params.parameters.visCueContrast(1,:);
            rewardSizes = params.parameters.rewardVolume(1,:);
            
            blockType = any(contrastConds(rewardSizes==max(rewardSizes)) > 0); %is Higher on Right
            blockType = blockType*ones(size(data.trialNumber));
        else
            blockType = -1*ones(numTrials,1);
        end
        
        data.rewardContingency = categorical(blockType,[0 1 -1],{'LeftHighReward','RightHighReward','SymmetricReward'});
        
        %Onset tone (1st number)
        soundOnsets = cell2mat( {trial.onsetToneSoundPlayedTime}');
        soundOnsets(soundOnsets<0) = 0; %correct any weird negative sound onset times
        expectedTime = soundOnsets(:,1); %first sound is onset Tone
        switch(dataProfile)
            case 'Grating2AFC_choiceWorld'
                data.onsetToneTime = getEventTimes(expRef,'audioMonitor','knownSoundTimes',expectedTime);
            case 'Grating2AFC_choiceWorld_noTimeline'
                data.onsetToneTime = expectedTime;
        end
        
        %Stimulus
        stimulus = [cond.visCueContrast]';
        data.contrastLeft = stimulus(:,1);
        data.contrastRight = stimulus(:,2);
        switch(dataProfile)
            case 'Grating2AFC_choiceWorld'
                data.stimulusOnsetTime = getEventTimes(expRef,'photoDiode');
            case 'Grating2AFC_choiceWorld_noTimeline'
                data.stimulusOnsetTime = [trial.stimulusCueStartedTime]';
        end
        
        %Go cue, only if soundOnsets has a 2nd column
        if size(soundOnsets,2) == 2
            expectedTime = soundOnsets(:,2);
            switch(dataProfile)
                case 'Grating2AFC_choiceWorld'
                    data.goCueTime = getEventTimes(expRef,'audioMonitor','knownSoundTimes',expectedTime);
                case 'Grating2AFC_choiceWorld_noTimeline'
                    data.goCueTime = expectedTime;
            end
        end
        
        %Choice
        data.choice = categorical( [trial.responseMadeID]', 1:3, {'Left','Right','NoGo'});
        data.choiceCompleteTime = [trial.responseMadeTime]';
        data.choiceStartTime = getEstimatedChoiceStartTimes(blockFile.inputSensorPositions, blockFile.inputSensorPositionTimes, data.choiceCompleteTime, data.choice, data.stimulusOnsetTime);
        
        %Feedback
        data.feedback = categorical( [trial.feedbackType]', [-1 1], {'Unrewarded','Rewarded'});
        
        %Reward size/time and punish times
        data.rewardVolume = nan(numTrials,1);
        valveOpenSize = blockFile.rewardDeliveredSizes(:,1);
        data.rewardVolume( data.feedback=='Rewarded' ) = valveOpenSize;
        data.rewardTime = nan(numTrials,1);
        data.punishSoundOnsetTime = nan(numTrials,1);
        
        switch(dataProfile)
            case 'Grating2AFC_choiceWorld'
                valveOpenTimes = getEventTimes(expRef,'waterValve');
                data.rewardTime( data.feedback=='Rewarded' ) = valveOpenTimes;
                
                expectedTime = [trial.negFeedbackSoundPlayedTime]';
                data.punishSoundOnsetTime( data.feedback=='Unrewarded' ) = getEventTimes(expRef,'audioMonitor','knownSoundTimes',expectedTime);
                
            case 'Grating2AFC_choiceWorld_noTimeline'
                data.rewardTime( data.feedback=='Rewarded' ) =  blockFile.rewardDeliveryTimes';
                data.punishSoundOnsetTime( data.feedback=='Unrewarded' ) = [trial.negFeedbackSoundPlayedTime]';
        end
        
    case 'RiskPreference_noTimeline'
        %This profile extracts behavioural data for the RiskPreference
        %task. It assumes that Timeline was _not_ used, and therefore all
        %timing measures (except wheel start and stop times) are approximate.
        %The stimulus bar heights represent potential reward volumes. NaN bar
        %values represent no bar being present on that trial.
        
        %Trial and repeat number
        numTrials = length(blockFile.events.endTrialTimes);
        data.trialNumber = (1:numTrials)';
        data.repeatNumber = blockFile.events.repeatNumValues(1:numTrials)';
        
        %Stimulus, bar values in units of reward volume (uL). If values are
        %-1, then no bar was present.
        data.leftBarValues = [blockFile.events.leftStim1ValueValues(1:numTrials)',...
            blockFile.events.leftStim2ValueValues(1:numTrials)'];
        data.leftBarValues(data.leftBarValues==-1) = NaN;
        data.rightBarValues = [blockFile.events.rightStim1ValueValues(1:numTrials)',...
            blockFile.events.rightStim2ValueValues(1:numTrials)'];
        data.rightBarValues(data.rightBarValues==-1) = NaN;
        data.stimulusOnsetTime = blockFile.events.stimulusOnTimes(1:numTrials)';
        
        %Go cue
        data.goCueTime = blockFile.events.interactiveOnTimes(1:numTrials)';
        
        %Choice
        data.choice = categorical( blockFile.events.choiceValues(1:numTrials)', [-1 1 0], {'Left','Right','NoGo'});
        data.choiceCompleteTime = blockFile.events.responseMadeTimes(1:numTrials)';
        data.choiceStartTime = getEstimatedChoiceStartTimes(blockFile.inputs.wheelMMValues, blockFile.inputs.wheelMMTimes, data.choiceCompleteTime, data.choice, blockFile.events.stimulusOnTimes(1:numTrials)');
        
        %Reward outcome
        expectedFeedbackTime = data.choiceCompleteTime;
        valveOpenTimes = blockFile.outputs.rewardTimes;
        valveOpenVolumes = blockFile.outputs.rewardValues;
        valveOpenTimes = valveOpenTimes(valveOpenVolumes>0);
        valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
        [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
    
    
    case {'RiskPreferenceImplicit',...
            'RiskPreferenceImplicit_noTimeline',...
            'RiskPreferenceImplicitStructured_noTimeline'}
        %Extracts behavioural data for implicit risk task. There are no
        %visual stimuli. Mice choose left or right, and receive rewards.
        %One choice is assoicated with gambles, and the other is associated
        %with a certain reward. The side associated with gambles switches.
        
        %Trial number
        numTrials = length(blockFile.events.endTrialTimes);
        data.trialNumber = (1:numTrials)';
        
        %Block identity (which side is associated with gambles)
        data.block = categorical(blockFile.events.gambleChoiceValues(1:numTrials)',[-1 1],{'LeftChoiceGamble','RightChoiceGamble'});
        
        %Choice
        data.choice = categorical( blockFile.events.responseValues(1:numTrials)', [-1 1 0], {'Left','Right','NoGo'});
        data.choiceCompleteTime = blockFile.events.responseMadeTimes(1:numTrials)';
        data.choiceStartTime = getEstimatedChoiceStartTimes(blockFile.inputs.wheelMMValues, blockFile.inputs.wheelMMTimes, data.choiceCompleteTime, data.choice, blockFile.events.interactiveOnTimes(1:numTrials)');
        
        %Certain reward size for each trial
        if isfield(blockFile.events, 'certainRewardSizeValues')
            data.certainRewardSize = blockFile.events.certainRewardSizeValues(1:numTrials)';
        end
        
        %Times
        switch(dataProfile)
            case 'RiskPreferenceImplicit'
                expectedTimes = blockFile.events.interactiveOnTimes(1:numTrials)';
                data.goCueTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedTimes);
                
                %reward time and volume
                expectedFeedbackTime = data.choiceCompleteTime;
                valveOpenTimes = getEventTimes(expRef,'reward_echo');
                valveOpenVolumes = blockFile.outputs.rewardValues';
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                
            case {'RiskPreferenceImplicit_noTimeline','RiskPreferenceImplicitStructured_noTimeline'}
                data.goCueTime = blockFile.events.interactiveOnTimes(1:numTrials)';
                
                %reward time and volume
                expectedFeedbackTime = data.choiceCompleteTime;
                valveOpenTimes = blockFile.outputs.rewardTimes;
                valveOpenVolumes = blockFile.outputs.rewardValues;
                valveOpenTimes = valveOpenTimes(valveOpenVolumes>0);
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
        end
        
    case {'RiskPreference2StimTypes','RiskPreference2StimTypes_noTimeline'}
        
        numTrials = length(blockFile.events.endTrialTimes);
        
        data.trialNumber = (1:numTrials)';
        data.repeatNumber = blockFile.events.repeatNumValues(1:numTrials)';
        
        %Stimulus conditions coded as 3 columns. Cols 1 and 2 are the
        %grating value. Col 3 is the gamble
        rightVals = [blockFile.paramsValues(1:numTrials).rightStimValues]';
        leftVals = [blockFile.paramsValues(1:numTrials).leftStimValues]';
        
        %stimulus on left
        isGamble = (leftVals(:,3)>=0);
        isGrating = leftVals(:,1)>0;
        leftOri = [blockFile.paramsValues(1:numTrials).leftStimOrientation]';
        stimulusLeft = 1*isGamble + 2*(isGrating & leftOri==0) + 3*(isGrating & leftOri==90); %grating Horz or vert or circle
        data.stimulusLeft = categorical(stimulusLeft,[0 1 2 3],{'None','Circle','VertGrating','HorzGrating'});
        data.stimulusLeftPayoff = nan( height(data), 2);
        data.stimulusLeftPayoff(isGrating,:) = leftVals(isGrating,1:2);
        data.stimulusLeftPayoff(isGamble,1) = min(leftVals(isGamble,3));
        data.stimulusLeftPayoff(isGamble,2) = max(leftVals(isGamble,3));
        data.stimulusLeftPayoff(~isGamble & ~isGrating, :) = 0;

        %stimulus on right
        isGamble = (rightVals(:,3)>=0);
        isGrating = rightVals(:,1)>0;
        rightOri = [blockFile.paramsValues(1:numTrials).rightStimOrientation]';
        stimulusRight = 1*isGamble + 2*(isGrating & rightOri==0) + 3*(isGrating & rightOri==90); %grating Horz or vert or circle
        data.stimulusRight = categorical(stimulusRight,[0 1 2 3],{'None','Circle','VertGrating','HorzGrating'});
        data.stimulusRightPayoff = nan( height(data), 2);
        data.stimulusRightPayoff(isGrating,:) = rightVals(isGrating,1:2);
        data.stimulusRightPayoff(isGamble,1) = min(rightVals(isGamble,3));
        data.stimulusRightPayoff(isGamble,2) = max(rightVals(isGamble,3));
        data.stimulusRightPayoff(~isGamble & ~isGrating, :) = 0;
        
        %choice
        data.choice = categorical( blockFile.events.choiceValues(1:numTrials)', [-1 1 0], {'Left','Right','NoGo'});
        data.choiceCompleteTime = blockFile.events.responseMadeTimes(1:numTrials)';
        data.choiceStartTime = getEstimatedChoiceStartTimes(blockFile.inputs.wheelMMValues, blockFile.inputs.wheelMMTimes, data.choiceCompleteTime, data.choice, blockFile.events.stimulusOnTimes(1:numTrials)');
        
        switch(dataProfile)
            case 'RiskPreference2StimTypes'
                %Stimulus onset
                stimOnTimes = getEventTimes(expRef,'photodiode');
                data.stimulusOnsetTime = stimOnTimes(1:numTrials);
                
                %go cue
                expectedTimes = blockFile.events.interactiveOnTimes(1:numTrials)';
                data.goCueTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedTimes);
                
                %Reward outcome (with timeline)
                expectedFeedbackTime = data.choiceCompleteTime;
                valveOpenTimes = getEventTimes(expRef,'reward_echo');
                valveOpenVolumes = blockFile.outputs.rewardValues';
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                
            case 'RiskPreference2StimTypes_noTimeline'
                %Stimulus onset
                data.stimulusOnsetTime = blockFile.events.stimulusOnTimes(1:numTrials)';
                
                %Go cue
                data.goCueTime = blockFile.events.interactiveOnTimes(1:numTrials)';
                
                %Reward outcome (no timeline)
                expectedFeedbackTime = data.choiceCompleteTime;
                valveOpenTimes = blockFile.outputs.rewardTimes;
                valveOpenVolumes = blockFile.outputs.rewardValues;
                valveOpenTimes = valveOpenTimes(valveOpenVolumes>0);
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                %data.rewardMagnitudeTimes = blockFile.events.rewardMagnitudeTimes(1:numTrials)';
                
        end
        
    case {'Pavlov1','Pavlov1_noTimeline','IntertemporalPavlov'}
        %Extracts behavioural data for Pavlov1 task. Visual stimuli (or
        %blank screen) are presented, and after a delay the reward is
        %given. No wheel movements are required.
        
        %Trial number
        if (length(blockFile.events.endTrialTimes) == length(blockFile.events.newTrialTimes)-1) & any(blockFile.events.expStopTimes >0)
            % For Pavlov1_pseudorandomisation, last trial does not have an
            % endTrialTime; define this as the experimentStopTime
            % (generally length of trialDuration)
            blockFile.events.endTrialTimes(end+1) = blockFile.events.expStopTimes;
            disp('Extending endTrialTimes')
        end
        numTrials = length(blockFile.events.endTrialTimes);
        data.trialNumber = (1:numTrials)';
        
        %Stimulus type
        if ~isfield(blockFile.paramsValues, 'stimulusOrientation')
            stimType = blockFile.events.stimulusTypeValues(1:numTrials)';
            data.stimulusType = categorical(stimType,[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19, 20, 21, 22, 23],{'None','Cross','Circle','50%GratingLeft','25%GratingLeft','50%GratingRight','25%GratingRight','100%GratingCentre', 'Rectangle', '0%Grating', '4000Hz', '8000Hz', 'WNoise', 'CrossBlack', 'CircleLarge', '2000Hz', 'CircleBlack', 'Grating0', 'Grating90', 'Grating45', 'Gabor0', 'Gabor90', 'Gabor45', 'Gabor135'});
        else 
            %ST 01/2025: functionality for Pavlov1_switchingProb which determines stimulus type via stimulusOrientation
            %Stimulus Orientation 0 = vertical, 90 = Horizontal 
            stimulusOrientation = {blockFile.paramsValues.stimulusOrientation}.';
            stimulusOrientation = stimulusOrientation(1:numTrials);
            stimOriDegree       =  cellfun(@(x) x(1), stimulusOrientation); % only takes 1st number in double as stimulus orientation
            
            % First, fill data.stimulusType with Gabor + Orientations where
            % stimulusTypeValues > 0
            stimType = blockFile.events.stimulusTypeValues(1:numTrials)';
            data.stimulusType   = categorical(stimOriDegree, [0 45 90 135],{'Gabor0', 'Gabor45', 'Gabor90', 'Gabor135'});
            data.stimulusType(stimType>0) = data.stimulusType(stimType>0);
            % Next, fill data.stimulusType with None where stimulusType==0
            data.stimulusType(stimType==0) = 'None';
            data.stimulusType              = categorical(data.stimulusType);
        end     
        gratingStimuliEvents = data.stimulusType~='None';
        
        %Times
        switch(dataProfile)
            case 'Pavlov1'
                %Stim onset and offset
                data.stimulusOnsetTime = nan(height(data),1);
                data.stimulusOffsetTime = nan(height(data),1);
                if any(stimType>0)
                    disp('In getBehavData: Using photodiode times to infer stimOnsetTimes')
                    photoDiodeOnsetTimes = getEventTimes(expRef,'photodiode');
                    expectedStimOnsetTimes = blockFile.events.stimulusOnTimes';
                    expectedStimOnsetTimes(expectedStimOnsetTimes > blockFile.events.endTrialTimes(numTrials)) = [];
                    data.stimulusOnsetTime(gratingStimuliEvents) = getStimOnsetTimes(photoDiodeOnsetTimes, expectedStimOnsetTimes, [-0.1 0.3]);
                end
                stimOffTimes = blockFile.events.stimulusOffTimes';
                data.stimulusOffsetTime(gratingStimuliEvents) = stimOffTimes(gratingStimuliEvents);

                %reward time and volume
                expectedFeedbackTime = blockFile.events.newTrialTimes(1:numTrials)';
                valveOpenTimes = getEventTimes(expRef,'reward_echo');
                valveOpenVolumes = blockFile.outputs.rewardValues';
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);

                % Increase window length for getRewardTimes if jitter is
                % present and >0
                maxDelay = 0;
                % jitterFieldNames = {'stimulusDelay', 'feedbackDelay'};
                if any(contains(fieldnames(blockFile.paramsValues), 'stimulusDelay', 'IgnoreCase', true))
                    maxDelay = maxDelay + max(blockFile.paramsValues(1).stimulusDelay);
                end
                if any(contains(fieldnames(blockFile.paramsValues), 'feedbackDelay', 'IgnoreCase', true))
                    maxDelay = maxDelay + max(blockFile.paramsValues(1).feedbackDelay);
                end
                windowEnd = 3+maxDelay;
                % disp(maxDelay);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 windowEnd]);

                %LickTimings - time of first lick after stimulus or reward
                %presentation. No licks in the trial period returns NaN
                
                 %If there is no LickDetector in the timeline file, then it
                 %will skip over this. 
                try
                    firstLickTimings = getEventTimes(expRef,'lickDetector'); %chagne event time file name when updated main func
                    [data.lickTimePostStim] = firstLickTimings(1:numTrials,1);
                    [data.lickTimePostReward] = firstLickTimings(1:numTrials,2);
                catch 
                end
                % Look for stimulusDelay and feedbackDelay
                try
                    stimulusOffsetJitter = blockFile.events.stimulusDelayValues(1:numTrials)';
                    [data.stimulusOffsetJitter] = stimulusOffsetJitter(:);
                    rewardJitter = blockFile.events.feedbackDelayValues(1:numTrials)';
                    [data.rewardJitter] = rewardJitter(:);
                catch 
                end
                    
                %laser
                if isfield(blockFile.events,'laserTTLmodeValues')  && ~isempty(blockFile.events.laserTTLmodeValues) && any(blockFile.events.laserTTLmodeValues(1,:)>0)
                    laserTTLmode = blockFile.events.laserTTLmodeValues(:,1:numTrials)';
                    data.laserMode = categorical(laserTTLmode(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','OutcomeFixedDuration'});
                    data.laserOnsetTime = nan(numTrials,1);
                    data.laserOffsetTime = nan(numTrials,1);
                    
                    %Get laser onset and offset times from Timeline
                    laserTimes = getEventTimes(expRef,'laser_echo');
                    
                    %Iterate through each trial and get the time of the
                    %laser onset and laser offset
                    trialStartTimes = blockFile.events.newTrialTimes(1:numTrials)';
                    trialEndTimes = blockFile.events.endTrialTimes(1:numTrials)';
                    for tr = 1:height(data)
                        if data.laserMode(tr) ~= 'Off'
                            idx = find(laserTimes(:,1) > trialStartTimes(tr),1,'first');
                            data.laserOnsetTime(tr) = laserTimes(idx,1); %Onset as the first laser onset time in the trial
                            
                            idx = find(laserTimes(:,2) < trialEndTimes(tr),1,'last');
                            data.laserOffsetTime(tr) = laserTimes(idx,2); %Offset as the last laser offset time in the trial
                            
                            %Occasionally, the laser echo is not properly
                            %detected for a given trial. This makes the
                            %onset time invalid for those trials. The code
                            %relabels these as laser off trials because
                            %it's not clear that the laser was actually on.
                            if ~( trialStartTimes(tr) < data.laserOnsetTime(tr) && data.laserOnsetTime(tr) < trialEndTimes(tr) )
                                warning('Expected laser echo was not detected for trial %d. Setting trial as a laser off trial. If this happens for many trials, something is wrong', tr);
                                data.laserOnsetTime(tr) = nan;
                                data.laserOffsetTime(tr) = nan;
                                data.laserMode(tr) = 'Off';
                            end
                        end
                    end
                    
                end
            case 'Pavlov1_noTimeline'
                %Stim onset and offset
                stimOnTimes = blockFile.events.stimulusOnTimes';
                stimOffTimes = blockFile.events.stimulusOffTimes';
                data.stimulusOnsetTime = nan(height(data),1);
                data.stimulusOffsetTime = nan(height(data),1);
                disp('In getBehavData: Using non None stimulus types to infer stimOnsetTime')
                data.stimulusOnsetTime(data.stimulusType~='None') = stimOnTimes(1:sum(gratingStimuliEvents));
                data.stimulusOffsetTime(data.stimulusType~='None') = stimOffTimes(1:sum(gratingStimuliEvents));
                
                %reward time and volume
                expectedFeedbackTime = blockFile.events.newTrialTimes(1:numTrials)';
                valveOpenTimes = blockFile.outputs.rewardTimes;
                valveOpenVolumes = blockFile.outputs.rewardValues;
                valveOpenTimes = valveOpenTimes(valveOpenVolumes>0);
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);

                % Increase window length for getRewardTimes if jitter is
                % present and >0
                maxDelay = 0;
                % jitterFieldNames = {'stimulusDelay', 'feedbackDelay'};
                if any(contains(fieldnames(blockFile.paramsValues), 'stimulusDelay', 'IgnoreCase', true))
                    maxDelay = maxDelay + max(blockFile.paramsValues(1).stimulusDelay);
                end
                if any(contains(fieldnames(blockFile.paramsValues), 'feedbackDelay', 'IgnoreCase', true))
                    maxDelay = maxDelay + max(blockFile.paramsValues(1).feedbackDelay);
                end
                windowEnd = 3+maxDelay;
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 windowEnd]);
                
                %LickTimings - time of first lick after stimulus or reward
                %presentation (+10ms later for reward to avoid crossover)
                %No licks in the trial period returns NaN

                 %If there is no LickDetector in the timeline file, then it
                 %will skip over this. bit messy a way but works. 
                try
                    firstLickTimings = getEventTimes(expRef,'lickDetector'); %chagne event time file name when updated main func
                    [data.lickTimePostStim] = firstLickTimings(1:numTrials,1);
                    [data.lickTimePostReward] = firstLickTimings(1:numTrials,2);
                catch 
                end
                % Look for stimulusDelay and feedbackDelay
                try
                    stimulusOffsetJitter = blockFile.events.stimulusDelayValues(1:numTrials)';
                    [data.stimulusOffsetJitter] = stimulusOffsetJitter(:);
                    rewardJitter = blockFile.events.feedbackDelayValues(1:numTrials)';
                    [data.rewardJitter] = rewardJitter(:);
                catch 
                end

                %laser
                if isfield(blockFile.events,'laserTTLmodeValues')  && ~isempty(blockFile.events.laserTTLmodeValues) && any(blockFile.events.laserTTLmodeValues(1,:)>0)
                    laserTTLmode = blockFile.events.laserTTLmodeValues(:,1:numTrials)';
                    data.laserMode = categorical(laserTTLmode(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','OutcomeFixedDuration'});
                    data.laserOnsetTime = nan(numTrials,1);
                    data.laserOffsetTime = nan(numTrials,1);
                 
                    %Get laser onset and offset times from blockfile
                    laserOnsetTimes = blockFile.outputs.laserTTLTimes(blockFile.outputs.laserTTLValues==1)';
                    laserOnsetTimes( laserOnsetTimes > blockFile.events.endTrialTimes(numTrials) ) = []; %remove any laser onsets after last trial
                    laserOffTimes = blockFile.outputs.laserTTLTimes(blockFile.outputs.laserTTLValues==0)';
                    [~,idx]=max(laserOnsetTimes < laserOffTimes',[],2);
                    laserOffsetTimes = laserOffTimes(idx);
                    data.laserOnsetTime( laserTTLmode(:,1)>0 ) = laserOnsetTimes;
                    data.laserOffsetTime( laserTTLmode(:,1)>0 ) = laserOffsetTimes;
                end
                
                
             case 'IntertemporalPavlov'
                %Stim onset
                data.stimulusOnsetTime = nan(height(data),1);
                photoDiodeOnsetTimes = getEventTimes(expRef,'photodiode');
                expectedStimOnsetTimes = blockFile.events.stimulusOnTimes';
                expectedStimOnsetTimes(expectedStimOnsetTimes > blockFile.events.endTrialTimes(numTrials)) = [];
                data.stimulusOnsetTime(gratingStimuliEvents) = getStimOnsetTimes(photoDiodeOnsetTimes, expectedStimOnsetTimes, [-0.1 0.3]);
                
                %reward time and volume
                expectedFeedbackTime = blockFile.events.newTrialTimes(1:numTrials)';
                valveOpenTimes = getEventTimes(expRef,'reward_echo');
                valveOpenVolumes = blockFile.outputs.rewardValues';
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 4]);
               
                data.parameter_reward_onset = [blockFile.paramsValues.rewardOnsetTime]';
                data.parameter_reward_volume = [blockFile.paramsValues.rewardMagnitude]';
                data.trial_duration = [blockFile.paramsValues.trialDuration]';
                data.stimulus_type = [blockFile.paramsValues.stimulusType]';
                data.intertrial_delay = [blockFile.paramsValues.interTrialDelay]';
                data.stimulus_duration = [blockFile.paramsValues.stimulusDuration]';
                data.trial_duration = [blockFile.paramsValues.trialDuration]';
        end
        
    case {'Value2AFC','Value2AFC_noTimeline','ReportOpto', 'Value2AFC_BehOpto', 'Value2AFC_BehOpto_noTimeline', 'Value2AFC_Pavlov', 'Value2AFC_Pavlov_noTimeline'}
        
        numTrials = length(blockFile.events.endTrialTimes);
        
        data.trialNumber = (1:numTrials)';
        data.repeatNumber = blockFile.events.repeatNumValues(1:numTrials)';
        
        %Stimulus conditions
        %0=nothing, 1=vert grating, 2=horz grating, 3=circle, 4=cross
        leftStimType = blockFile.events.leftStimTypeValues(1:numTrials)';
        data.stimulusLeft = categorical(leftStimType,[0,1,2,3,4,5, 6, 7, 9, 10],{'None','VertGrating','HorzGrating','Circle','Cross', 'CenterGrating', 'CenterCross', 'CenterCircle', 'CenterVertBar', 'CenterDiamond'});
        data.stimulusLeftPayoff = blockFile.events.leftStimRewardValues(:,1:numTrials)';
        rightStimType = blockFile.events.rightStimTypeValues(1:numTrials)';
        data.stimulusRight = categorical(rightStimType,[0,1,2,3,4,5, 6, 7, 9, 10],{'None','VertGrating','HorzGrating','Circle','Cross','CenterGrating', 'CenterCross', 'CenterCircle', 'CenterVertBar', 'CenterDiamond'});
        data.stimulusRightPayoff = blockFile.events.rightStimRewardValues(:,1:numTrials)';

        %choice
        data.choice = categorical( blockFile.events.choiceValues(1:numTrials)', [-1 1 0], {'Left','Right','NoGo'});
        data.choiceCompleteTime = blockFile.events.responseMadeTimes(1:numTrials)';
        data.choiceStartTime = getEstimatedChoiceStartTimes(blockFile.inputs.wheelMMValues, blockFile.inputs.wheelMMTimes, data.choiceCompleteTime, data.choice, blockFile.events.stimulusOnTimes(1:numTrials)');
        
        switch(dataProfile)
            case 'Value2AFC'                
                %Stimulus onset
                stimOnTimes = getEventTimes(expRef,'photodiode');
                data.stimulusOnsetTime = stimOnTimes(1:numTrials);
                
                %go cue
                expectedTimes = blockFile.events.interactiveOnTimes(1:numTrials)';
                data.goCueTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedTimes);
                
                %Reward outcome (with timeline)
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = getEventTimes(expRef,'reward_echo');
                valveOpenVolumes = blockFile.outputs.rewardValues';
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                
                %Reward beep
                data.rewardBeepFreq = blockFile.events.rewardBeepFrequencyValues(1:numTrials)';
                data.rewardBeepFreq( isnan(data.rewardVolume) ) = NaN;
                data.rewardBeepOnsetTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedFeedbackTime);
                data.rewardBeepOnsetTime(isnan(data.rewardVolume) ) = NaN;
                
                %Punish sound
                madeBestChoice = blockFile.events.madeBestChoiceValues(1:numTrials)';
                punishNoiseAmp = [blockFile.paramsValues(1:numTrials).punishNoiseAmp]';
                data.punishSoundOnsetTime = nan(numTrials,1);
                punish_idx = madeBestChoice==0 & punishNoiseAmp>0;
                if sum(punish_idx)>0
                    data.punishSoundOnsetTime(punish_idx) = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedFeedbackTime(punish_idx));
                end
            
            case 'ReportOpto'                
                %laser onset
                laserOnsetTime = getEventTimes(expRef,'laser_echo');
                data.laserOnsetTime = laserOnsetTime(1:numTrials);
                
                %Reward outcome (with timeline)
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = getEventTimes(expRef,'reward_echo');
                valveOpenVolumes = blockFile.outputs.rewardValues';
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                
                %Reward beep
                %data.rewardBeepFreq = blockFile.events.rewardBeepFrequencyValues(1:numTrials)';
                %data.rewardBeepFreq( isnan(data.rewardVolume) ) = NaN;
                %data.rewardBeepOnsetTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedFeedbackTime);
                %data.rewardBeepOnsetTime(isnan(data.rewardVolume) ) = NaN;
                

            case 'Value2AFC_noTimeline'
                %Stimulus onset
                data.stimulusOnsetTime = blockFile.events.stimulusOnTimes(1:numTrials)';
                
                %Go cue
                data.goCueTime = blockFile.events.interactiveOnTimes(1:numTrials)';                
                
                %Reward outcome (no timeline)
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = blockFile.outputs.rewardTimes;
                valveOpenVolumes = blockFile.outputs.rewardValues;
                valveOpenTimes = valveOpenTimes(valveOpenVolumes>0);
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                
                %Reward beep
                data.rewardBeepFreq = blockFile.events.rewardBeepFrequencyValues(1:numTrials)';
                data.rewardBeepFreq(data.rewardVolume==0) = NaN;
                data.rewardBeepOnsetTime = blockFile.events.feedbackTimes(1:numTrials)';
                data.rewardBeepOnsetTime(data.rewardVolume==0) = NaN;
                
                %Punish outcome, if punish enabled
                madeBestChoice = blockFile.events.madeBestChoiceValues(1:numTrials)';
                punishNoiseAmp = [blockFile.paramsValues(1:numTrials).punishNoiseAmp]';
                data.punishSoundOnsetTime = nan(numTrials,1);
                data.punishSoundOnsetTime(madeBestChoice==0 & punishNoiseAmp>0) = expectedFeedbackTime(madeBestChoice==0 & punishNoiseAmp>0);

            case 'Value2AFC_Pavlov'
                %Stimulus onset
                stimOnTimes = getEventTimes(expRef,'photodiode');
                data.stimulusOnsetTime = stimOnTimes(1:numTrials);
                
                %go cue
                expectedTimes = blockFile.events.interactiveOnTimes(1:numTrials)';
                data.goCueTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedTimes);
                
                %Reward outcome (with timeline)
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = getEventTimes(expRef,'reward_echo');
                valveOpenVolumes = blockFile.outputs.rewardValues';
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                
                %Reward beep
                data.rewardBeepFreq = blockFile.events.rewardBeepFrequencyValues(1:numTrials)';
                data.rewardBeepFreq( isnan(data.rewardVolume) ) = NaN;
                data.rewardBeepOnsetTime = getEventTimes(expRef,'sound_echo','KnownSoundTimes',expectedFeedbackTime);
                data.rewardBeepOnsetTime(isnan(data.rewardVolume) ) = NaN;
                
               
                %Punish sound
                punishNoiseAmp = [blockFile.paramsValues(1:numTrials).punishNoiseAmp]';
                data.punishSoundOnsetTime = nan(numTrials,1);
                data.punishSoundOnsetTime(punishNoiseAmp>0 & isnan(data.rewardVolume)) = expectedFeedbackTime(punishNoiseAmp>0 & isnan(data.rewardVolume));

                %add info on which ones are the pavlov Trials
                pavlovTrials = blockFile.paramsValues(1).pavlovTrials;
                data.TrialType = cell(height(data),1);

                data.TrialType(1:pavlovTrials,1) = {'Pavlov'};
                data.TrialType(pavlovTrials+1:end,1) = {'Instrumental'};
                data.TrialType = categorical(data.TrialType);

                data.trialNumber2 = (1:numTrials)';
                data.trialNumber = NaN(height(data),1);
                data.trialNumber(1:pavlovTrials,1) = 1:pavlovTrials;
                data.trialNumber(pavlovTrials+1:end) = 1:height(data)-pavlovTrials;
        

            case 'Value2AFC_Pavlov_noTimeline'
                %Stimulus onset
                data.stimulusOnsetTime = blockFile.events.stimulusOnTimes(1:numTrials)';

                %Go cue
                data.goCueTime = blockFile.events.interactiveOnTimes(1:numTrials)';                
                
                %Reward outcome (no timeline)
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = blockFile.outputs.rewardTimes;
                valveOpenVolumes = blockFile.outputs.rewardValues;
                valveOpenTimes = valveOpenTimes(valveOpenVolumes>0);
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                
                %Reward beep
                data.rewardBeepFreq = blockFile.events.rewardBeepFrequencyValues(1:numTrials)';
                data.rewardBeepFreq(data.rewardVolume==0) = NaN;
                data.rewardBeepOnsetTime = blockFile.events.feedbackTimes(1:numTrials)';
                data.rewardBeepOnsetTime(data.rewardVolume==0) = NaN;
                
                %Punish outcome, if punish enabled
                punishNoiseAmp = [blockFile.paramsValues(1:numTrials).punishNoiseAmp]';
                data.punishSoundOnsetTime = nan(numTrials,1);
                data.punishSoundOnsetTime(punishNoiseAmp>0 & isnan(data.rewardVolume)) = expectedFeedbackTime(punishNoiseAmp>0 & isnan(data.rewardVolume));

                %add info on which ones are the pavlov Trials
                pavlovTrials = blockFile.paramsValues(1).pavlovTrials;
                data.TrialType = cell(height(data),1);

                data.TrialType(1:pavlovTrials,1) = {'Pavlov'};
                data.TrialType(pavlovTrials+1:end,1) = {'Instrumental'};
                data.TrialType = categorical(data.TrialType);

                data.trialNumber2 = (1:numTrials)';
                data.trialNumber = NaN(height(data),1);
                data.trialNumber(1:pavlovTrials,1) = 1:pavlovTrials;
                data.trialNumber(pavlovTrials+1:end) = 1:height(data)-pavlovTrials;


            
            case 'Value2AFC_BehOpto'
                %Stimulus onset
                data.stimulusOnsetTime = blockFile.events.stimulusOnTimes(1:numTrials)';
                
                %Go cue
                data.goCueTime = blockFile.events.interactiveOnTimes(1:numTrials)';                
                
                %Reward outcome (no timeline)
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = blockFile.outputs.rewardTimes;
                valveOpenVolumes = blockFile.outputs.rewardValues;
                valveOpenTimes = valveOpenTimes(valveOpenVolumes>0);
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                
                %Reward beep
                data.rewardBeepFreq = blockFile.events.rewardBeepFrequencyValues(1:numTrials)';
                data.rewardBeepFreq(data.rewardVolume==0) = NaN;
                data.rewardBeepOnsetTime = blockFile.events.feedbackTimes(1:numTrials)';
                data.rewardBeepOnsetTime(data.rewardVolume==0) = NaN;
                
                % Punish outcome, if punish enabled
%                 madeBestChoice = blockFile.events.madeBestChoiceValues(1:numTrials)';
%                 punishNoiseAmp = [blockFile.paramsValues(1:numTrials).punishNoiseAmp]';
%                 data.punishSoundOnsetTime = nan(numTrials,1);
%                 data.punishSoundOnsetTime(madeBestChoice==0 & punishNoiseAmp>0) = expectedFeedbackTime(madeBestChoice==0 & punishNoiseAmp>0);

                if isfield(blockFile.events,'laserTTLmodeRightValues') && ~isempty(blockFile.events.laserTTLmodeRightValues) && any(blockFile.events.laserTTLmodeRightValues(1,:)>0 | blockFile.events.laserTTLmodeLeftValues(1,:)>0)
                    laserTTLmodeRight = blockFile.events.laserTTLmodeRightValues(1,1:numTrials)';
                    laserTTLmodeLeft = blockFile.events.laserTTLmodeLeftValues(1,1:numTrials)';
                    data.laserModeRight = categorical(laserTTLmodeRight(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','RewardFixedDuration'});
                    data.laserModeLeft = categorical(laserTTLmodeLeft(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','RewardFixedDuration'});
                    data.laserModeRight(data.laserModeRight == 'RewardFixedDuration' & (data.choice=='Left' |data.choice=='NoGo') ) = 'Off';
                    data.laserModeLeft(data.laserModeLeft == 'RewardFixedDuration' & (data.choice=='Right' |data.choice=='NoGo')) = 'Off';
                    data.laserDurationRight = blockFile.events.laserTTLmodeRightValues(2,1:numTrials)';
                    data.laserDurationLeft = blockFile.events.laserTTLmodeLeftValues(2,1:numTrials)';
                    
                    data.laserOnsetTime = nan(numTrials,1);
                    data.laserOffsetTime = nan(numTrials,1);
                    
                    % we have this, because the actual duration of the
                    % laser is different from that specified in the mc
                    % settings if the specified duration is less than ~0.4
                    data.laserDurationActual = nan(numTrials, 1);
                    
                    %Get laser onset and offset times from Timeline
                    laserTimes = getEventTimes(expRef,'laser_echo');
                    
                    %Iterate through each trial and get the time of the
                    %laser onset and laser offset
                    trialStartTimes = blockFile.events.newTrialTimes(1:numTrials)';
                    trialEndTimes = blockFile.events.endTrialTimes(1:numTrials)';
                    for tr = 1:height(data)
                        if (data.laserModeRight(tr) ~= 'Off') || (data.laserModeLeft(tr) ~= 'Off')
                            idx = find(laserTimes(:,1) > trialStartTimes(tr),1,'first');
                            
                            if ~isempty(idx)
                                data.laserOnsetTime(tr) = laserTimes(idx,1); %Onset as the first laser onset time in the trial
                            idx = find(laserTimes(:,2) < trialEndTimes(tr),1,'last');
                            data.laserOffsetTime(tr) = laserTimes(idx,2); %Offset as the last laser offset time in the trial
                            else 
                                data.laserOnsetTime(tr) = NaN;
                                data.laserOffsetTime(tr) = NaN;
                                data.laserModeRight(tr) = 'Off';
                                data.laserModeLeft(tr) = 'Off';
                                warning('Expected laser echo was not detected for LaserOffsetTime trial %d. Setting trial as a laser off trial. If this happens for many trials, something is wrong', tr);
                            end
                            
                            data.laserDurationActual(tr) = data.laserOffsetTime(tr) - data.laserOnsetTime(tr);
                            
                            %Occasionally, the laser echo is not properly
                            %detected for a given trial. This makes the
                            %onset time invalid for those trials. The code
                            %relabels these as laser off trials because
                            %it's not clear that the laser was actually on.
                            if ~(trialStartTimes(tr) < data.laserOnsetTime(tr) && data.laserOnsetTime(tr) < trialEndTimes(tr) )
                                warning('Expected laser echo was not detected for trial %d. Setting trial as a laser off trial. If this happens for many trials, something is wrong', tr);
                                data.laserOnsetTime(tr) = nan;
                                data.laserOffsetTime(tr) = nan;
                                data.laserModeRight(tr) = 'Off';
                                data.laserModeLeft(tr) = 'Off';

                            end
                        end
                    end

                end
                        

        case 'Value2AFC_BehOpto_noTimeline'
                
                data.stimulusOnsetTime = blockFile.events.stimulusOnTimes(1:numTrials)';
                
                %Go cue
                data.goCueTime = blockFile.events.interactiveOnTimes(1:numTrials)';                
                
                %Reward outcome (no timeline)
                expectedFeedbackTime = blockFile.events.feedbackTimes(1:numTrials)';
                valveOpenTimes = blockFile.outputs.rewardTimes;
                valveOpenVolumes = blockFile.outputs.rewardValues;
                valveOpenTimes = valveOpenTimes(valveOpenVolumes>0);
                valveOpenVolumes = valveOpenVolumes(valveOpenVolumes>0);
                [data.rewardTime,data.rewardVolume] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedFeedbackTime, [0 1]);
                
                %Reward beep
                data.rewardBeepFreq = blockFile.events.rewardBeepFrequencyValues(1:numTrials)';
                data.rewardBeepFreq(data.rewardVolume==0) = NaN;
                data.rewardBeepOnsetTime = blockFile.events.feedbackTimes(1:numTrials)';
                data.rewardBeepOnsetTime(data.rewardVolume==0) = NaN;

                % Punish outcome, if punish enabled
                madeBestChoice = blockFile.events.madeBestChoiceValues(1:numTrials)';
                punishNoiseAmp = [blockFile.paramsValues(1:numTrials).punishNoiseAmp]';
                data.punishSoundOnsetTime = nan(numTrials,1);
                data.punishSoundOnsetTime(madeBestChoice==0 & punishNoiseAmp>0) = expectedFeedbackTime(madeBestChoice==0 & punishNoiseAmp>0);

                if isfield(blockFile.events,'laserTTLmodeRightValues') && ~isempty(blockFile.events.laserTTLmodeRightValues) && any(blockFile.events.laserTTLmodeRightValues(1,:)>0 | blockFile.events.laserTTLmodeLeftValues(1,:)>0)
                    laserTTLmodeRight = blockFile.events.laserTTLmodeRightValues(1,1:numTrials)';
                    laserTTLmodeLeft = blockFile.events.laserTTLmodeLeftValues(1,1:numTrials)';
                    data.laserModeRight = categorical(laserTTLmodeRight(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','RewardFixedDuration'});
                    data.laserModeLeft = categorical(laserTTLmodeLeft(:,1),[0,1,2,3],{'Off','StimFixedDuration','StimOnToOff','RewardFixedDuration'});
                    data.laserModeRight(data.laserModeRight == 'RewardFixedDuration' & (data.choice=='Left' |data.choice=='NoGo') ) = 'Off';
                    data.laserModeLeft(data.laserModeLeft == 'RewardFixedDuration' & (data.choice=='Right' |data.choice=='NoGo')) = 'Off';
                    data.laserDurationRight = blockFile.events.laserTTLmodeRightValues(2,1:numTrials)';
                    data.laserDurationLeft = blockFile.events.laserTTLmodeLeftValues(2,1:numTrials)';
                    data.laserOnsetTime = nan(numTrials,1);
                    data.laserOffsetTime = nan(numTrials,1);
                 
%                     %Get laser onset and offset times from blockfile
                    laserOnsetTimes = blockFile.outputs.laserTTLTimes(blockFile.outputs.laserTTLValues==1)';
                    laserOnsetTimes( laserOnsetTimes > blockFile.events.endTrialTimes(numTrials) ) = []; %remove any laser onsets after last trial
                    laserOffTimes = blockFile.outputs.laserTTLTimes(blockFile.outputs.laserTTLValues==0)';
                    [~,idx]=max(laserOnsetTimes < laserOffTimes',[],2);
                    laserOffsetTimes = laserOffTimes(idx);
                    data.laserOnsetTime( data.laserModeRight ~= 'Off'| data.laserModeLeft ~= 'Off') = laserOnsetTimes;
                    data.laserOffsetTime( data.laserModeRight ~= 'Off'| data.laserModeLeft ~= 'Off') = laserOffsetTimes;
                 
                  else disp('error with laser Right/Left')
                  end                         
                
        end
        
        
                 
    case {'PhotoTagging'}
        
        numTrials = length(blockFile.events.endTrialTimes);
        
        data.trialNumber = (1:numTrials)';
        
        switch(dataProfile)
            
            case 'PhotoTagging'                
                %Stimulus onset
             
                laserTrials = find(blockFile.events.laserTTLValues(1:numTrials) ==1);
                laserTime = getEventTimes(expRef, 'laser_echo');      
%                 data.laserPulseOnset(laserTrials) = laserTime(1:5:end,1)';
%                 data.laserPulseOffset(laserTrials) = laserTime(5:5:end,2)';
                data.laserPulseOnsetTime(laserTrials) = laserTime(:,1)';
                data.laserPulseOffsetTime(laserTrials) = laserTime(:,2)';
                data.laserPulseOnsetTime((data.laserPulseOnsetTime == 0)) = NaN;
                data.laserPulseOffsetTime((data.laserPulseOffsetTime == 0)) = NaN;
%           
                %Reward outcome
                
                rewardTrials = find(blockFile.outputs.rewardValues(1:numTrials) ==1);
                data.rewardVolume = blockFile.outputs.rewardValues(1:numTrials)';
                data.rewardVolume(data.rewardVolume == 0) = NaN;
                rewardTime = getEventTimes(expRef, 'reward_echo');
                data.rewardTime(rewardTrials) = rewardTime(:)';
                data.rewardTime(data.rewardTime == 0) = NaN;
                
              
        end 
        
    otherwise
        error('dataProfile %s does not exist',dataProfile);
end

end

function choiceStartTimes = getEstimatedChoiceStartTimes(wheelPos, wheelT, choiceCompleteTime, choice, earliestChoiceTime)
%This function uses the wheel trace to try to identify the time when the
%choice movement started. Using the known choiceCompleteTimes, the code
%runs back through time to find the time when the wheel first moved in the
%direction corresponding to the choice for that trial.

%resample to ensure dropped frames aren't a problem
fs = median(diff(wheelT));
wheelTNew = 0:fs:wheelT(end);
wheelPosNew = interp1(wheelT, wheelPos, wheelTNew);
wheelPos = wheelPosNew;
wheelT = wheelTNew;

numTrials = length(choice);
choiceStartTimes = nan(numTrials,1);

for n = 1:numTrials
    if choice(n) ~= 'NoGo'
        %Get wheel data prior to the choiceCompleteTime
        moveWindowEnd = choiceCompleteTime(n);
        moveWindowStart = moveWindowEnd-0.25; %250 ms prior to response made
        if moveWindowStart < earliestChoiceTime(n) %earliest choice is stimulusOnTimes when the stimulus comes ON
            moveWindowStart = earliestChoiceTime(n);
        end
        time_idx = moveWindowStart <= wheelT & wheelT <= moveWindowEnd;
        thisPos = wheelPos(time_idx);
        thisT = wheelT(time_idx);
        
        if ~isempty(thisPos)
            %Scale position values to a standard range
            thisPos = thisPos - thisPos(end); %zero at choice made
            thisPos = abs(thisPos);
            thisPos = thisPos/max(thisPos);
            
            %Specify time when wheel pos is beyond a particular threshold
            choiceStartTimes(n) = thisT( find(thisPos < 0.75,1,'first') );
        end
    end
end

end

function stimTimes = getStimOnsetTimes(photoDiodeOnsetTimes, expectedStimulusTimes, window)
%This function returns the onset time of the photodiode flip after each
%stimulus event (in a window)

stimTimes = nan(size(expectedStimulusTimes));
for i = 1:length(expectedStimulusTimes)
    windowStart = expectedStimulusTimes(i) + window(1);
    windowEnd = expectedStimulusTimes(i) + window(2);
    
    idx = find(windowStart < photoDiodeOnsetTimes & photoDiodeOnsetTimes < windowEnd,1,'first');
    if ~isempty(idx)
        stimTimes(i) = photoDiodeOnsetTimes(idx);
    end
end

end

function [rewardTimes,rewardVolumes] = getRewardTimes(valveOpenTimes,valveOpenVolumes,expectedRewardTime, window)
%During a behavioural session, rewards can be given either from the mouse
%completing a task, or from a keypress. This can cause a mismatch in the
%number of trials and number of total rewards given. This code goes through
%each expectedRewardTime and extracts the valve open time and valve open
%volume corresponding to that event.

rewardTimes = nan(size(expectedRewardTime));
rewardVolumes = nan(size(expectedRewardTime));
for n = 1:length(expectedRewardTime)
    windowStart = expectedRewardTime(n) + window(1);
    windowEnd = expectedRewardTime(n) + window(2);
    
    idx = find(windowStart < valveOpenTimes & valveOpenTimes < windowEnd,1,'first');
    if ~isempty(idx)
        rewardTimes(n) = valveOpenTimes(idx);
        rewardVolumes(n) = valveOpenVolumes(idx);
    end
end
end