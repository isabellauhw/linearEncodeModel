function [props, lbls] = getrenderprops(hObj)
%GETRENDERPROPS   Returns the properties to render.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.

props = {'isminphase', 'stopbandslope'};
lbls  = {'Minimum Phase', 'Stopband Slope (dB)'};

% [EOF]