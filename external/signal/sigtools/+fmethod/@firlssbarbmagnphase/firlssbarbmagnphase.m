classdef firlssbarbmagnphase < fmethod.abstractfirlssbarbmag
%FIRLSSBARBMAGNPHASE   Construct a FIRLSSBARBMAGNPHASE object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firlssbarbmagnphase class
%   fmethod.firlssbarbmagnphase extends fmethod.abstractfirlssbarbmag.
%
%    fmethod.firlssbarbmagnphase properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.firlssbarbmagnphase methods:
%       getexamples -   Get the examples.
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function this = firlssbarbmagnphase

  % this = fmethod.firlssbarbmagnphase;

  this.DesignAlgorithm = 'FIR Least-squares';


  end  % firlssbarbmagnphase

end  % constructor block

methods  % public methods
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 

end  % classdef

