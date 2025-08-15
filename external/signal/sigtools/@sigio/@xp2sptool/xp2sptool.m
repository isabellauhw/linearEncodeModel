function this = xp2sptool(data)
%XP2SPTOOL Export to SPTool.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(1,1);

this = sigio.xp2sptool;
set(this,'Version', 1.0,'Data',data);

addcomponent(this,siggui.labelsandvalues('maximum', this.variablecount));

parse4obj(this);

settag(this);

% [EOF]
