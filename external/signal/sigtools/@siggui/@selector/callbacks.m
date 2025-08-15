function cbs = callbacks(hSct)
%CALLBACKS Callbacks for the Selector object

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

% This can be a private method

cbs.radio = @radio_cb;
cbs.popup = @popup_cb;

% ---------------------------------------------------------
function radio_cb(hcbo, eventStruct, hSct)

h = get(hSct, 'Handles');

set(setdiff(h.radio, hcbo), 'Value', 0);
set(hcbo, 'Value', 1);

tag  = get(hcbo, 'Tag');

% Set the selection to the tag of the radio button
set(hSct, 'selection', tag);

% ---------------------------------------------------------
function popup_cb(hcbo, eventStruct, hSct)

tag  = get(hcbo, 'Tag');
tags = get(hcbo, 'UserData');
indx = get(hcbo, 'Value');

h = get(hSct, 'Handles');

hon = findobj(h.radio, 'tag', tag);
set(setdiff(h.radio, hon), 'Value', 0);
set(hon, 'Value', 1);

% Set the selection to the tag of the popup
set(hSct, 'Selection', tag);

% Set the subselection to the indexed userdata tags
set(hSct, 'SubSelection', tags{indx});

% [EOF]
