function varargout = computepsd(Sxx1,w2,range,nfft,Fs,esttype)
%COMPUTEPSD  Compute the one-sided or two-sided PSD or Mean-Square.
%   [Pxx,W,UNITS] = COMPUTEPSD(Sxx,W,RANGE,NFFT,Fs,ESTTYPE) where the
%   inputs and outputs are:
%
%   Inputs:
%    Sxx   - Whole power spectrum [Power]; it can be a vector or a matrix.
%            For matrices the operation is applied to each column.
%    W     - Frequency vector in rad/sample or in Hz.
%    RANGE - Determines if a 'onesided' or a 'twosided' Pxx and Sxx are
%            returned.
%    NFFT  - Number of frequency points.
%    Fs    - Sampling Frequency.
%    ESTTYPE - A string indicating the estimate type: 'psd', or 'ms' value.
%
%   Outputs:
%    Pxx   - One-sided or two-sided PSD or MEAN-SQUARE (not scaled by Fs)
%            depending on the input arguments RANGE and TYPE.
%    W     - Frequency vector 0 to 2*Nyquist or 0 to Nyquist depending on
%            range, units will be either rad/sample (if Fs is empty) or Hz
%            (otherwise).
%    UNITS - Either 'rad/sample' or 'Hz' 

%#codegen

%   Copyright 1988-2018 The MathWorks, Inc.


if nargin < 6
    esttype = 'psd';
end

% Make sure we always returns a column vector for frequency
w1 = w2(:);

% Generate the one-sided spectrum [Power] if so wanted
if strcmp(range,'onesided') && isscalar(nfft)
   if isodd(nfft)
      select = 1:(nfft+1)/2;  % ODD
      Sxx_unscaled = Sxx1(select,:); % Take only [0,pi] or [0,pi)
      Sxx = [Sxx_unscaled(1,:); 2*Sxx_unscaled(2:end,:)];  % Only DC is a unique point and doesn't get doubled
   else
      select = 1:nfft/2+1;    % EVEN
      Sxx_unscaled = Sxx1(select,:); % Take only [0,pi] or [0,pi)
      Sxx = [Sxx_unscaled(1,:); 2*Sxx_unscaled(2:end-1,:); Sxx_unscaled(end,:)]; % Don't double unique Nyquist point
   end
   w = w1(select);
else
    Sxx = Sxx1;
    w=w1;
end

% Compute the PSD [Power/freq]
if ~isempty(Fs) && ~isnan(Fs)
   Pxx = Sxx./Fs; % Scale by the sampling frequency to obtain the psd
   units = 'Hz';
else
   Pxx = Sxx./(2.*pi); % Scale the power spectrum by 2*pi to obtain the psd 
   units = 'rad/sample';
end

if any(strcmpi(esttype,{'ms','power'}))
   varargout = {Sxx,w,units};  % Mean-square
else  
    varargout = {Pxx,w,units};  % PSD
end
end
