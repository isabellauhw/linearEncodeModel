function str = getstring(h, tag)
%GETSTRING Returns the string at the tag

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

ids = get(h, 'Identifiers');

idx = find(strcmpi(tag, ids));

if isempty(idx)
    str = '';
else
    strs = get(h, 'Strings');
    str  = strs{idx};
end

% [EOF]
