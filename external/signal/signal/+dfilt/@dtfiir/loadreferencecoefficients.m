function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
if s.version.number <2
    if (isprop(s,'Numerator') && isprop(s,'Denominator')) || ...
            (isfield(s,'Numerator')&& isfield(s,'Denominator'))
        
        this.Numerator = s.Numerator;
        this.Denominator = s.Denominator;
    end
else
    if ~isempty(s.refnum)
        this.Numerator = s.refnum;
    end
    
    if ~isempty(s.refden)
        this.Denominator = s.refden;
    end
    
   
end

% [EOF]
