function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN Perform the actual design.

%   Copyright 1999-2017 The MathWorks, Inc.

% Validate specifications
[N,F,E,A,nfpts] = validatespecs(hspecs);

% Determine if the filter is real
isreal = true;
if F(1)<0, isreal = false; end

% Weights
NBands = hspecs.NBands;
this.privNBands = NBands;
W = [];
for idx = 1:NBands
  strW = [sprintf('B%d',idx),'Weights'];
  strF = [sprintf('B%d', idx),'Frequencies'];
  Widx = this.(strW);
  if isempty(Widx)
    Widx = ones(size(hspecs.(strF))); 
  elseif isscalar(Widx)
    Widx = Widx*ones(size(hspecs.(strF)));
  end
  W = [W Widx]; %#ok<*AGROW>
end

if length(W)~=nfpts
    error(message('signal:fmethod:eqripmultiband:actualdesign:InvalidWeights'))
end

% Density factor
lgrid = this.DensityFactor;
if lgrid<16
    error(message('signal:fmethod:eqripmultiband:actualdesign:InvaliddensityFactor'));
end

% Multi-band
if isreal
    method = thisrealmethod(this);
    if A(end)~=0 && rem(N,2)
        b = feval(method,N,E,{@this.multiband,A,F,W,false},{lgrid},'h');
    else
        b = feval(method,N,E,{@this.multiband,A,F,W,false},{lgrid});
    end
else
    method = thiscomplexmethod(this);
    b = feval(method,N,E,{@this.multiband,A,F,W,true},{lgrid});
end
    
varargout = {{b}};
    
% [EOF]
