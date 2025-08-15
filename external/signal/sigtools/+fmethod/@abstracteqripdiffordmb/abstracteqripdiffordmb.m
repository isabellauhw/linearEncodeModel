classdef (Abstract) abstracteqripdiffordmb < fmethod.abstracteqripdiffhilb
%ABSTRACTEQRIPDIFFORDMB Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqripdiffordmb class
%   fmethod.abstracteqripdiffordmb extends fmethod.abstracteqripdiffhilb.
%
%    fmethod.abstracteqripdiffordmb properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.abstracteqripdiffordmb methods:
%       algoname - Short design algorithm name



methods  % public methods
  name = algoname(~)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
  s = thisdesignopts(~,s)
end  % possibly private or hidden 

end  % classdef

