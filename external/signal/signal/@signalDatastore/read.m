function [data, infoStruct] = read(obj)
%READ Read the next consecutive signal
%   [SIG,INFO] = READ(SDS) returns signal data, SIG, extracted from the
%   datastore, as well as a structure, INFO, containing information about
%   the read signal. INFO contains signal information such as the file
%   name, and the signal time information (if time information was
%   specified). For the case of file data, INFO also contains the variable
%   names that were used to read the signal data and the time data (if this
%   information was specified in the signalDatastore).
%
%   % EXAMPLE:
%      % Create a signal datastore to iterate through the elements of an
%      % in-memory cell array of random matrices. Set sample rate to 1000
%      % Hz.
%      data = {randn(100,1); randn(120,3); randn(135,2); randn(100,1);...
%              randn(150,2); randn(155,2); randn(85,10); randn(170,2);...
%              randn(145,3); randn(112,2)};
%      sds = signalDatastore(data,'SampleRate',1000);
%
%      while hasdata(sds)
%          [data,info] = read(sds);
%      end

%   Copyright 2019 The MathWorks, Inc.

[data, infoStruct] = read(obj.pDatastoreInternal);

for idx = 1:numel(infoStruct)
if obj.pIsReadFcnDefault
    %Append constant time info for the datastore
    if ~isempty(obj.pTimeInformationPropertyName) && obj.pTimeInformationPropertyName == "SampleRate"
        if isscalar(obj.pSampleRate) || ~isfield(infoStruct(idx),'ElementIndex')
            infoStruct(idx).SampleRate = obj.pSampleRate;
        else
            infoStruct(idx).SampleRate = obj.pSampleRate(infoStruct(idx).ElementIndex);
        end
    elseif ~isempty(obj.pTimeInformationPropertyName) && obj.pTimeInformationPropertyName == "SampleTime"
        if isscalar(obj.pSampleTime) || ~isfield(infoStruct(idx),'ElementIndex')
            infoStruct(idx).SampleTime = obj.pSampleTime;
        else
            infoStruct(idx).SampleTime = obj.pSampleTime(infoStruct(idx).ElementIndex);
        end
    elseif ~isempty(obj.pTimeInformationPropertyName) && obj.pTimeInformationPropertyName == "TimeValues"
        if iscell(obj.pTimeValues)
            if numel(obj.pTimeValues) == 1 || ~isfield(infoStruct(idx),'ElementIndex')
                infoStruct(idx).TimeValues = obj.pTimeValues{1};
            else
                infoStruct(idx).TimeValues = obj.pTimeValues{infoStruct(idx).ElementIndex};
            end
        else
            if isvector(obj.pTimeValues) || ~isfield(infoStruct(idx),'ElementIndex')
                infoStruct(idx).TimeValues = obj.pTimeValues;
            else
                infoStruct(idx).TimeValues = obj.pTimeValues(:,infoStruct(idx).ElementIndex);
            end
        end
    end          
end
end

if isfield(infoStruct,'ElementIndex')
    infoStruct = rmfield(infoStruct,'ElementIndex');
end

end