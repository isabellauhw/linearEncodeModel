function s = siggui_getstate(hObj)
%SIGGUI_GETSTATE Get the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

s = get(hObj);

if isrendered(hObj)
    s = rmfield(s, get(find(hObj.RenderedPropHandles, 'Visible', 'On'), 'Name'));
end

% [EOF]
