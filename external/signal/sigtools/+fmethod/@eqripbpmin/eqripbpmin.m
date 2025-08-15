classdef eqripbpmin < fmethod.abstracteqripbpmin
%EQRIPBPMIN   Construct an EQRIPBPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqripbpmin class
%   fmethod.eqripbpmin extends fmethod.abstracteqripbpmin.
%
%    fmethod.eqripbpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.eqripbpmin methods:
%       designargs -   Return the inputs for the FIRPM design function.



methods  % constructor block
  function this = eqripbpmin(DensityFactor)

  % this = fmethod.eqripbpmin;

  this.DesignAlgorithm = 'Equiripple';

  if nargin
      set(this, 'DensityFactor', DensityFactor);
  end


  end  % eqripbpmin

end  % constructor block

methods  % public methods
  args = designargs(this,hspecs)
end  % public methods 

end  % classdef

