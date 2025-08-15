classdef eqriphilbord < fmethod.abstracteqripdiffhilb
%EQRIPHILBORD   Construct an EQRIPHILBORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqriphilbord class
%   fmethod.eqriphilbord extends fmethod.abstracteqripdiffhilb.
%
%    fmethod.eqriphilbord properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.eqriphilbord methods:
%       algoname -   Short design algorithm name
%       designargs -   Returns the inputs to the design function.
%       getexamples -   Get the examples.
%       validspecobj -   Returns the name of the valid specification object.



methods  % constructor block
  function this = eqriphilbord

  % this = fmethod.eqriphilbord;

  this.DesignAlgorithm = 'Equiripple';


  end  % eqriphilbord

end  % constructor block

methods  % public methods
  name = algoname(this)
  args = designargs(this,hs)
  examples = getexamples(this)
  s = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
  s = thisdesignopts(this,s)
end  % possibly private or hidden 

end  % classdef

