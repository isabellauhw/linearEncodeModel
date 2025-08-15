function drawmasknresp(d, Hd)
%DRAWMASKNRESP Draw the mask and the response

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

HdNew = dfilt.dfiltwfs(Hd, getnyquist(d)*2);

opts = getfvtooloptions(d);
if ~strncmpi(d.frequnits, 'normalized', 10)
    opts = {opts{:}, 'NormalizedFrequency', 'Off'};
end

h = fvtool(HdNew, opts{:}, 'DesignMask', 'On');

% [EOF]
