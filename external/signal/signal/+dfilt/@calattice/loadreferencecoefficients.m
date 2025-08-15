function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if s.version.number < 2
    if isfield(s,'Allpass1')||isprop(s,'Allpass1')
        this.Allpass1 = s.Allpass1;
    end
    if isfield(s,'Allpass2')||isprop(s,'Allpass2')
        this.Allpass2 = s.Allpass2;
    end
    if isfield(s,'Beta')||isprop(s,'Beta')
        this.Beta = s.Beta;
    end
else
    if isfield(s,'refAllpass1')||isprop(s,'refAllpass1')
        this.Allpass1 = s.refAllpass1;
    end
    if isfield(s,'refAllpass2')||isprop(s,'refAllpass2')
        this.Allpass2 = s.refAllpass2;
    end
    if isfield(s,'refBeta')||isprop(s,'refBeta')
        this.Beta = s.refBeta;
    end
end

% [EOF]
