function visible_listener(this, eventData)
%VISIBLE_LISTENER Listener to the visible property of the design panel

%   Copyright 1988-2011 The MathWorks, Inc.

visState = get(this, 'Visible');

set([getcomponent(this, '-class', 'siggui.selector', 'Name', 'Response Type') ...
    getcomponent(this, '-class', 'siggui.selector', 'Name', 'Design Method') ...
        this.ActiveComponents], 'Visible', visState);

if isempty(this.CurrentDesignMethod), set(this.Frames, 'Visible', visState); end
        
set(this.Handles.design, 'Visible', visState)
if iscalledbydspblks(this)
  set(this.Handles.inputprocessing_lbl, 'Visible', visState)
  set(this.Handles.inputprocessing_popup, 'Visible', visState)
end
listeners(this, eventData, 'staticresponse_listener'); 

% [EOF]
