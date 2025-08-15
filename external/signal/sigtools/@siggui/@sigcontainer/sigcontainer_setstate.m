function sigcontainer_setstate(hParent, s)
%SETSTATE Set the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

fields = fieldnames(s);

for indx = 1:length(fields)
    hChild = getcomponent(hParent, '-class', ['siggui.' fields{indx}]);
    if ~isempty(hChild)
        setstate(hChild, s.(fields{indx}));
        s = rmfield(s, fields{indx});
    end
end

siggui_setstate(hParent, s);

% [EOF]
