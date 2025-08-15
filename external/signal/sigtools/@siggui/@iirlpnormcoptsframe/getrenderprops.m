function [props, lbls] = getrenderprops(hObj)
%GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

[props, lbls] = lpnorm_getrenderprops(hObj);

props = {props{:}, 'maxpoleradius'};
lbls  = {lbls{:}, 'Max Pole Radius'};

% [EOF]
