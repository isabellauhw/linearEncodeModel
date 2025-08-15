function cbs = callbacks(hConvert)
%CALLBACKS Callbacks for the HG objects in the Convert Dialog object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

cbs.listbox = @listbox_cb;


% -----------------------------------------------------------
function listbox_cb(hcbo, eventStruct, hConvert)

index  = get(hcbo,'Value');
string = getconvertstructchoices(hConvert);

set(hConvert,'TargetStructure',string{index});

% [EOF]
