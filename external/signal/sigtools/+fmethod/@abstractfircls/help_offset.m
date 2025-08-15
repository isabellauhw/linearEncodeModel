function help_offset(this) %#ok<INUSD>
%HELP_OFFSET

%   Copyright 1999-2015 The MathWorks, Inc.

offset_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''PassbandOffset'', PASSBANDOFFSET) specifies the ', ...
    '    passband band gain in dB. PASSBANDOFFSET is 0 dB by default.');
disp(offset_str);
disp(' ');

% [EOF]
