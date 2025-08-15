classdef eqriplpmin < fmethod.abstracteqrip
%EQRIPLPMIN   Construct an EQRIPLPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqriplpmin class
%   fmethod.eqriplpmin extends fmethod.abstracteqrip.
%
%    fmethod.eqriplpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.eqriplpmin methods:
%       designargs -   Returns a cell to be passed to the design function.
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       privupdateargs - Utility fcn called by POSTPROCESSMINORDERARGS
%       validspecobj -   Returns the name of the valid specification object.



methods  % constructor block
  function this = eqriplpmin(DensityFactor)

  % this = fmethod.eqriplpmin;

  this.DesignAlgorithm = 'Equiripple';

  if nargin
      set(this, 'DensityFactor', DensityFactor);
  end


  end  % eqriplpmin

end  % constructor block

methods  % public methods
  args = designargs(this,hs)
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
  args = privupdateargs(this,args,Nstep)
  str = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [stopbands,passbands,Astop,Apass] = getfbandstomeas(this,hspecs)
  help(this)
end  % possibly private or hidden 

end  % classdef

