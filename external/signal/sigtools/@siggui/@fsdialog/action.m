function aClose = action(hFs)
%ACTION Perform the action of the fsdialog box

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

% If getfs errors then the user entered an invalid variable.
getfs(hFs);

% Send the NewFs event
send(hFs, 'NewFs', handle.EventData(hFs, 'NewFs'));
aClose = true;

% [EOF]
