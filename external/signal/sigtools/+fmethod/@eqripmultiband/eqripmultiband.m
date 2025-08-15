classdef eqripmultiband < fmethod.abstracteqripmultibandarbmagord
%EQRIPMULTIBAND   Construct an EQRIPMULTIBAND object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqripmultiband class
%   fmethod.eqripmultiband extends fmethod.abstracteqripmultibandarbmagord.
%
%    fmethod.eqripmultiband properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       B1Weights - Property is of type 'double_vector user-defined'  
%       B2Weights - Property is of type 'double_vector user-defined'  
%       B3Weights - Property is of type 'double_vector user-defined'  
%       B4Weights - Property is of type 'double_vector user-defined'  
%       B5Weights - Property is of type 'double_vector user-defined'  
%       B6Weights - Property is of type 'double_vector user-defined'  
%       B7Weights - Property is of type 'double_vector user-defined'  
%       B8Weights - Property is of type 'double_vector user-defined'  
%       B9Weights - Property is of type 'double_vector user-defined'  
%       B10Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.eqripmultiband methods:
%       actualdesign - Perform the actual design.



methods  % constructor block
  function this = eqripmultiband

  % this = fmethod.eqripmultiband;

  this.DesignAlgorithm = 'Equiripple';


  end  % eqripmultiband

end  % constructor block

methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
end  % public methods 


methods (Hidden) % possibly private or hidden
  m = thiscomplexmethod(~)
  m = thisrealmethod(~)
end  % possibly private or hidden 

end  % classdef

