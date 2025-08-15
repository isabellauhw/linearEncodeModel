function densityfactor = set_densityfactor(this, densityfactor)
%SET_DENSITYFACTOR PreSet function for the 'densityfactor' property.

%   Copyright 1999-2015 The MathWorks, Inc.

if densityfactor == Inf
  error(message('signal:fmethod:abstracteqrip:set_densityfactor:DFNotFinite','DensityFactor'))
end

this.privDensityFactor = densityfactor;

% [EOF]
