function reset(obj)
%RESET Reset the signalDatastore to the start of the data
%   reset(SDS) resets signalDatastore SDS. 
%
%   % EXAMPLE:
%       data = {randn(100,1); randn(120,3); randn(135,2); randn(100,1);...
%               randn(150,2); randn(155,2); randn(85,10); randn(170,2);...
%               randn(145,3); randn(112,2)};
%       sds = signalDatastore(data,'SampleRate',1000);
%       read(sds);
%       read(sds);
%       progress(sds)
%       reset(sds);
%       progress(sds)

%   Copyright 2019 The MathWorks, Inc.
try
    reset(obj.pDatastoreInternal);
catch ME
    throw(ME);
end
end
