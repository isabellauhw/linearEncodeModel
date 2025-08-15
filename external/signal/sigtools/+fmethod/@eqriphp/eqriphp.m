classdef eqriphp < fmethod.eqriplp
%EQRIPHP   Construct an EQRIPHP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqriphp class
%   fmethod.eqriphp extends fmethod.eqriplp.
%
%    fmethod.eqriphp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%
%    fmethod.eqriphp methods:
%       designargs -   Return the design inputs.
%       getdesignpanelstate -   Get the designpanelstate.
%       getexamples -   Get the examples.
%       validspecobj -   Returns the name of the valid specification object.



methods  % constructor block
  function this = eqriphp(DensityFactor)

  % this = fmethod.eqriphp;

  this.DesignAlgorithm = 'Equiripple';

  if nargin
      set(this, 'DensityFactor', DensityFactor);
  end


  end  % eqriphp

end  % constructor block

methods  % public methods
  args = designargs(this,hs)
  s = getdesignpanelstate(this)
  examples = getexamples(this)
  s = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

