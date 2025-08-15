function sfds2 = subset(obj,indices)
%SUBSET Create a signalDatastore with a subset of signals
%   SDS2 = SUBSET(SDS,IDXS) returns an signalDatastore, SFD2, with a subset
%   of the signals in SDS specified in indices IDXS. Select files or
%   members from SDS that you want in SDS2 by specifying IDXS as a numeric
%   vector of indices, or a logical vector with true on the locations of
%   the files or members of interest.
%
%   % EXAMPLE:
%       % Create a signalDatastore and a subset containing the first and 
%       % fourth member.
%       data = {randn(100,1); randn(120,3); randn(135,2); randn(100,1);...
%               randn(150,2); randn(155,2); randn(85,10); randn(170,2);...
%               randn(145,3); randn(112,2)};
%       sds = signalDatastore(data,'SampleRate',1000);
%       sdsSubset = subset(sds,[1,4])

%   Copyright 2019 The MathWorks, Inc.

sfds2 = copy(obj);
sfds2.pDatastoreInternal = subset(sfds2.pDatastoreInternal,indices);

% Get correct time values if sample rate, sample time, or time values were
% specified and were set to vectors or matrices
if ~isempty(obj.pTimeInformationPropertyName) && obj.pTimeInformationPropertyName == "SampleRate"
    if ~isscalar(obj.pSampleRate)
        sfds2.pSampleRate = obj.pSampleRate(indices);
    end
elseif ~isempty(obj.pTimeInformationPropertyName) && obj.pTimeInformationPropertyName == "SampleTime"
    if ~isscalar(obj.pSampleTime)
        sfds2.pSampleTime = obj.pSampleTime(indices);
    end
elseif ~isempty(obj.pTimeInformationPropertyName) && obj.pTimeInformationPropertyName == "TimeValues"
    if ~isvector(obj.pTimeValues)
        sfds2.pTimeValues = obj.pTimeValues(:,indices);
    end
end
end