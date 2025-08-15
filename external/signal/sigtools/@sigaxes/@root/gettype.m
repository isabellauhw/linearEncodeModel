function type = gettype(hC)
%GETTYPE Returns the type of the Complex Number

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if length(hC) > 1
    type = 's';
else
    type = '';
end

if isempty(find(hC, '-isa', 'sigaxes.pole'))
    type = ['Zero' type];
elseif isempty(find(hC, '-isa', 'sigaxes.zero'))
    type = ['Pole' type];
else
    type = 'Poles and Zeros';
end


% [EOF]
