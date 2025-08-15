classdef (Abstract) abstractfirmaxflat < fmethod.abstractfir
%ABSTRACTFREQSAMPARBMAG   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%ABSTRACTWINDOW   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.
  
%fmethod.abstractfirmaxflat class
%   fmethod.abstractfirmaxflat extends fmethod.abstractfir.
%
%    fmethod.abstractfirmaxflat properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.abstractfirmaxflat methods:
%       designargs -   Return the arguments for MAXFLAT
%       getvalidstructs -   Get the validstructs.
%       lpprototypedesign -   Design the prototype lowpass maximally flat FIR which



methods  % public methods
  args = designargs(this,hspecs)
  validstructs = getvalidstructs(this)
  b = lpprototypedesign(this,hspecs,varargin)
end  % public methods 


 methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

