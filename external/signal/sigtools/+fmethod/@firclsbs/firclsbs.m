classdef firclsbs < fmethod.abstractfircls
%FIRCLSBS   Construct an FIRCLSBS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firclsbs class
%   fmethod.firclsbs extends fmethod.abstractfircls.
%
%    fmethod.firclsbs properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Zerophase - Property is of type 'bool'  
%       PassbandOffset - Property is of type 'mxArray'  
%
%    fmethod.firclsbs methods:
%       designargs -   Return the arguments for MAXFLAT
%       get_offset -  Preget function for 'PassbandOffset' property
%       getexamples -   Get the examples.
%       set_offset - - Preset function for 'PassbandOffset' property.
%       validspecobj -   Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %PASSBANDOFFSET Property is of type 'mxArray' 
  PassbandOffset = [];
end


methods  % constructor block
  function this = firclsbs

  % this = fmethod.firclsbs;

  this.DesignAlgorithm = 'FIR Constrained Least-Squares';

  end  % firclsbs

end  % constructor block

methods 
  function value = get.PassbandOffset(obj)
  value = get_offset(obj,obj.PassbandOffset);
  end
  %------------------------------------------------------------------------
  function set.PassbandOffset(obj,value)
  validateattributes(value,{'double'},{'vector'},'','PassbandOffset');
  obj.PassbandOffset = set_offset(obj,value);
  end

end   % set and get functions 

methods  % public methods
  args = designargs(this,hspecs)
  offset = get_offset(this,offset)
  examples = getexamples(this)
  offset = set_offset(this,offset)
  s = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help_offset(this)
  newA = postprocessmask(this,oldA,units)
end  % possibly private or hidden 

end  % classdef

