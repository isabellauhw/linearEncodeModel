function [Pxx1, F1, Pxxc] = psdcenterdc(Pxx, F, Pxxc, psdoptions, esttype)
%#codegen
%PSDCENTERDC  Center power and frequency for a given psdoptions structure
%   [PXX, F] = PSDCENTERDC(PXX,F,PSDOPTIONS) centers the power spectrum and
%   frequency vector based upon the Fs, nfft, and range fields in
%   PSDOPTIONS
 
%   Copyright 2014-2019 The MathWorks, Inc.

nFreq = numel(F);
if nFreq == 0
   Pxx1 = Pxx;
   F1 = F;
  return
end

even_nfft = signalwavelet.internal.iseven(psdoptions.nfft);
isonesided = strcmpi(psdoptions.range,'onesided');

if isonesided
  % Undo any x2 scaling of frequencies and confidence interval estimates
  unscaled = isfield(psdoptions,'eigenvals') ...
               || (nargin==5 && any(strcmpi(esttype,{'tfe','tfeh2','mscohere'})));
           
  if even_nfft 
    if ~unscaled 
      % divide all powers by 2 except nyquist and DC
      Pxx(2:end-1,:) = Pxx(2:end-1,:)/2;
      if ~isempty(Pxxc)
        Pxxc(2:end-1,:) = Pxxc(2:end-1,:)/2;
      end
    end
    idx = [nFreq-1:-1:2 1:nFreq];
  else
    if ~unscaled
      % divide all powers by 2 except DC
      Pxx(2:end,:) = Pxx(2:end,:)/2;
      if ~isempty(Pxxc)
        Pxxc(2:end,:) = Pxxc(2:end,:)/2;
      end
    end
    idx = [nFreq:-1:2 1:nFreq];
  end
else
  if even_nfft
    idx = [nFreq/2+2:nFreq 1:nFreq/2+1];
  else
    idx = [(nFreq+1)/2+1:nFreq 1:(nFreq+1)/2];
  end
end

Pxx1 = Pxx(idx,:);
F1 = F(idx);
if ~isempty(Pxxc)
  Pxxc = Pxxc(idx,:);
end

Fs1 = psdoptions.Fs;
if isempty(Fs1) || isnan(Fs1)
  % normalize to 2*pi when default specified.
  Fs = 2*pi;
else
   Fs = Fs1;
end

if isonesided
  F1(1:(end-nFreq)) = -F1(1:(end-nFreq));
elseif even_nfft
  F1(1:nFreq/2-1) = F1(1:nFreq/2-1) - Fs;
else
  F1(1:(nFreq-1)/2) = F1(1:(nFreq-1)/2) - Fs;
end

end
