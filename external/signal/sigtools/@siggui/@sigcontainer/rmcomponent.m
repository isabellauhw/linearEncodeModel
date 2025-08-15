function rmcomponent(this, h)
%RMCOMPONENT   Remove the component.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

h = h(:)';

for hindx = h
    if ~isa(hindx, 'siggui.siggui')
        warning(message('signal:sigcontainer:ChildMustBeSiggui'));
    else
        disconnect(hindx);
    end
end

% Call a separate method to add the listener to the notification event.
% This will allow subclasses to overload this method.
attachnotificationlistener(this);

% [EOF]
