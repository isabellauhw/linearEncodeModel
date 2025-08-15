function help_offset(this)
%HELP_OFFSET

%   Copyright 1999-2015 The MathWorks, Inc.

offset_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''PassbandOffset'', PASSBANDOFFSET) specifies the ', ...
    '    passband gain in dB. PASSBANDOFFSET is a row vector of length 2',...
    '    where the first and the second elements specify the gain values for the first and the second',...
    '    passband respectively. PASSBANDOFFSET is [0 0] by default.');
disp(offset_str);
disp(' ');

% [EOF]
