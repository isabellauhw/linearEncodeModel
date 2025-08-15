function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN Perform the actual design.

%   Copyright 1999-2017 The MathWorks, Inc.

% Validate specifications
[N,F,E,H,nfpts] = validatespecs(hspecs);

% Weights
W = [];
NBands = hspecs.NBands;
this.privNBands = NBands;
for i = 1:NBands
    aux = get(this, ['B',num2str(i),'Weights']);
    if isempty(aux)
        aux = ones(size(get(hspecs,['B',num2str(i),'Frequencies'])));
    elseif isscalar(aux)
      aux = aux*ones(size(get(hspecs,['B',num2str(i),'Frequencies'])));
    end
    W = [W aux]; %#ok<*AGROW>
end

if length(W)~=nfpts
    error(message('signal:fmethod:eqripmultibandarbmagnphase:actualdesign:InvalidWeights'))
end

% Density factor
lgrid = this.DensityFactor;
if lgrid<16
    error(message('signal:fmethod:eqripmultibandarbmagnphase:actualdesign:InvaliddensityFactor'));
end

% Multi-band
b = cfirpm(N,E,{@multiband,F,H,W},{lgrid});
    
varargout = {{b}};
    
%--------------------------------------------------------------------------
function [DH,DW] = multiband(N,~,GF,~,F,H,myW)

if nargin==2
  % Return symmetry default:
  if strcmp(N,'defaults')
    % Second arg (F) is cell-array of args passed later to function:
    DH = 'real';
    return
  end
end

DH = interp1(F(:), H(:), GF);
DW = interp1(F(:), myW(:), GF);

% [EOF]
