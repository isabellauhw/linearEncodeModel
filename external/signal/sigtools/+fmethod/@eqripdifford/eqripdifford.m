classdef eqripdifford < fmethod.abstracteqripdiffhilb
%EQRIPDIFFORD   Construct an EQRIPDIFFORD object.

%   Copyright 1999-2015 The MathWorks, Inc.
 
%fmethod.eqripdifford class
%   fmethod.eqripdifford extends fmethod.abstracteqripdiffhilb.
%
%    fmethod.eqripdifford properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.eqripdifford methods:
%       algoname -   Short design algorithm name
%       designargs -   Returns the inputs to the design function.
%       getexamples -   Get the examples.
%       validspecobj -   Returns the name of the valid specification object.



methods  % constructor block
  function this = eqripdifford(varargin)

  % this = fmethod.eqripdifford;

  this.DesignAlgorithm = 'Equiripple';


  end  % eqripdifford

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

