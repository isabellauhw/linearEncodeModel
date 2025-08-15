function cancel(this)
%CANCEL Perform the cancel operation for the dialog.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

if isrendered(this), set(this, 'Visible', 'Off'); end

setstate(this, get(this, 'PreviousState'));

send(this, 'DialogCancelled', handle.EventData(this, 'DialogCancelled'));

% [EOF]
