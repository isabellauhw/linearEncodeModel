function setstring(h, tag, newstr)
%SETSTRINGS

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

ids = get(h, 'Identifiers');

idx = find(strcmpi(tag, ids));

if ~isempty(idx)
    strs = get(h, 'Strings');
    strs{idx} = newstr;
    set(h, 'Strings', strs);
end

% [EOF]
