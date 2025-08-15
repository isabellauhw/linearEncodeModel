classdef (Abstract) abstracteqripdiffhilb < fmethod.abstracteqrip
%ABSTRACTEQRIPDIFFHILB   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqripdiffhilb class
%   fmethod.abstracteqripdiffhilb extends fmethod.abstracteqrip.
%
%    fmethod.abstracteqripdiffhilb properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.abstracteqripdiffhilb methods:
%       getvalidstructs -   Get the validstructs.
%       set_maxphase -   PreSet function for the 'maxphase' property.
%       set_minphase -   PreSet function for the 'minphase' property.



methods  % public methods
  validstructs = getvalidstructs(this)
  maxphase = set_maxphase(this,maxphase)
  minphase = set_minphase(this,minphase)
end  % public methods 


methods (Hidden) % possibly private or hidden
  s = thisdesignopts(this,s)
end  % possibly private or hidden 

end  % classdef

