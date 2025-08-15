function cbs = callbacks(h)
%CALLBACKS Callbacks for the EXPORT2HARDWARE dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

cbs.popup = @popup_cb;
cbs.check = @check_cb;


% ------------------------------------------------------------
function popup_cb(hcbo, eventStruct, h)

set(h, 'ExportMode', updateexportmode(h,get(hcbo,'Value')));


% ------------------------------------------------------------
function check_cb(hcbo, eventStruct, h)

set(h, 'DisableWarnings', get(hcbo, 'Value'));

% [EOF]
