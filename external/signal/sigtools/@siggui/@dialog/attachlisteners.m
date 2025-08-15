function attachlisteners(this)
%ATTACHLISTENERS   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

% Install the default listeners
l = [ ...
        this.WhenRenderedListeners(:); ...
        handle.listener(this, this.findprop('isApplied'), ...
        'PropertyPostSet', @isapplied_listener); ...
    ];

set(l(end), 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

isapplied_listener(this);

% [EOF]
