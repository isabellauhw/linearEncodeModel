function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if s.version.number < 2
    if isfield(s,'Gain') ||isprop(s,'Gain')
        if ~isempty(s.Gain)
            this.Gain = s.Gain;
        end
    end
else
    if isfield(s,'refgain')||isprop(s,'refgain')
        if ~isempty(s.refgain)
           this.Gain = s.refgain;
        end
    end
end

% [EOF]
