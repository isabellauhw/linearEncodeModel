classdef (Abstract) abstracteqripsbarbmagord < fmethod.abstracteqrip
%ABSTRACTEQRIPSBARBMAGORD Construct an ABSTRACTEQRIPSBARBMAGORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqripsbarbmagord class
%   fmethod.abstracteqripsbarbmagord extends fmethod.abstracteqrip.
%
%    fmethod.abstracteqripsbarbmagord properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.abstracteqripsbarbmagord methods:
%       getexamples - Get the examples.
%       singleband -  Frequency response called by FIRPM and CFIRPM (twice)
%       validspecobj - Return the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WEIGHTS Property is of type 'double_vector user-defined' 
  Weights = 1;
end


methods 
  function set.Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','Weights')
  obj.Weights = value;
  end

end   % set and get functions 

methods  % public methods
  examples = getexamples(~)
  [DH,DW] = singleband(~,N,FF,GF,~,A,F,myW,iscomplex,delay)
  vso = validspecobj(~)
end  % public methods 

end  % classdef

