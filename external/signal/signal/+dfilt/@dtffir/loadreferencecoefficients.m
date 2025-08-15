function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if s.version.number < 2
    if isfield(s,'Numerator')||isprop(s,'Numerator')
        this.Numerator = s.Numerator;
    end
else
    if isfield(s,'refnum')||isprop(s,'refnum') && ~isempty(s.refnum)
        this.Numerator = s.refnum;
    end
end

% [EOF]
