function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if s.version.number < 2
    if (isprop(s,'Lattice') && isprop(s,'Ladder')) || ...
            (isfield(s,'Lattice')&& isfield(s,'Ladder'))
        this.Lattice = s.Lattice;
        this.Ladder = s.Ladder;
    end
else
    this.Lattice = s.reflattice;
    this.Ladder = s.refladder;
end

% [EOF]
