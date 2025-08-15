function [props, lbls] = getrenderprops(hObj)
%GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

[props, lbls] = cremez_getrenderprops(hObj);

props = {props{:}, 'invSincFreqFactor'};
lbls  = {lbls{:}, 'InvSinc Freq. Factor'};

% [EOF]
