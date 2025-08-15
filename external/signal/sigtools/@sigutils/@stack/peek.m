function data = peek(hStack)
%PEEK Show the last entered data

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% If the stack is empty cannot peek
if isempty(hStack)
    error(message('signal:sigutils:stack:peek:Empty'));
end

% Return the last entry
allData = get(hStack,'Data');
data    = allData{end};

% [EOF]
