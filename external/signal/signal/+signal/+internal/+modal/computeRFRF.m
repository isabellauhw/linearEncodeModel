function ofrf = computeRFRF(f,fidx,Res,poles,fm)
%COMPUTERFRF Compute reconstructed frequency response functions.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016-2017 The MathWorks, Inc.

FRFsize = [size(f,1) size(Res,2) size(Res,3)];

% Sythesize an FRF based on estimated residues, Res, and poles.    
ofrf = zeros(FRFsize,'like',Res);
switch lower(fm)
  case 'pp' % set of poles for each frf
    for iFRF = 1:FRFsize(2)*FRFsize(3)
      for iMode = find(~isnan(poles(:,iFRF).'))
      % Find the residues for each mode and each FRF
        ofrf(fidx,iFRF) = ofrf(fidx,iFRF) + Res(iMode,iFRF)./(1i*2*pi*f(fidx) - poles(iMode,iFRF)) + ...
        conj(Res(iMode,iFRF))./(1i*2*pi*f(fidx) - conj(poles(iMode,iFRF))); 
      end
    end
  case {'lsce','lsrf'} % ones set of poles
    for iFRF = 1:FRFsize(2)
      for jFRF = 1:FRFsize(3)
        for iMode = find(~isnan(poles.'))
          ofrf(fidx,iFRF,jFRF) = ofrf(fidx,iFRF,jFRF) + Res(iMode,iFRF,jFRF)./(1i*2*pi*f(fidx) - poles(iMode)) + ...
          conj(Res(iMode,iFRF,jFRF))./(1i*2*pi*f(fidx) - conj(poles(iMode))); 
        end
      end
    end
end

% Set output FRF to NaN outside of frequency range.
ofrf(~fidx,:,:) = nan;