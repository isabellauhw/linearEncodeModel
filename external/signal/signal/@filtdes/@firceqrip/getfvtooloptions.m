function opts = getfvtooloptions(d)
%GETFVTOOLOPTIONS Returns the options sent to FVTool from the design method

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

opts = {'Analysis', 'magnitude'};

if isdb(d)
    opts = {opts{:}, 'MagnitudeDisplay', 'magnitude (db)'};
elseif strcmpi(d.minPhase, 'On')
    opts = {opts{:}, 'MagnitudeDisplay', 'magnitude'};
else
    opts = {opts{:}, 'MagnitudeDisplay', 'zero-phase'};
end

% [EOF]
