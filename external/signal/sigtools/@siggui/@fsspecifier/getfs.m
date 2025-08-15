function fs = getfs(hFs)
%GETFS Returns the Sampling Frequency structure

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

fs = getstate(hFs);

if strcmpi(fs.Units,'normalized (0 to 1)')
    fs.value = [];
else
    fs.value = evaluatevars(fs.Value);
end

fs.units = fs.Units;

fs = rmfield(fs, {'Value', 'Units'});

% [EOF]
