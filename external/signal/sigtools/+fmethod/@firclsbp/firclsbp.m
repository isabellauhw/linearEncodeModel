classdef firclsbp < fmethod.abstractfircls
%FIRCLSBP   Construct an FIRCLSBP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firclsbp class
%   fmethod.firclsbp extends fmethod.abstractfircls.
%
%    fmethod.firclsbp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Zerophase - Property is of type 'bool'  
%       PassbandOffset - Property is of type 'double'  
%
%    fmethod.firclsbp methods:
%       designargs -   Return the arguments for MAXFLAT
%       getexamples -   Get the examples.
%       postprocessmask - - Change the mask according to passband offset value.
%       validspecobj -   Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %PASSBANDOFFSET Property is of type 'double' 
  PassbandOffset = 0;
end


methods  % constructor block
  function this = firclsbp

  % this = fmethod.firclsbp;

  this.DesignAlgorithm = 'FIR Constrained Least-Squares';


  end  % firclsbp

end  % constructor block

methods 
  function set.PassbandOffset(obj,value)
  validateattributes(value,{'numeric'}, {'scalar'},'','PassbandOffset')
  value = double(value);
  obj.PassbandOffset = value;
  end

end   % set and get functions 

methods  % public methods
  args = designargs(this,hspecs)
  examples = getexamples(this)
  newA = postprocessmask(this,oldA,units)
  s = validspecobj(this)
end  % public methods 

end  % classdef

