classdef (Abstract) abstractfircls < fmethod.abstractfir
%ABSTRACTFIRCLS   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractfircls class
%   fmethod.abstractfircls extends fmethod.abstractfir.
%
%    fmethod.abstractfircls properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Zerophase - Property is of type 'bool'  
%
%    fmethod.abstractfircls methods:
%       actualdesign -   Perform the actual design.
%       getvalidstructs -   Get the validstructs.
%       postprocessmask - - Change the mask according to the passband offset value.


properties (AbortSet, SetObservable, GetObservable)
  %ZEROPHASE Property is of type 'bool' 
  Zerophase = false;
end


methods 
  function set.Zerophase(obj,value)
  validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','Zerophase')
  value = logical(value);
  obj.Zerophase = value;
  end

end   % set and get functions 

methods  % public methods
  varargout = actualdesign(this,hspecs)
  validstructs = getvalidstructs(this)
  newA = postprocessmask(this,oldA,units)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
  help_offset(this)
  help_zerophase(this)
end  % possibly private or hidden 

end  % classdef

