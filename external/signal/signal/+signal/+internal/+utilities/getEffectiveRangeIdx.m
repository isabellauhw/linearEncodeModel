function [minIdx, maxIdx] = getEffectiveRangeIdx(x, inputRange)
%GETEFFECTIVERANGE get the effective range index given an inputRange
% x              - frequency vector or time vector
% inputRange     - TimeRange [T1 T2] or FrequencyRange [F1 F2]
% minIdx, maxIdx - the index of x corresponding to inputRange 
%   This function is for internal use only. It may be removed. 

%   Copyright 2017-2019 The MathWorks, Inc. 
%#codegen

tolerance = eps(max(x)); 
[err1,idx1] = min(abs(x-inputRange(1)));

if err1 <= tolerance
    minIdx = idx1;
else
    minIdx = find(x>=inputRange(1), 1);
    if isempty(minIdx)
        minIdx = length(x);
    end    
end

minIdx = minIdx(1);
[err2,idx2] = min(abs(x-inputRange(2)));
if err2 <= tolerance
    maxIdx = idx2;
else
    maxIdx = find(x<=inputRange(2), 1, 'last');
    if isempty(maxIdx)
        maxIdx = 1;
    end
end

if minIdx > maxIdx
    [~, minIdxV] = min(abs(x-mean(inputRange)));
    minIdx = minIdxV(1);
    maxIdx = minIdx;
end
maxIdx = maxIdx(1);
end