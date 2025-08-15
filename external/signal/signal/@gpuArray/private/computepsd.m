function varargout = computepsd(Sxx1,w2,range,nfft,Fs,esttype)
%COMPUTEPSD  Compute the one-sided or two-sided PSD or Mean-Square.

%   Copyright 2019 The MathWorks, Inc.

if nargin < 6
    esttype = 'psd';
end

% Make sure we always returns a column vector for frequency
w1 = reshape(w2,[],1);

% Generate the one-sided spectrum [Power] if so wanted
if strcmp(range,'onesided') && isscalar(nfft)
    if mod(nfft,2) ~= 0
        select = 1:(nfft+1)/2;  % ODD
        Sxx_unscaled = head(Sxx1,length(select)); % Take only [0,pi] or [0,pi)
        Sxx = [head(Sxx_unscaled,1); 2*tail(Sxx_unscaled, size(Sxx_unscaled,1)-1)]; % Only DC is a unique point and doesn't get doubled
    else
        select = 1:nfft/2+1;    % EVEN
        Sxx_unscaled = head(Sxx1,length(select)); % Take only [0,pi] or [0,pi)
        S.type = '()';
        S.subs = {2:size(Sxx_unscaled,1)-1,':'};
        Sxx = [head(Sxx_unscaled,1); 2*subsref(Sxx_unscaled,S); tail(Sxx_unscaled,1)]; % Don't double unique Nyquist point
    end
    w = head(w1,length(select));
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
