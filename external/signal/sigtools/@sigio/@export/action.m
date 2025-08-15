function aClose = action(this)
%ACTION Perform the action of the export dialog

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.

hCD = get(this,'Destination');
aClose = action(hCD);

if isrendered(this)
    set(this, 'Visible', 'Off');
end

% [EOF]
