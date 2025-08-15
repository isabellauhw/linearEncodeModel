function this = xp2matfile(data)
%XP2MATFILE Constructor for the eport to MAT-file class.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(1,1);

this = sigio.xp2matfile;

set(this,'Version', 1.0,'Data',data);

abstractxpdestwvars_construct(this);

% Set save file dialog box properties
set(this,'FileName','untitled.mat',...
    'FileExtension','mat',...
    'DialogTitle','Export to a MAT-file');

settag(this);

% [EOF]
