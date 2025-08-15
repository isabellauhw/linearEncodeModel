classdef windowhp < fmethod.abstractwindow
%WINDOWHP   Construct a WINDOWHP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.windowhp class
%   fmethod.windowhp extends fmethod.abstractwindow.
%
%    fmethod.windowhp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.windowhp methods:
%       designargs -   Return the arguments for FIR1
%       getexamples -   Get the examples.
%       validspecobj -   Return the valid specification object.



methods  % constructor block
  function this = windowhp

  % this = fmethod.windowhp;

  this.DesignAlgorithm = 'Window';


  end  % windowhp

end  % constructor block

methods  % public methods
  args = designargs(this,hspecs)
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

