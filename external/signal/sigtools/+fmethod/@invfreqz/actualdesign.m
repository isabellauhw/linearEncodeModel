function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN Perform the actual design.

%   Copyright 1999-2017 The MathWorks, Inc.

% Validate specifications
[Nb,Na] = getfilterorders(this,hspecs);
[F,A,P,nfpts] = super_validatespecs(hspecs);

% Determine if the filter is real
isreal = true;
if F(1)<0, isreal = false; end

% Interpolate magnitudes and phases on regular grid
nfft = max(nextpow2(nfpts),1024);
[ff,aa,pp] = interp_on_regular_grid(F,A,P,nfft,isreal);

% Build the complex response 
H = aa.*exp(1i*pp);

W = this.Weights;
if isempty(W) || isscalar(W)
    if isreal
        [b,a] = invfreqz(H,ff*pi,Nb,Na);
    else
        [b,a] = invfreqz(H,ff*pi,'complex',Nb,Na);
    end
elseif length(W)~=nfpts
    error(message('signal:fmethod:invfreqz:actualdesign:InvalidWeights'));
else
    WW = interp1(F,W,ff);
    if isreal
        [b,a] = invfreqz(H,ff*pi,Nb,Na,WW);
    else
        [b,a] = invfreqz(H,ff*pi,'complex',Nb,Na,WW);
    end
end

varargout = {{b,a}};

%--------------------------------------------------------------------------
function [ff,aa,pp] = interp_on_regular_grid(F,A,P,nfft,~)
% Interpolate magnitudes and phases on regular grid

ff = linspace(F(1),F(end),nfft);
aa = interp1(F,A,ff);
pp = interp1(F,P,ff);
