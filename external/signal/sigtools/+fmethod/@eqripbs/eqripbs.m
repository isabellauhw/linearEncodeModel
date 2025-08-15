classdef eqripbs < fmethod.abstracteqripbsord
%EQRIPBS   Construct an EQRIPBS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqripbs class
%   fmethod.eqripbs extends fmethod.abstracteqripbsord.
%
%    fmethod.eqripbs properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Wpass1 - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%       Wpass2 - Property is of type 'posdouble user-defined'  



methods  % constructor block
  function this = eqripbs(DensityFactor)

  % this = fmethod.eqripbs;

  this.DesignAlgorithm = 'Equiripple';

  if nargin
      set(this, 'DensityFactor', DensityFactor);
  end


  end  % eqripbs
        
end  % constructor block
end  % classdef

