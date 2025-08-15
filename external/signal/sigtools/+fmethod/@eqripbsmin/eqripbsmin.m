classdef eqripbsmin < fmethod.abstracteqripbsmin
%EQRIPBSMIN   Construct an EQRIPBSMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqripbsmin class
%   fmethod.eqripbsmin extends fmethod.abstracteqripbsmin.
%
%    fmethod.eqripbsmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.eqripbsmin methods:
%       designargs -   Return the inputs for the FIRPM design function.



methods  % constructor block
  function this = eqripbsmin(DensityFactor)

  % this = fmethod.eqripbsmin;

  this.DesignAlgorithm = 'Equiripple';

  if nargin
      set(this, 'DensityFactor', DensityFactor);
  end


  end  % eqripbsmin

end  % constructor block

methods  % public methods
  args = designargs(this,hspecs)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

