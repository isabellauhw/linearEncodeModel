function coeffs = set_coeffs(this, coeffs)
%SET_COEFFS   PreSet function for the 'coeffs' property.

%   Author(s): R. Losada
%   Copyright 2005-2017 The MathWorks, Inc.

% Always convert to row vector
if ~isempty(coeffs)
    coeffs = coeffs(:).';
end

% Check that coeffs are valid
validate_coeffs(this,coeffs);

% Make sure to clear metadata
clearmetadata(this);

% Set the reference coefficients
this.refallpasscoeffs = coeffs;

oldncoeffs = length(this.AllpassCoefficients);

% Quantize the coefficients
quantizecoeffs(this);

% If number of coeffs changes, flush states
if  oldncoeffs~= length(coeffs)
    reset(this);
end

% Hold an empty to not duplicate storage
coeffs = [];

% [EOF]
