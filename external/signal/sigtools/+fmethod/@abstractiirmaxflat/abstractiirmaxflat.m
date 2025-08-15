classdef (Abstract) abstractiirmaxflat < fmethod.abstractclassiciir
%ABSTRACTIIRMAXFLAT   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractiirmaxflat class
%   fmethod.abstractiirmaxflat extends fmethod.abstractclassiciir.
%
%    fmethod.abstractiirmaxflat properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%
%    fmethod.abstractiirmaxflat methods:
%       getvalidstructs -   Get the validstructs.
%       lpprototypedesign - LPPROTOTYPEACTUALDESIGN   Design the prototype lowpass IIR filter which



methods  % public methods
  validstructs = getvalidstructs(this)
  [b,a] = lpprototypedesign(this,hspecs,varargin)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

