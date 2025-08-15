function h = xp2txtfile(data)
%XP2TXTFILE Constructor for the export to text-file class..

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(1,1);

h = sigio.xp2txtfile;

set(h,'Version',1.0,'Data',data);

% Set variable labels and names
parse4vec(h);

% Set save file dialog box properties
set(h,'FileName','untitled.txt',...
    'FileExtension','txt',...
    'DialogTitle','Export to a Text-file');

settag(h);

% [EOF]
