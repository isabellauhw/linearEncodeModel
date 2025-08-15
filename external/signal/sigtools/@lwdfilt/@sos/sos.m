function this = sos(sosMatrix, scales)
%SOS   Construct a SOS object.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

this = lwdfilt.sos;

if nargin > 0
    set(this, 'SOSMatrix', sosMatrix);
    set(this, 'refsosMatrix', sosMatrix);
    if nargin > 1
        set(this, 'ScaleValues', scales);
        set(this, 'refScaleValues', scales);
    end
end

% [EOF]
