function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if s.version.number < 2
    if isfield(s,'Lattice')||isprop(s,'Lattice')
        this.Lattice = s.Lattice;
    end
else
    if isfield(s,'reflattice')||isprop(s,'reflattice')
        this.Lattice = s.reflattice;
    end
end

% [EOF]
