function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN Perform the actual design.

%   Copyright 1999-2017 The MathWorks, Inc.

% Validate specifications
[N,F,A,~,nfpts] = validatespecs(hspecs);

% Determine if the filter is real
isreal = true;
if F(1)<0, isreal = false; end

% Weights
W = this.Weights;
if isempty(W)
    W = ones(size(F));
elseif isscalar(W)
    W = W*ones(size(F)); 
elseif length(W)~=nfpts
    error(message('signal:fmethod:eqripsbarbmag:actualdesign:InvalidWeights'))
end

% Density factor
lgrid = this.DensityFactor;
if lgrid<16
    error(message('signal:fmethod:eqripsbarbmag:actualdesign:InvaliddensityFactor'));
end

% Single band
if isreal
    FF = [0 1];
    method = thisrealmethod(this);
    if A(end)~=0 && rem(N,2)
        b = feval(method,N,FF,{@this.singleband,A,F,W,false},{lgrid},'h');
    else
        b = feval(method,N,FF,{@this.singleband,A,F,W,false},{lgrid});
    end
else
    FF = [-1 1];
    method = thiscomplexmethod(this);
    b = feval(method,N,FF,{@this.singleband,A,F,W,true},{lgrid}); 
end
    
varargout = {{b}};
    


% [EOF]
