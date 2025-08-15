function coeffs = getselectedcoeffs(hCoeff)
%GETSELECTEDCOEFFS Returns the coefficients for the selected structure
%   GETSELECTEDCOEFFS Returns the coefficients for the currently selected
%   filter structure.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

shortstruct = getshortstruct(hCoeff,'struct');
all_coeffs  = get(hCoeff,'Coefficients');
coeffs      = getfield(all_coeffs,shortstruct);

% [EOF]
