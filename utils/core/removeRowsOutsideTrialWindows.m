function [cleanedMats, zeroRows, trialVec] = removeRowsOutsideTrialWindows(obj, refMat, varargin)
    % removeRowsOutsideTrialWindows Removes rows outside trial time windows.
    %
    % INPUTS:
    %   - *obj*: object containing behavioral data with stimulusOnsetTime and outcomeTime
    %   - *refMat*: reference matrix (same rows as timeVec), used to filter rows
    %   - *varargin*: other matrices to be filtered (must have same row count)
    %
    % OUTPUTS:
    %   - *cleanedMats*: cell array of filtered matrices (no rows outside trial windows)
    %   - *zeroRows*: logical vector indicating rows removed (true = removed)
    %   - *trialVec*: vector labeling each row with trial number (0 = outside any trial)

nTrials = height(obj.bhv);
nTimePoints = length(obj.globalTime);

% Initialize trial vector with zeros (0 means outside trial window)
trialVec = zeros(nTimePoints, 1);
trialCounter = 1;

for t = 1:nTrials
    % Original (continuous) trial boundary times
    rawTStart = obj.bhv.stimulusOnsetTime(t) - obj.preTime;
    rawTEnd   = obj.bhv.outcomeTime(t) + obj.postTime;

    % Find closest indices in timeVec for start and end times
    % Note: although find the closest time by the original onset time,
    % not the time kernel start and end time, since linear encoding
    % model expands the time kernel by the multiple of the sampling
    % rate, e.g., (-0.5s and 2s), it wouldn't cause findClosestTimeIdx
    % to locate a different frame here.
    startIdx = findClosestTimeIdx(obj.globalTime, rawTStart);
    endIdx = findClosestTimeIdx(obj.globalTime, rawTEnd);

    % Mark the trial rows within the window
    trialVec(startIdx:endIdx) = trialCounter;
    trialCounter = trialCounter + 1;
end

% Rows outside any trial have trialVec == 0
zeroRows = (trialVec == 0);

% Remove zero rows from refMat
cleanedRefMat = refMat(~zeroRows, :);

% Remove zero rows from all varargin matrices and store in cleanedMats
cleanedMats = cell(size(varargin));
for i = 1:numel(varargin)
    mat = varargin{i};
    if size(mat, 1) ~= nTimePoints
        error('Matrix %d row count does not match timeVec length.', i);
    end
    cleanedMats{i} = mat(~zeroRows, :);
end

% Also update trialVec to only include remaining rows
trialVec = trialVec(~zeroRows);
end

