classdef firlsdifford < fmethod.abstractfirls
%FIRLSDIFFORD   Construct a FIRLSDIFFORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firlsdifford class
%   fmethod.firlsdifford extends fmethod.abstractfirls.
%
%    fmethod.firlsdifford properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.firlsdifford methods:
%       algoname -   Short design algorithm name
%       designargs -   Returns the inputs to the design function.
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Returns the name of the valid specification object.



methods  % constructor block
  function this = firlsdifford

  % this = fmethod.firlsdifford;

  this.DesignAlgorithm = 'FIR least-squares';


  end  % firlsdifford

end  % constructor block

methods  % public methods
  name = algoname(this)
  args = designargs(this,hs)
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
  s = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

