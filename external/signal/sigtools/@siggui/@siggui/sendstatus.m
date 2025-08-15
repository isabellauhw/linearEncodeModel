function sendstatus(hObj, str)
%SENDSTATUS Send a status from the object
%   SENDSTATUS(H, STR) Send the StatusChanged Notification using STR as the 
%   new status.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(2,2);

statusinfo.StatusString = str;

send(hObj, 'Notification', ...
    sigdatatypes.notificationeventdata(hObj, 'StatusChanged', statusinfo));

% [EOF]
