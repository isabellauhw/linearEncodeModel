function h = handles2vector(this)
%HANDLES2VECTOR Convert the handles structure to a vector

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.

h = get(this,'Handles');

% The "controllers" are now uipanels.
if isfield(h, 'java')
    if isfield(h.java, 'controller')
        h.controller = h.java.controller;
    end
    h = rmfield(h, 'java');
end
    
h = convert2vector(h);

% Remove the non-handles.
h(~ishghandle(h)) = [];

% [EOF]
