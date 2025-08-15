classdef (Abstract) abstracteqripbpmin < fmethod.abstracteqripbp
%ABSTRACTEQRIPBPMIN Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqripbpmin class
%   fmethod.abstracteqripbpmin extends fmethod.abstracteqripbp.
%
%    fmethod.abstracteqripbpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.abstracteqripbpmin methods:
%       getexamples -   Get the examples.
%       privupdateargs - Utility fcn called by POSTPROCESSMINORDERARGS



methods  % public methods
  examples = getexamples(~)
  args = privupdateargs(~,args,Nstep)
end  % public methods 


methods (Hidden) % possibly private or hidden
  s = validspecobj(~)
end  % possibly private or hidden 

end  % classdef

