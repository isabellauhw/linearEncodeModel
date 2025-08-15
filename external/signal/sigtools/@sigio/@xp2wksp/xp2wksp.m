function this = xp2wksp(data)
%XP2WKSP Constructor for the export to workspace class.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(1,1);

this = sigio.xp2wksp;
set(this,'Version', 1.0,'Data',data);

abstractxpdestwvars_construct(this);

settag(this);

% [EOF]
