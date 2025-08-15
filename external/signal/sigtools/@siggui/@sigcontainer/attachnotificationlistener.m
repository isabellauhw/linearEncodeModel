function attachnotificationlistener(hParent)
%ATTACHNOTIFICATIONLISTENER

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

hAllChildren = allchild(hParent);

% Add a listener to a local function.  Creating function handles for
% external MATLAB files is very slow.  Local functions is much faster.
hListener = handle.listener(hAllChildren, 'Notification', @lclnotification_listener);
set(hListener, 'CallbackTarget', hParent);

set(hParent, 'NotificationListener', hListener);

% -----------------------------------------------------------
function lclnotification_listener(hObj, eventData, varargin)

notification_listener(hObj, eventData, varargin{:});

% [EOF]
