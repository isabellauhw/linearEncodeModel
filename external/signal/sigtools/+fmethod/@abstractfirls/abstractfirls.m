classdef (Abstract) abstractfirls < fmethod.abstractfir
%ABSTRACTFIRLS   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractfirls class
%   fmethod.abstractfirls extends fmethod.abstractfir.
%
%    fmethod.abstractfirls properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.abstractfirls methods:
%       actualdesign -   Design a least squares filter.



methods  % public methods
  b = actualdesign(this,hs)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
  help_firls(this)
end  % possibly private or hidden 

end  % classdef

