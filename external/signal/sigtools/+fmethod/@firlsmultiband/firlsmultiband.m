classdef firlsmultiband < fmethod.abstractfirlsmultiband
%FIRLSMULTIBAND   Construct a FIRLSMULTIBAND object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firlsmultiband class
%   fmethod.firlsmultiband extends fmethod.abstractfirlsmultiband.
%
%    fmethod.firlsmultiband properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       B1Weights - Property is of type 'double_vector user-defined'  
%       B2Weights - Property is of type 'double_vector user-defined'  
%       B3Weights - Property is of type 'double_vector user-defined'  
%       B4Weights - Property is of type 'double_vector user-defined'  
%       B5Weights - Property is of type 'double_vector user-defined'  
%       B6Weights - Property is of type 'double_vector user-defined'  
%       B7Weights - Property is of type 'double_vector user-defined'  
%       B8Weights - Property is of type 'double_vector user-defined'  
%       B9Weights - Property is of type 'double_vector user-defined'  
%       B10Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.firlsmultiband methods:
%       getexamples -   Get the examples.
%       getvalidspecs -   Get the validspecs.
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function this = firlsmultiband

  % this = fmethod.firlsmultiband;

  this.DesignAlgorithm = 'FIR least-squares';


  end  % firlsmultiband

end  % constructor block

methods  % public methods
  examples = getexamples(this)
  [N,F,E,A,P,nfpts] = getvalidspecs(this,hspecs)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  b = thisforcelinearphase(this,b)
end  % possibly private or hidden 

end  % classdef

