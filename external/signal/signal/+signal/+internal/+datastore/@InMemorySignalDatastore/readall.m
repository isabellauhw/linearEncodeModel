function data = readall(obj)
%READALL Reads all members from the datastore
%For internal use only. It may be removed.
%   SIGS = READALL(SDS) reads all of the members from SDS and returns a
%   cell array of signals.

%   Copyright 2019 The MathWorks, Inc.

data = obj.Members;
end
