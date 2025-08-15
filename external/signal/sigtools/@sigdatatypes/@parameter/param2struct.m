function s = param2struct(hPrm)
%PARAM2STRUCT Convert parameters to a structure
%   PARAM2STRUCT Returns a structure with fieldnames equal to the tags
%   of the input parameters

%    Author(s): J. Schickler
%    Copyright 1988-2017 The MathWorks, Inc.

tags = get(hPrm, 'Tag');
vals = get(hPrm, 'Value');

if ~iscell(tags), tags = {tags}; vals = {vals}; end

for i = 1:length(hPrm)
    valid = get(hPrm(i), 'AllOptions');
    vv    = get(hPrm(i), 'ValidValues');
    if iscellstr(valid) & iscellstr(vv)
        vals{i} = find(strcmpi(vals{i}, valid));
    end
end

s = cell2struct(vals, tags);

% [EOF]
