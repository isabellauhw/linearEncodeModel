classdef (Abstract) abstracteqripbpord < fmethod.abstracteqripbp
%ABSTRACTEQRIPBPORD Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqripbpord class
%   fmethod.abstracteqripbpord extends fmethod.abstracteqripbp.
%
%    fmethod.abstracteqripbpord properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Wstop1 - Property is of type 'posdouble user-defined'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop2 - Property is of type 'posdouble user-defined'  
%
%    fmethod.abstracteqripbpord methods:
%       designargs - Return the design function inputs.
%       getdesignpanelstate -   Get the designpanelstate.
%       getexamples -   Get the examples.
%       validspecobj - Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WSTOP1 Property is of type 'posdouble user-defined' 
  Wstop1 = 1;
  %WPASS Property is of type 'posdouble user-defined' 
  Wpass = 1;
  %WSTOP2 Property is of type 'posdouble user-defined' 
  Wstop2 = 1;
end


methods 
  function set.Wstop1(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wstop1')
  value = double(value);
  obj.Wstop1 = value;
  end
  %------------------------------------------------------------------------
  function set.Wpass(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wpass')
  value = double(value);
  obj.Wpass = value;
  end
  %------------------------------------------------------------------------
  function set.Wstop2(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wstop2')
  value = double(value);
  obj.Wstop2 = value;
  end

end   % set and get functions 

methods  % public methods
  args = designargs(this,hs)
  s = getdesignpanelstate(this)
  examples = getexamples(~)
  s = validspecobj(~)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

