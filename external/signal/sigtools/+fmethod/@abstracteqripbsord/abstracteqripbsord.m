classdef (Abstract) abstracteqripbsord < fmethod.abstracteqripbs
%ABSTRACTEQRIPBSORD Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqripbsord class
%   fmethod.abstracteqripbsord extends fmethod.abstracteqripbs.
%
%    fmethod.abstracteqripbsord properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Wpass1 - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%       Wpass2 - Property is of type 'posdouble user-defined'  
%
%    fmethod.abstracteqripbsord methods:
%       designargs - Return the design function inputs.
%       getdesignpanelstate - Get the designpanelstate.
%       getexamples - Get the examples.
%       validspecobj - Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WPASS1 Property is of type 'posdouble user-defined' 
  Wpass1 = 1;
  %WSTOP Property is of type 'posdouble user-defined' 
  Wstop = 1;
  %WPASS2 Property is of type 'posdouble user-defined' 
  Wpass2 = 1;
end


methods 
  function set.Wpass1(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wpass1')
  value = double(value);
  obj.Wpass1 = value;
  end
  %------------------------------------------------------------------------
  function set.Wstop(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wstop')
  value = double(value);
  obj.Wstop = value;
  end
  %------------------------------------------------------------------------
  function set.Wpass2(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wpass2')  
  value = double(value);
  obj.Wpass2 = value;
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

