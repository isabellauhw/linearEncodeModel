classdef eqripbp < fmethod.abstracteqripbpord
%EQRIPBP   Construct an EQRIPBP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqripbp class
%   fmethod.eqripbp extends fmethod.abstracteqripbpord.
%
%    fmethod.eqripbp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Wstop1 - Property is of type 'posdouble user-defined'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop2 - Property is of type 'posdouble user-defined'  



methods  % constructor block
  function this = eqripbp(DensityFactor)

  % this = fmethod.eqripbp;

  this.DesignAlgorithm = 'Equiripple';

  if nargin
      set(this, 'DensityFactor', DensityFactor);
  end


  end  % eqripbp

end  % constructor block
end  % classdef

