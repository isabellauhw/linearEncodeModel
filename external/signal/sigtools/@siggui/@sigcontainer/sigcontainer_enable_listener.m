function sigcontainer_enable_listener(hObj, varargin)
%SIGCONTAINER_ENABLE_LISTENER Perform the work of the enable listener

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Set the enable state of all HG object
siggui_enable_listener(hObj, varargin{:});

hC = allchild(hObj);

for indx = 1:length(hC)
    if isrendered(hC(indx))
        set(hC(indx), 'Enable', hObj.Enable);
    end
end

% [EOF]
