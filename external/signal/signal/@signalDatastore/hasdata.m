function tf = hasdata(obj)
%HASDATA True if there are more signals in the signalDatastore
%   TF = HASDATA(SDS) returns a logical scalar, TF, indicating availability
%   of data.
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

tf = hasdata(obj.pDatastoreInternal);

end
