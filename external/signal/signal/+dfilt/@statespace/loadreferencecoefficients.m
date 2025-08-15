function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if s.version.number < 2
    if (isprop(s,'A') && isprop(s,'B') && isprop(s,'C') && isprop(s,'D')) || ...
            (isfield(s,'A') && isfield(s,'B') && isfield(s,'C') && isfield(s,'D'))
        this.A = s.A;
        this.B = s.B;
        this.C = s.C;
        this.D = s.D;
    end
else
    this.A = s.refA;
    this.B = s.refB;
    this.C = s.refC;
    this.D = s.refD;
end

% [EOF]
