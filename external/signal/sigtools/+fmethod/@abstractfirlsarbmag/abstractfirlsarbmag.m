classdef (Abstract) abstractfirlsarbmag < fmethod.abstractfirls
%ABSTRACTFIRLSARBMAG   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractfirlsarbmag class
%   fmethod.abstractfirlsarbmag extends fmethod.abstractfirls.
%
%    fmethod.abstractfirlsarbmag properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.abstractfirlsarbmag methods:
%       actualdesign -   Perform the actual design.



methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
  b = super_thisforcelinearphase(this,b)
  b = thisforcelinearphase(this,b)
end  % possibly private or hidden 

end  % classdef

