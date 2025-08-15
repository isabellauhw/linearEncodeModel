classdef (Abstract) abstracteqripbs < fmethod.abstracteqrip
%ABSTRACTEQRIPBS Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqripbs class
%   fmethod.abstracteqripbs extends fmethod.abstracteqrip.
%
%    fmethod.abstracteqripbs properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.abstracteqripbs methods:
%       getfbandstomeas - RE  Get frequency bands, and attenuation and ripple
%       getvalidstructs - Get the validstructs.



methods  % public methods
  [stopbands,passbands,Astop,Apass] = getfbandstomeas(~,hspecs)
  validstructs = getvalidstructs(~)
end  % public methods 

end  % classdef

