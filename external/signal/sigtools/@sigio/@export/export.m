function hXP = export(data)
%EXPORT Create an Export Object.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(1,1);

hXP = sigio.export;

hXP.Data = data;

set(hXP, 'Version', 1.0);

settag(hXP);

% [EOF]
