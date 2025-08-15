classdef firlslp < fmethod.abstractfirls
%FIRLSLP   Construct a FIRLSLP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firlslp class
%   fmethod.firlslp extends fmethod.abstractfirls.
%
%    fmethod.firlslp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%
%    fmethod.firlslp methods:
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Return the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WPASS Property is of type 'posdouble user-defined' 
  Wpass = 1;
  %WSTOP Property is of type 'posdouble user-defined' 
  Wstop = 1;
end


methods  % constructor block
  function this = firlslp

  % this = fmethod.firlslp;

  this.DesignAlgorithm = 'FIR least-squares';


  end  % firlslp

end  % constructor block

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
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
  s = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  args = designargs(this,hs)
  help(this)
end  % possibly private or hidden 

end  % classdef

