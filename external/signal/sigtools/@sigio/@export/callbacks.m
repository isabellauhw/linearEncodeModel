function cbs = callbacks(hXP)
%CALLBACKS Callbacks for the Export Dialog

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

cbs.popup    = @popup_cb; 

% --------------------------------------------------------------------
function popup_cb(hcbo, eventStruct, hXP)

strs = getappdata(hcbo,'PopupStrings'); % get untranslated strings
idx = get(hcbo,'Value'); % get popup index

set(hXP, 'CurrentDestination', strs{idx});

% [EOF]
