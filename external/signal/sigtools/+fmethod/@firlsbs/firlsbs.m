classdef firlsbs < fmethod.abstractfirls
%FIRLSBS   Construct a FIRLSBS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firlsbs class
%   fmethod.firlsbs extends fmethod.abstractfirls.
%
%    fmethod.firlsbs properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Wpass1 - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%       Wpass2 - Property is of type 'posdouble user-defined'  
%
%    fmethod.firlsbs methods:
%       designargs -   Returns the inputs to the design function.
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WPASS1 Property is of type 'posdouble user-defined' 
  Wpass1 = 1;
  %WSTOP Property is of type 'posdouble user-defined' 
  Wstop = 1;
  %WPASS2 Property is of type 'posdouble user-defined' 
  Wpass2 = 1;
end


methods  % constructor block
  function this = firlsbs

  % this = fmethod.firlsbs;

  this.DesignAlgorithm = 'FIR least-squares';


  end  % firlsbs

end  % constructor block

methods 
  function set.Wpass1(obj,value)
  validateattributes(value,{'numeric'},{'positive','scalar'},'','Wpass1')
  value=double(value);
  obj.Wpass1 = value;
  end
  %------------------------------------------------------------------------
  function set.Wstop(obj,value)
  validateattributes(value,{'numeric'},{'positive','scalar'},'','Wstop')
  value=double(value);
  obj.Wstop = value;
  end
  %------------------------------------------------------------------------
  function set.Wpass2(obj,value)
  validateattributes(value,{'numeric'},{'positive','scalar'},'','Wpass2')
  value=double(value);
  obj.Wpass2 = value;
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

