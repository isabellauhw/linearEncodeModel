function [props, lbls] = remez_getrenderprops(hObj)
%REMEZ_GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

props = {'densityfactor'};
lbls  = {getString(message('signal:sigtools:siggui:DensityFactor'))};

% [EOF]
