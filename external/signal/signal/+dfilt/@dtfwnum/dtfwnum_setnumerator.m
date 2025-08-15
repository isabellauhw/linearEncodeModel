function num = dtfwnum_setnumerator(Hd, num)
%SETNUMERATOR Overloaded set on the Numerator property.
  
%   Author: V. Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.

num = set_coeffs(Hd, num);

% Check data type and store numerator as reference
if isempty(num)
    error(message('signal:dfilt:schema:Empty')); 
elseif ~isfinite(num)
     error(message('signal:dfilt:schema:MustBeFinite'));
elseif ~isnumeric(num)
    error(message('signal:dfilt:schema:MustBeNumeric'));
end

Hd.refnum = num; 

ncoeffs = Hd.ncoeffs;
oldlength=0;
if ~isempty(ncoeffs), oldlength = ncoeffs(1); end
newlength = length(num);
ncoeffs(1) = newlength;
Hd.ncoeffs = ncoeffs;

if newlength~=oldlength
    reset(Hd);
end

% We need to set the ncoeffs property before calling quantizecoeffs because
% setmaxsum needs this info.
set_ncoeffs(Hd.filterquantizer, newlength);

% Quantize the coefficients
quantizecoeffs(Hd);

% Hold an empty to not duplicate storage
num = [];

