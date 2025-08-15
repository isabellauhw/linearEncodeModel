function help(hObj)
%HELP Help for the dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

str = get(hObj, 'HelpLocation');

if isempty(str)
    doc signal
else
    helpview(str{:});
end

% [EOF]
