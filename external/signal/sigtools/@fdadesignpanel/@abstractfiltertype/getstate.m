function s = getstate(hObj)
%GETSTATE Get the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

s = get(hObj);

h = getspecs(hObj);

f = fieldnames(s);

% Keep the Tag and Version
for i = 3:length(f)
    if ~strcmpi(f{i}, h)
        s = rmfield(s, f{i});
    end
end

% [EOF]
