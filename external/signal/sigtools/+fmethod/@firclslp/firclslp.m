classdef firclslp < fmethod.abstractfircls
%FIRCLSLP   Construct an FIRCLSLP object.
  
%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firclslp class
%   fmethod.firclslp extends fmethod.abstractfircls.
%
%    fmethod.firclslp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Zerophase - Property is of type 'bool'  
%       PassbandOffset - Property is of type 'double'  
%
%    fmethod.firclslp methods:
%       designargs -   Return the arguments for MAXFLAT
%       getexamples -   Get the examples.
%       searchmincoeffwl - Search for min. coeff wordlength.
%       validspecobj -   Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %PASSBANDOFFSET Property is of type 'double' 
  PassbandOffset = 0;
end


methods  % constructor block
  function this = firclslp

  % this = fmethod.firclslp;

  this.DesignAlgorithm = 'FIR constrained least-squares';


  end  % firclslp

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
  Hbest = searchmincoeffwl(this,args,varargin)
  s = validspecobj(this)
end  % public methods 

end  % classdef

