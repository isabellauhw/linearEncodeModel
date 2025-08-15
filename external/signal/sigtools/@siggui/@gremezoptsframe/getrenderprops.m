function [props, lbls] = getrenderprops(hObj)
%GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

[props, lbls] = remez_getrenderprops(hObj);

props = {props{:}, 'phase', 'firtype'};
lbls  = {lbls{:}, 'Phase', 'FIR Type'};

% [EOF]
