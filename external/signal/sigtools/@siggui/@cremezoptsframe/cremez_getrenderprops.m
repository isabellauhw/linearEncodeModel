function [props, lbls] = cremez_getrenderprops(hObj)
%GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

[props, lbls] = remez_getrenderprops(hObj);

props = {props{:}, 'symmetryconstraint', 'secondstageoptimization'};
lbls  = {lbls{:}, 'Symmetry', 'Second-stage optimization'};

% [EOF]
