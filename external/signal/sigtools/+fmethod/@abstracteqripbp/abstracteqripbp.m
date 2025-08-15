classdef (Abstract) abstracteqripbp < fmethod.abstracteqrip
%ABSTRACTEQRIPBP Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.
  
%fmethod.abstracteqripbp class
%   fmethod.abstracteqripbp extends fmethod.abstracteqrip.
%
%    fmethod.abstracteqripbp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.abstracteqripbp methods:
%       getfbandstomeas - RE Get frequency bands, and attenuation and ripple
%       getvalidstructs - Get the validstructs.



methods  % public methods
  [stopbands,passbands,Astop,Apass] = getfbandstomeas(~,hspecs)
  validstructs = getvalidstructs(~)
end  % public methods 

end  % classdef

