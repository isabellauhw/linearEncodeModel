function attachnotificationlistener(hFDA)
%ATTACHNOTIFICATIONLISTENER

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

hChildren = allchild(hFDA);

% Add a listener to a local function.  Creating function handles for
% external MATLAB files is very slow.  Local functions is much faster.
hListener = handle.listener([hFDA; hChildren(:)], 'Notification', @lclnotification_listener);
set(hListener, 'CallbackTarget', hFDA);

if ~isempty(hFDA.FvtoolHandle)
  addlistener(hFDA.FvtoolHandle, 'Notification', @(s,e)lclnotification_listener(s,e));
end

set(hFDA, 'NotificationListener', hListener);

% -----------------------------------------------------------
function lclnotification_listener(hObj, eventData, varargin)

notification_listener(hObj, eventData, varargin{:});

% [EOF]
