classdef eqripsbarbmagnphase < fmethod.abstracteqrip
%EQRIPSBARBMAGNPHASE   Construct an EQRIPSBARBMAGNPHASE object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqripsbarbmagnphase class
%   fmethod.eqripsbarbmagnphase extends fmethod.abstracteqrip.
%
%    fmethod.eqripsbarbmagnphase properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.eqripsbarbmagnphase methods:
%       actualdesign - Perform the actual design.
%       getexamples -   Get the examples.
%       validspecobj -   Return the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WEIGHTS Property is of type 'double_vector user-defined' 
  Weights = 1;
end


methods  % constructor block
  function this = eqripsbarbmagnphase

  % this = fmethod.eqripsbarbmagnphase;

  this.DesignAlgorithm = 'Equiripple';


  end  % eqripsbarbmagnphase

end  % constructor block

methods 
  function set.Weights(obj,value)
  validateattributes(value,{'double'}, {'vector'},'','Weights')  
  obj.Weights = value;
  end

end   % set and get functions 

methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
  s = thisdesignopts(this,s)
end  % possibly private or hidden 

end  % classdef

