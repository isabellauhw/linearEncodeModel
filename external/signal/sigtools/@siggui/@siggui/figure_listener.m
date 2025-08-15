function figure_listener(h, eventData)
%FIGURE_LISTENER Listener for the deletion of the figure

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if isa(h, 'siggui.siggui')
    unrender(h);
end

% [EOF]
