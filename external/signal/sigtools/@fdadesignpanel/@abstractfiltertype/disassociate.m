function disassociate(h)
%DISASSOCIATE Disassociate the specs frame from it's graphical frame.
%   DISASSOCIATE(H) Disassociate the specs frame from it's graphical frame.
%   This will not remove the listeners.  It will only set the handles property
%   to [] thereby rendering the listeners useless.  Calling ASSOCIATE will
%   reattach the handles and reactivate the listeners.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if ~isrendered(h)
    error(message('signal:fdadesignpanel:abstractfiltertype:disassociate:objectNotRendered'));
end

for hindx = allchild(h)
    disconnect(hindx);
end

% [EOF]
