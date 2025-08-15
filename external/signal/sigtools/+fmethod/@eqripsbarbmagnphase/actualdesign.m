function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN Perform the actual design.

%   Copyright 1999-2017 The MathWorks, Inc.

% Validate specifications
[N,F,A,P,nfpts] = validatespecs(hspecs);

% Weights
W = this.Weights;
if isempty(W)
    W = ones(size(F));
elseif isscalar(W)
    W = W*ones(size(F));
elseif length(W)~=nfpts
    error(message('signal:fmethod:eqripsbarbmagnphase:actualdesign:InvalidWeights'))
end

% Density factor
lgrid = this.DensityFactor;
if lgrid<16
    error(message('signal:fmethod:eqripsbarbmagnphase:actualdesign:InvaliddensityFactor'));
end

% Single band
if F(1)<0
    FF = [-1 1];
else
    FF = [0 1];
end
b = cfirpm(N,FF,{@singleband,F,A,P,W},{lgrid}); 
   
varargout = {{b}};
    
%--------------------------------------------------------------------------
function [DH,DW] = singleband(N,~,GF,~,F,A,P,myW)
% Frequency response called by CFIRPM (twice)

if nargin==2
  % Return symmetry default:
  if strcmp(N,'defaults')
    % Return symmetry.
    DH='real';
    return
  end
end

% Build the complex response
H = A.*exp(1i*P);

DH = interp1(F(:), H(:), GF);
DW = interp1(F(:), myW(:), GF);

% [EOF]
