classdef firlssbarbmag < fmethod.abstractfirlssbarbmag
%FIRLSSBARBMAG   Construct a FIRLSSBARBMAG object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firlssbarbmag class
%   fmethod.firlssbarbmag extends fmethod.abstractfirlssbarbmag.
%
%    fmethod.firlssbarbmag properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.firlssbarbmag methods:
%       getexamples -   Get the examples.
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function this = firlssbarbmag


  % this = fmethod.firlssbarbmag;

  this.DesignAlgorithm = 'FIR least-squares';


  end  % firlssbarbmag

end  % constructor block

methods  % public methods
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  b = thisforcelinearphase(this,b)
end  % possibly private or hidden 

end  % classdef

