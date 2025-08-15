function dummy = setvariablenames(h, P)
%SETVARIABLENAMES SetFunction for the VariableNames property.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

if isempty(P)
    dummy = [];
    return;
else
    lvh = getcomponent(h, '-class', 'siggui.labelsandvalues');
    set(lvh,'Values',P);
    
    dummy = [];
end

% [EOF]
