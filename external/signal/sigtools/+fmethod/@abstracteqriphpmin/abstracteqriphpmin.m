classdef (Abstract) abstracteqriphpmin < fmethod.abstracteqrip
%ABSTRACTEQRIPHPMIN Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqriphpmin class
%   fmethod.abstracteqriphpmin extends fmethod.abstracteqrip.
%
%    fmethod.abstracteqriphpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.abstracteqriphpmin methods:



methods (Hidden) % possibly private or hidden
  s = validspecobj(this)
end  % possibly private or hidden 

end  % classdef

