classdef firlsbp < fmethod.abstractfirls
%FIRLSBP   Construct a FIRLSBP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firlsbp class
%   fmethod.firlsbp extends fmethod.abstractfirls.
%
%    fmethod.firlsbp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Wstop1 - Property is of type 'posdouble user-defined'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop2 - Property is of type 'posdouble user-defined'  
%
%    fmethod.firlsbp methods:
%       designargs -   Returns the inputs to the design function.
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WSTOP1 Property is of type 'posdouble user-defined' 
  Wstop1 = 1;
  %WPASS Property is of type 'posdouble user-defined' 
  Wpass = 1;
  %WSTOP2 Property is of type 'posdouble user-defined' 
  Wstop2 = 1;
end


methods  % constructor block
  function this = firlsbp

  % this = fmethod.firlsbp;

  this.DesignAlgorithm = 'FIR Least-Squares';


  end  % firlsbp

end  % constructor block

methods 
  function set.Wstop1(obj,value)
  validateattributes(value,{'numeric'},{'positive','scalar'},'','Wstop1')
  value=double(value);
  obj.Wstop1 = value;
  end
  %------------------------------------------------------------------------
  function set.Wpass(obj,value)
  validateattributes(value,{'numeric'},{'positive','scalar'},'','Wpass')
  value=double(value);
  obj.Wpass = value;
  end
  %------------------------------------------------------------------------
  function set.Wstop2(obj,value)
  validateattributes(value,{'numeric'},{'positive','scalar'},'','Wstop2')
  value=double(value);
  obj.Wstop2 = value;
  end

end   % set and get functions 

methods  % public methods
  args = designargs(this,hs)
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
  s = validspecobj(this)
end  % public methods 

methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

