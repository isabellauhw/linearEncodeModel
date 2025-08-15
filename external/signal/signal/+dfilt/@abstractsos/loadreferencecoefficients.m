function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if s.version.number < 2
    if isfield(s,'SOSMatrix')||isprop(s,'SOSMatrix')
        this.sosMatrix = s.SOSMatrix;
    end
    
    if isfield(s,'sosMatrix')||isprop(s,'sosMatrix')
        this.sosMatrix = s.sosMatrix;
    end
    
    if isfield(s,'ScaleValues')||isprop(s,'ScaleValues')
        this.ScaleValues = s.ScaleValues;
    end
else
    if isfield(s,'refsosMatrix')||isprop(s,'refsosMatrix')
        this.sosMatrix = s.refsosMatrix;
    end
    if isfield(s,'refScaleValues')||isprop(s,'refScaleValues')
        this.ScaleValues = s.refScaleValues;
    end
end

% [EOF]
