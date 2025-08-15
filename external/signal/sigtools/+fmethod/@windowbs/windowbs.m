classdef windowbs < fmethod.abstractwindow
%WINDOWBS   Construct a WINDOWBS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.windowbs class
%   fmethod.windowbs extends fmethod.abstractwindow.
%
%    fmethod.windowbs properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.windowbs methods:
%       designargs -   Return the arguments for FIR1
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Return the valid specification object.



methods  % constructor block
  function this = windowbs

  % this = fmethod.windowbs;

  this.DesignAlgorithm = 'Window';


  end  % windowbs

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

