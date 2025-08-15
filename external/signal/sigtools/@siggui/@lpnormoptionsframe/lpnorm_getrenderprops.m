function [props, lbls] = lpnorm_getrenderprops(hObj)
%LPNORM_GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

[props, lbls] = remez_getrenderprops(hObj);

props = {props{:}, 'pnormend'};
lbls  = {lbls{:}, 'Pth Norm'};

% [EOF]
