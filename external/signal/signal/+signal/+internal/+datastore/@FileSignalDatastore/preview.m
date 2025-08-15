function data = preview(obj)
%PREVIEW Read the first file from the datastore for preview
%For internal use only. It may be removed.
%   data = PREVIEW(SDS) always reads the first file from SDS. preview does
%   not affect the state of SDS.

%   Copyright 2019 The MathWorks, Inc.

copysds = copy(obj);
reset(copysds);
copysds.PreviewCall = true;
data   = read(copysds);
copysds.PreviewCall = false;
end