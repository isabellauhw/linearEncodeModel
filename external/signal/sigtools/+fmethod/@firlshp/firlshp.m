classdef firlshp < fmethod.firlslp
%FIRLSHP   Construct a FIRLSHP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firlshp class
%   fmethod.firlshp extends fmethod.firlslp.
%
%    fmethod.firlshp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%
%    fmethod.firlshp methods:
%       designargs -   Return the design inputs.
%       getexamples -   Get the examples.
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function this = firlshp

  % this = fmethod.firlshp;

  this.DesignAlgorithm = 'FIR least-squares';


  end  % firlshp

end  % constructor block

methods  % public methods
  args = designargs(this,hs)
  examples = getexamples(this)
  s = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

