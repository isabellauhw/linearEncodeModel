function setselectedcoeffs(hCoeff,coeffs)
%SETSELECTEDCOEFFS Sets the coefficients for the selected structure
%   SGETSELECTEDCOEFFS(hCOEFF, COEFFS) sets the coefficients for the 
%   currently selected filter structure to COEFFS.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

shortstruct = getshortstruct(hCoeff,'struct');
all_coeffs  = get(hCoeff,'Coefficients');
all_coeffs  = setfield(all_coeffs,shortstruct,coeffs);

set(hCoeff,'Coefficients',all_coeffs);

% [EOF]
