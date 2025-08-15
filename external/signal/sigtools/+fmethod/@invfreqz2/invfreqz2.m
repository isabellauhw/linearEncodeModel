classdef invfreqz2 < fmethod.invfreqz
%INVFREQZ2   Construct an INVFREQZ2 object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.invfreqz2 class
%   fmethod.invfreqz2 extends fmethod.invfreqz.
%
%    fmethod.invfreqz2 properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.invfreqz2 methods:
%       getexamples -   Get the examples.
%       getfilterorders -   Get the filterorders.
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function this = invfreqz2

  % this = fmethod.invfreqz2;

  this.FilterStructure = 'df2';
  this.DesignAlgorithm = 'IIR Least-Squares';


  end  % invfreqz2

end  % constructor block

methods  % public methods
  examples = getexamples(this)
  [NumOrder,DenOrder] = getfilterorders(this,hspecs)
  vso = validspecobj(this)
end  % public methods 

end  % classdef

