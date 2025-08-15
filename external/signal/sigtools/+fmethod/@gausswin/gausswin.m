classdef gausswin < fmethod.abstractrcosfir
%WINDOWRCOS Construct a gausswin object

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.gausswin class
%   fmethod.gausswin extends fmethod.abstractrcosfir.
%
%    fmethod.gausswin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.gausswin methods:
%       actualdesign - <short description>
%       designargs - Return the arguments for the design method
%       getexamples -   Get the examples.
%       help_gauss - HELP   
%       validspecobj - Return the name of the valid specification object



methods  % constructor block
  function this = gausswin

  % this = fmethod.gausswin;

  this.DesignAlgorithm = 'Window';


  end  % gausswin

end  % constructor block

methods  % public methods
  b = actualdesign(this,hspecs,varargin)
  args = designargs(this,hspecs)
  examples = getexamples(this)
  help_gauss(this)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

