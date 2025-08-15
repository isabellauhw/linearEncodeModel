function cancel(this)
%CANCEL   Close down the dialog with no unwind.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

% Hide the dialog, but not through the object.  This avoids the transaction
% finding the change, but we do not see the "cancel" operation
if isrendered(this), set(this,'Visible','Off'); end

send(this, 'DialogCancelled', handle.EventData(this, 'DialogCancelled'));

% [EOF]
