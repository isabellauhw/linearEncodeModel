function [N,F,D,W,nfpts] = getdesiredresponse(this,hspecs)
%GETDESIREDRESPONSE Get the desiredresponse.

%   Copyright 1999-2017 The MathWorks, Inc.

% Validate specifications
[N,F,A,P,nfpts] = validatespecs(hspecs);

% Weights
W = this.Weights;
if isempty(W)
    W = ones(size(F));
elseif isscalar(W)
  W = W*ones(size(F));
end
if length(W)~=nfpts
    error(message('signal:fmethod:abstractfirlssbarbmag:getdesiredresponse:InvalidWeights'))
end
W = W(:).';

% Interpolate magnitudes and phases on regular grid
[F,A,P,W,nfpts] = interp_on_grid(F,A,P,W,N+1);

% Complex Response 
D = A.*exp(1i*P);

%--------------------------------------------------------------------------
function [ff,aa,pp,ww,nfpts] = interp_on_grid(F,A,P,W,filtlength)
% Interpolate magnitudes and phases 

if F(1)==0
    fdomain = 'half';
else 
    fdomain = 'whole';
end

[ff,nfpts] = crmz_grid([F(1) F(end)]/2, filtlength, fdomain, 16);
ff = 2*ff;
aa = interp1(F,A,ff);
pp = interp1(F,P,ff);
ww = interp1(F,W,ff);

% Force row vectors
ff=ff(:).';aa = aa(:).';pp = pp(:).';ww=ww(:).';

% [EOF]
