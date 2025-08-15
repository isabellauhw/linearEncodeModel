classdef eqriphpmin < fmethod.abstracteqriphpmin
%EQRIPHPMIN   Construct an EQRIPHPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqriphpmin class
%   fmethod.eqriphpmin extends fmethod.abstracteqriphpmin.
%
%    fmethod.eqriphpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.eqriphpmin methods:
%       designargs -   Return the inputs for the FIRPM design function.
%       getexamples -   Get the examples.
%       privupdateargs - Utility fcn called by POSTPROCESSMINORDERARGS



methods  % constructor block
  function this = eqriphpmin(DensityFactor)

  % this = fmethod.eqriphpmin;

 this.DesignAlgorithm = 'Equiripple';

  if nargin
      set(this, 'DensityFactor', DensityFactor);
  end


  end  % eqriphpmin

end  % constructor block

methods  % public methods
  args = designargs(this,hs)
  examples = getexamples(this)
  args = privupdateargs(this,args,Nstep)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [stopbands,passbands,Astop,Apass] = getfbandstomeas(this,hspecs)
  help(this)
end  % possibly private or hidden 

end  % classdef

