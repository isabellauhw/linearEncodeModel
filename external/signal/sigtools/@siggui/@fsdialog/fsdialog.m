function hFs = fsdialog(defaultFs)
%FSDIALOG Construct an FsDialog 

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hFs = siggui.fsdialog;

addcomponent(hFs, siggui.fsspecifier);

% If the defaultFs was passed in use it to set the state of the specifier
if nargin == 1
    setstate(getcomponent(hFs, '-class', 'siggui.fsspecifier'), defaultFs);
end

% Set up the defaults
set(hFs, 'Version', 1);

% [EOF]
