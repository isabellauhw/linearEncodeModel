function sdsOut = shuffle(obj)
%SHUFFLE Shuffle the signals in the signalDatastore
%   SDSOUT = SHUFFLE(SDS) creates a deep copy of the input datastore, SDS,
%   and shuffles the signals using randperm, resulting in the datastore
%   SDSOUT.
%
%   % EXAMPLE:
%       % Create a signalDatastore and a shuffled version
%       data = {randn(100,1); randn(120,3); randn(135,2); randn(100,1);...
%               randn(150,2); randn(155,2); randn(85,10); randn(170,2);...
%               randn(145,3); randn(112,2)};
%       sds = signalDatastore(data,'SampleRate',1000);
%       sdsShuffled = shuffle(sds)

%   Copyright 2019 The MathWorks, Inc.
try
    sdsOut = copy(obj);
    
    [sdsOut.pDatastoreInternal,sIndices] = shuffle(obj.pDatastoreInternal);
    
    % Get correct time values if sample rate, sample time, or time values were
    % specified and were set to vectors or matrices
    if ~isempty(obj.pTimeInformationPropertyName) && obj.pTimeInformationPropertyName == "SampleRate"
        if ~isscalar(obj.pSampleRate)            
            sdsOut.pSampleRate = obj.pSampleRate(sIndices);
        end
    elseif ~isempty(obj.pTimeInformationPropertyName) && obj.pTimeInformationPropertyName == "SampleTime"
        if ~isscalar(obj.pSampleTime)            
            sdsOut.pSampleTime = obj.pSampleTime(sIndices);
        end
    elseif ~isempty(obj.pTimeInformationPropertyName) && obj.pTimeInformationPropertyName == "TimeValues"
        if ~isvector(obj.pTimeValues)            
            sdsOut.pTimeValues = obj.pTimeValues(:,sIndices);
        end
    end
catch e
    throw(e)
end
end