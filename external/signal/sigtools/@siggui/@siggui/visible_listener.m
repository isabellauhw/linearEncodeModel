function visible_listener(hBase, eventData)
%VISIBLE_LISTENER The listener for the visible property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

% WARNING: This is the superclass listener which will perform a "blind"
% set(h,'visible').  If you want to only certain UIControls to be made visible
% or invisible you must overload this method.  It is recommended that you make
% all UIcontrols invisible when the object is invisible.

siggui_visible_listener(hBase, eventData);

% [EOF]
