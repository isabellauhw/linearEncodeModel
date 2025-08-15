function text_listener(h, eventData)
%TEXT_LISTENER  Listen to the text property of the object and update the UI as necessary

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% Get the text to be set and set it to the ui
Text = get(h, 'Text');
handles = get(h, 'Handles');
set(handles.text,'String',Text);

% [EOF]
