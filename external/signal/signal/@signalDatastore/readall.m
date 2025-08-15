function data = readall(obj)
%READALL Read all signals from the signalDatastore
%   SIGS = READALL(SDS) reads all the signals from signalDatastore and
%   returns them in cell array SIGS.
%
%   % EXAMPLE:
%      % Create a signal datastore and read all its elements
%      data = {randn(100,1); randn(120,3); randn(135,2); randn(100,1);...
%              randn(150,2); randn(155,2); randn(85,10); randn(170,2);...
%              randn(145,3); randn(112,2)};
%      sds = signalDatastore(data,'SampleRate',1000);
%      data = readall(sds)

%   Copyright 2019 The MathWorks, Inc.

data = readall(obj.pDatastoreInternal);
end
