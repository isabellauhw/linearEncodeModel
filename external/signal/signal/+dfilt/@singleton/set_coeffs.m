function c = set_coeffs(this,c)                                               
%SET_COEFFS Set the coefficients.                                          

%   Author(s): V. Pellissier                                          
%   Copyright 1988-2005 The MathWorks, Inc.


narginchk(2,2);                                                

% Always store as a row                                                    
c = c(:).';                                                                

clearmetadata(this);

% [EOF]
