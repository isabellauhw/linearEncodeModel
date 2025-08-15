function P = setvariablelabels(h, P)
%SETVARIABLELABELS SetFunction for the VariableLabels property.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

if ~isempty(P)
    lvh = getcomponent(h, '-class', 'siggui.labelsandvalues');
    
    for n = 1:length(P)
        newP{n} = [getTranslatedString('signal:sigtools:sigio',P{n}),':'];
    end
    set(lvh,'Labels',newP);
end

% [EOF]
