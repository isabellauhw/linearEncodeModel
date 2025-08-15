function num = setnumerator(Hd,num)
%SETNUMERATOR Overloaded set on the Numerator property.
  
%   Author: V. Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);   

% Always make coeffs a row
num = set_coeffs(Hd, num);

n = length(num);
iseven = (rem(n,2)==0);

if n>1
    % Force coefficients symmetry
    if iseven
        m = n/2;
        num = [num(1:m), num(m:-1:1)];
    else
        m = (n-1)/2;
        num = [num(1:m), num(m+1), num(m:-1:1)];
    end
end

oldlength = Hd.ncoeffs;
newlength = length(num);
Hd.ncoeffs = newlength;

if newlength~=oldlength
    reset(Hd);
end

if isempty(num)
    error(message('signal:dfilt:schema:Empty')); 
elseif ~isfinite(num)
     error(message('signal:dfilt:schema:MustBeFinite'));
end

% Store numerator as reference
Hd.refnum = num;

% We need to set the ncoeffs property before calling quantizecoeffs because
% setmaxsum needs this info.
set_ncoeffs(Hd.filterquantizer, newlength);

% Quantize the coefficients
quantizecoeffs(Hd);

% Hold an empty to not duplicate storage
num = [];
