classdef windowbp < fmethod.abstractwindow
%WINDOWBP   Construct a WINDOWBP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.windowbp class
%   fmethod.windowbp extends fmethod.abstractwindow.
%
%    fmethod.windowbp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.windowbp methods:
%       designargs -   Return the arguments for FIR1
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Return the valid specification object.



methods  % constructor block
  function this = windowbp

  % this = fmethod.windowbp;

  this.DesignAlgorithm = 'Window';


  end  % windowbp

end  % constructor block

methods  % public methods
  args = designargs(this,hspecs)
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

