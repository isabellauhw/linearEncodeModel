function datamodel = setprivdata(this, datamodel)
%SETPRIVDATA

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

l = handle.listener(datamodel, 'VectorChanged', @lclvectorchanged_listener);
set(l, 'CallbackTarget', this);
set(this, 'VectorChangedListener', l);

% -------------------------------------------------------------------------
function lclvectorchanged_listener(this, eventData)

if ~isempty(eventData.Source)
    setupdestinations(this);
end

% [EOF]
