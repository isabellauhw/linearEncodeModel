function f = isstable(Hb)
%ISSTABLE True if the filter is stable

%   Copyright 1988-2018 The MathWorks, Inc.

f = base_is(Hb, 'thisisstable');

% [EOF]
