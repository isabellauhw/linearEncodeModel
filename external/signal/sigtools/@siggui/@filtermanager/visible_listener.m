function visible_listener(this, eventData)
%VISIBLE_LISTENER   Listener to 'visible'.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

set(this.FigureHandle, 'Visible', this.Visible);

% [EOF]
