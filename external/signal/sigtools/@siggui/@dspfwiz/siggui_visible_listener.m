function siggui_visible_listener(hObj, ~)
%SIGGUI_VISIBLE_LISTENER The listener for the visible property
%   Does the actual work

%   Copyright 2011-2016 The MathWorks, Inc.

visState = get(hObj, 'Visible');

updateinputprocrateoptions(hObj);   

set(hObj.Container, 'Visible', visState);
set(hObj.Handles.button, 'Visible', visState)
set(hObj.Handles.inputprocessing_lbl, 'Visible', visState)
set(hObj.Handles.inputprocessing_popup, 'Visible', visState)


if hObj.privShowRateOptionsFlag && strcmpi(visState,'on')
  rateOptsVisState = 'on';
else
  rateOptsVisState = 'off';
end

set(hObj.Handles.rateoptions_lbl, 'Visible', rateOptsVisState)
set(hObj.Handles.rateoptions_popup, 'Visible', rateOptsVisState)

% [EOF]