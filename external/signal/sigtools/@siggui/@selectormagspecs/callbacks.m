function cbs = callbacks(h)
%CALLBACKS  Provides access to the callbacks from within a method

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

cbs.rbc = @rb_call;

%-------------------------------------------------------------------------------
function rb_call(h_source, eventData, h)

AppData = getappdata(h_source);
indx = AppData.Index;

% Set the currentSelection property based on the radio button selected
allOpts = set(h, 'CurrentSelection');

set(h, 'CurrentSelection', allOpts{indx});

% Update the uis as necessary
update_uis(h, indx)

send(h, 'UserModifiedSpecs', handle.EventData(h, 'UserModifiedSpecs'));

% [EOF]
