function cbs = callbacks(h) %#ok<INUSD>
%CALLBACKS Callbacks for the Export Dialog

%   Copyright 1988-2011 The MathWorks, Inc.

cbs.exportas = @exportas_cb;
cbs.checkbox = @checkbox_cb;


% --------------------------------------------------------------------
function exportas_cb(hcbo, eventStruct, h) %#ok<*INUSL>

strs = getappdata(hcbo,'PopupStrings'); % get untranslated strings
idx = get(hcbo,'Value'); % get popup index
set(h, 'ExportAs', strs{idx});


% --------------------------------------------------------------------
function checkbox_cb(hcbo, eventStruct, h)

set(h, 'Overwrite', get(hcbo, 'Value'));

% [EOF]
