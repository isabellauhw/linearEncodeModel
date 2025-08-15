function cbs = callbacks(hSOS)
%CALLBACKS Callbacks for the SOS Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

cbs.scale     = @scale_cb;
cbs.direction = @direction_cb;

% ---------------------------------------------------------------------
function scale_cb(hcbo, eventStruct, hSOS)

val = popupstr(hcbo);

set(hSOS,'Scale',val);


% ---------------------------------------------------------------------
function direction_cb(hcbo, eventStruct, hSOS)

val = popupstr(hcbo);

set(hSOS,'Direction',val);

% [EOF]
