function help_zerophase(this) %#ok<INUSD>
%HELP_ZEROPHASE

%   Copyright 1999-2015 The MathWorks, Inc.

offset_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''Zerophase'', ZEROPHASE) designs a filter with a zero-phase response', ...
    '    if ZEROPHASE is true. ZEROPHASE is false by default.');
disp(offset_str);
disp(' ');

% [EOF]
