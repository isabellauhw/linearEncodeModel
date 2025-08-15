function enable_listener(h,eventData)
%ENABLE_LISTENER Callback for the listener to the enable property.

%   Author(s): R. Losada, Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% This method should be private

% get the enable state
EnabState = get(h, 'Enable');

% Get the handles
handles = get(h, 'Handles');

if strcmp(EnabState, 'off')
    setenableprop(handles2vector(h), 'off');
else
    setenableprop(handles2vector(h), 'on');
    % If ~isMinOrd then the radiobutton for Minimum is disabled
    if ~get(h, 'IsMinOrd')
        setenableprop(handles.rbs(end), 'off');
    else
        % If isMinOrd and mode is Minimum then edit box disabled
        Mode = get(h,'Mode');
        AllModes = set(h, 'Mode');
        if strcmp(Mode, AllModes{2})
            setenableprop(handles.eb, 'off');
        end
    end    
end

% Always leave the frame and it's label enabled on
setenableprop(handles.framewlabel,'on');

% [EOF]
