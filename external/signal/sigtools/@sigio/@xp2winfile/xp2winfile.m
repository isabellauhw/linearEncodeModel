function h = xp2winfile(data)
%XP2TXTFILE Constructor for the export to window text-file class.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,1);

h = sigio.xp2winfile;

set(h,'Version',1.0,'Data',data);

settag(h);

% [EOF]
