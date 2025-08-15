function data = preview(obj)
%PREVIEW Read the first member from the datastore for preview
%For internal use only. It may be removed.
%   data = PREVIEW(SDS) always reads the first member from SDS. preview
%   does not affect the state of SDS.

%   Copyright 2019 The MathWorks, Inc.

data = obj.Members{1};
end