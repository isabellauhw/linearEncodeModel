function [dataCorrected, variance] = applySubtractionCorrection (data, twoPDir, expRef, makeFig,saveFigName,fRate, override_reward_echoes);

% function dataCorrected = applySubtractionCorrection (twoPDir, expRef);
%
% This function read two signal from two device, and calculate the onset
% delay in two signal and appy it to the behavior data.
%
% ASSUMPTION 1: Both signal is aligned, but there is only onset delay.
% ASSUMPTION 2: Behaviour signal starts later than two photon recording.
% HA 13/07/2023
% ST 11/04/2024

if nargin < 6
    fRate = 20000;
    override_reward_echoes = false;
end

if nargin < 7
    override_reward_echoes = false;
end

%Get reward echo from PAQ file (from text file extracted from PAQ file)

parts = split(expRef, '_');
recordingID = str2double(parts{2}); % Get the recording ID for multiple files
filename = dir(fullfile(twoPDir,['*_reward_frames.txt']));
if isempty(filename)
    error ('No reward frames file found in the directory');
    %filename = dir(fullfile(twoPDir,['*', parts{2},'_reward_frames_*.txt']));
end
disp(fullfile(filename.folder,filename.name));
reward_echo_twoP = dlmread(fullfile(filename.folder,filename.name), '\n')';

%ST: CHANGED /20000 to /fRate, for use across rig types
if isa(fRate, 'double') == 0
    fRate = double(fRate);
end
reward_echo_twoP = reward_echo_twoP/fRate; % in secs.

%Load reward echos from timeline
  % Truncate the reward echo from timeline if paq-io file was prematurely
  % terminated
if override_reward_echoes == false
    b = dat.loadBlock(expRef);
    reward_echo_behav = getEventTimes(expRef,'reward_echo'); % in secs
else
    reward_echo_behav = data.rewardTime(~isnan(data.rewardVolume));
end


% calculate delay between two signal
assert( length(reward_echo_behav)==length(reward_echo_twoP),...
        'Error: %d timeline reward echos but %d twoPhoton reward echos',length(reward_echo_behav),length(reward_echo_twoP));

delay = mean(reward_echo_twoP - reward_echo_behav);
delay_array = ones(size(reward_echo_twoP))*delay;
signal = (reward_echo_twoP - (reward_echo_behav+delay_array))*1000; %to ms.
variance = max(abs(signal));

if variance > 20 %ms
    figure
    dd = histogram(signal, FaceColor= 'k');
    xlabel('Differences in time for each reward event (ms)');
    box off;
    ylabel('Number of reward events');
    title(['Onset delay : ',  num2str(delay), 'second']);
    saveas(gcf,fullfile(saveFigName, 'VarianceBetweenProblematicCorrectedSignals.png'));
    close;

    % Lets plot the problem first
    figure; plot(reward_echo_twoP -reward_echo_behav)
    ylabel('Second differences between reward events (sec)')
    xlabel('Number of events')
    saveas(gcf,fullfile(saveFigName, 'hugeVarianceDetected.png'));
    close;
    % Lets solve the problem: There are some large delay(s) in the signal
    delay_indexes = find(diff(signal)>20);
    delay_indexes = [delay_indexes, length(signal)];
    delay_array = ones(size(reward_echo_twoP));
    t_start = 1;
    for k = 1: length(delay_indexes)
        index = t_start:delay_indexes(k);
        delay = mean(reward_echo_twoP(index) - reward_echo_behav(index));
        delay_array(index) = ones(size(index))*delay;
        t_start     = delay_indexes(k)+1;
    end
    signal = (reward_echo_twoP - (reward_echo_behav+delay_array))*1000; %to ms.
    variance = max(abs(signal));
end
if makeFig
    figure
    dd = histogram(signal, FaceColor= 'k');
    xlabel('Differences in time for each reward event (ms)');
    box off;
    ylabel('Number of reward events');
    title(['Onset delay : ',  num2str(delay), 'second']);
    saveas(gcf,fullfile(saveFigName, 'VarianceBetweenCorrectedSavedSignals.png'));
    %close;
end
% manual reward will cause problem as we dont have their time in the
% behavior data - exclude them first from the delay_array
rewardTime_withOutNans = data.rewardTime(~isnan(data.rewardTime));
if length(rewardTime_withOutNans)~= length(reward_echo_behav)
    % This means there are manual rewards.
    manualRewards = setdiff(reward_echo_behav, rewardTime_withOutNans);
    index_manualRewards = ismember(reward_echo_behav, manualRewards);
    delay_array = delay_array(~index_manualRewards);
end

% Estimate the delay for trials without reward event ( unrewarded trials)
delay_array_full = nan(size(data.rewardTime));
delay_array_full(find(~isnan(data.rewardTime))) = delay_array;
% Interpolate the NaNs using linear interpolation
nan_indices      = isnan(delay_array_full);
known_indices    = find(~nan_indices);% Create an array of indices for the known (non-NaN) data points
known_values     = delay_array_full(~nan_indices); % Create an array of values for the known data points
nan_indices      = find(nan_indices); % Create an array of indices for the NaNs

% Interpolate the NaNs using linear interpolation
estimated_values = interp1(known_indices, known_values, nan_indices, 'linear');

% Sandra's fix for NaN values at first and last trials - 22/03/24
% check that all non-NaN in estimated_values are identical. If not, fill in
% the first and last NaN values with the first and last non-NaN values
% respectively
estimated_NotNan = estimated_values(~isnan(estimated_values));
if all(estimated_NotNan == estimated_NotNan(1))
    estimated_values(isnan(estimated_values)) = estimated_NotNan(1);
    disp("All non-NaN estimated_values found to be the same.")
else
    disp("Not all non-NaN estimated_values are the same.")
    stillnan_indx = find(isnan(estimated_values));
    disp(stillnan_indx);
    i = 1;
    while i < length(stillnan_indx) + 1
        if stillnan_indx(1) ~= 1 %if stillnans are in the back
            disp('All the stillnan_indx are at the end.')
            firstlastidx = stillnan_indx(1);
            estimated_values(firstlastidx:end) = estimated_NotNan(end);
            i = length(stillnan_indx) + 1; %break while loop
        elseif stillnan_indx(1) == 1 %if stillnans start from 1st trial
            disp('The stillnan_indx start from 1st trial.')
            if length(stillnan_indx) == 1 %only 1 stillnan and it's at the beginning
                estimated_values(stillnan_indx) = estimated_NotNan(1);   
                i = length(stillnan_indx) + 1; %break while loop
            elseif stillnan_indx(i) + 1 == stillnan_indx(i+1) %when consecutive stillnan_indices are within 1 of each other
                estimated_values(stillnan_indx) = estimated_NotNan(1);
                i = length(stillnan_indx) + 1; %break while loop
            elseif stillnan_indx(i) + 1 ~= stillnan_indx(i+1) %when consecutive stillnan_indices are no longer within 1 of each other, the 'first' and 'last' sequential NaN values have been found
                lastfirstidx = stillnan_indx(i);
                fprintf('Last first-NaN-value found! %d', lastfirstidx);
                estimated_values(1:lastfirstidx) = estimated_NotNan(1);
                if lastfirstidx ~= stillnan_indx(end) %if there are more stillnans
                    disp('And stillnans are also at the end')
                    firstlastidx = stillnan_indx(i+1);
                    fprintf('First last-NaN-value found! %d', firstlastidx);
                    estimated_values(firstlastidx:end) = estimated_NotNan(end);
                end
                i = length(stillnan_indx) + 1; %break while loop
            end
        end
    end
end

if ~isnan(estimated_values)
    disp('No more NaN values');
end

delay_array_full(nan_indices) = estimated_values; % Replace the NaNs with the estimated values

% ST 08/2024: Add 'delay_array_full' as column to 'data' table and do not
% change the times in data table
data.("trialOffsets") = delay_array_full;
dataCorrected = data;

% % XX--Apply delay in time to behaviour file.--XX ST 08/2024: No longer
% applied, please calculate the appropriate delayed times for PAQ events
% (e.g. imaging) by adding trialOffsets to your event times in
% dataCorrected
% fields = fieldnames(data);
% for f = 1:length(fields)
%     if contains(fields(f),'Time')
%        data.(fields{f}) = data.(fields{f})+ delay_array_full ;
%        %data.(fields{f}) = applyCorrection( data.(fields{f}), behav2probe );
%     end
% end



end
