classdef firlshilbord < fmethod.abstractfirls
%FIRLSHILBORD   Construct a FIRLSHILBORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firlshilbord class
%   fmethod.firlshilbord extends fmethod.abstractfirls.
%
%    fmethod.firlshilbord properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.firlshilbord methods:
%       algoname -   Short design algorithm name
%       designargs -   Returns the inputs to the design function.
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Returns the name of the valid specification object.



methods  % constructor block
  function this = firlshilbord

  % this = fmethod.firlshilbord;

  this.DesignAlgorithm = 'FIR least-squares';


  end  % firlshilbord

end  % constructor block

methods  % public methods
  name = algoname(this)
  args = designargs(this,hs)
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
  s = validspecobj(this)
end  % public methods 

end  % classdef

