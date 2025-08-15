function sendfiledirty(hObj)
%SENDFILEDIRTY Send the File Dirty notification

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

send(hObj, 'Notification', sigdatatypes.notificationeventdata(hObj, 'FileDirty'));

% [EOF]
