function visible_listener(this, eventData)
%VISIBLE_LISTENER   Listener to the visible property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

set(this.FigureHandle, 'Visible', this.Visible);

% [EOF]
