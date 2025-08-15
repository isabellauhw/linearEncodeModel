classdef windowlp < fmethod.abstractwindow
%WINDOWLP   Construct a WINDOWLP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.windowlp class
%   fmethod.windowlp extends fmethod.abstractwindow.
%
%    fmethod.windowlp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.windowlp methods:
%       designargs -   Return the arguments for FIR1
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Return the valid specification object.



methods  % constructor block
  function this = windowlp

  % this = fmethod.windowlp;

  this.DesignAlgorithm = 'Window';


  end  % windowlp

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

