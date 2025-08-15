classdef firclshp < fmethod.abstractfircls
%FIRCLSHP   Construct an FIRCLSHP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firclshp class
%   fmethod.firclshp extends fmethod.abstractfircls.
%
%    fmethod.firclshp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Zerophase - Property is of type 'bool'  
%       PassbandOffset - Property is of type 'double'  
%
%    fmethod.firclshp methods:
%       designargs -   Return the arguments for MAXFLAT
%       getexamples -   Get the examples.
%       searchmincoeffwl - Search for min. coeff wordlength.
%       validspecobj -   Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %PASSBANDOFFSET Property is of type 'double' 
  PassbandOffset = 0;
end


methods  % constructor block
  function this = firclshp

  % this = fmethod.firclshp;

  this.DesignAlgorithm = 'FIR Constrained Least-Squares';


  end  % firclshp

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

