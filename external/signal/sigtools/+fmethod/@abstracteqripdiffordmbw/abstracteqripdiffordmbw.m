classdef (Abstract) abstracteqripdiffordmbw < fmethod.abstracteqripdiffordmb
%ABSTRACTEQRIPDIFFORDMBW Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqripdiffordmbw class
%   fmethod.abstracteqripdiffordmbw extends fmethod.abstracteqripdiffordmb.
%
%    fmethod.abstracteqripdiffordmbw properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%
%    fmethod.abstracteqripdiffordmbw methods:
%       designargs - Returns the inputs to the design function.
%       getexamples - Get the examples.
%       validspecobj -  Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WPASS Property is of type 'posdouble user-defined' 
  Wpass = 1;
  %WSTOP Property is of type 'posdouble user-defined' 
  Wstop = 1;
end


methods 
  function set.Wpass(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wpass')
  value=double(value);
  obj.Wpass = value;
  end
  %------------------------------------------------------------------------
  function set.Wstop(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wstop')
  value=double(value);
  obj.Wstop = value;
  end

end   % set and get functions 

methods  % public methods
  args = designargs(this,hs)
  examples = getexamples(~)
  s = validspecobj(~)
end  % public methods 

end  % classdef

