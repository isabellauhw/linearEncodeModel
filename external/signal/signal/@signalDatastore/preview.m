function data = preview(obj)
%PREVIEW Read the first signal from the signalDatastore for preview
%   SIG = PREVIEW(SDS) reads the first signal from signalDatastore, SDS,
%   without affecting its state. SIG is a cell array containing the first
%   signal.

%   Copyright 2019 The MathWorks, Inc.

copysds = copy(obj);
reset(copysds);
data = read(copysds);
end