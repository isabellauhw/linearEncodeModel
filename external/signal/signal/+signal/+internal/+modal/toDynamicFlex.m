function FRF = toDynamicFlex(FRF,f,se)
%TODYNAMICFLEX Convert frequency response function to dynamic flexibility.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016 The MathWorks, Inc.

switch lower(se)
  case 'acc' % Accelerance
    factor = -1./((2*pi*f).^2); 
    factor(1) = factor(2);
    FRF = bsxfun(@times,FRF,factor);  
  case 'vel' % Mobility
    factor = 1./((1i*2*pi*f));
    factor(1) = factor(2);
    FRF = bsxfun(@times,FRF,factor);
  case 'dis' % Dynamic Flexibility
    % No op
end