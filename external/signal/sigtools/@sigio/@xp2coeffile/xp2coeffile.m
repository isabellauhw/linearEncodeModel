function h = xp2coeffile(data)
%XP2TXTFILE Constructor for the export to coefficient file class.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(1,1);

h = sigio.xp2coeffile;

set(h,'Version',1.0,'Data',data);

settag(h);

% [EOF]
