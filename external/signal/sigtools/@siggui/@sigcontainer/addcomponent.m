function addcomponent(hParent, hChildren)
%ADDCOMPONENT Add a component to the container
%   ADDCOMPONENT(hPARENT, hCHILDREN) Add the objects hCHILDREN to be
%   children of the sigcontainer hPARENT.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

hChildren = hChildren(:)';

for hindx = hChildren
    if ~(isa(hindx, 'siggui.siggui') || isa(hindx, 'siggui.sigguiMCOS'))
        warning(message('signal:sigcontainer:ChildMustBeSiggui'));
    else
        connect(hParent, hindx, 'down');
    end
end

% Call a separate method to add the listener to the notification event.
% This will allow subclasses to overload this method.
attachnotificationlistener(hParent);

% [EOF]
