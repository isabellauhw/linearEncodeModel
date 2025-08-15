function Name = getdynamicname(h, eventData)
%GETDYNAMICNAME  Returns the name of the dynamic prperty

%   Copyright 1988-2002 The MathWorks, Inc.

% Get the handle 
p = get(h, 'Dynamic_Prop_Handles');

% extract name
Name = p.Name;

% [EOF]
