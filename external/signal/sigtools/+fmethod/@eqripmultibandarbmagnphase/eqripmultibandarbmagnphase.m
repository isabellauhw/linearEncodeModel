classdef eqripmultibandarbmagnphase < fmethod.abstracteqripmultibandarbresponse
%EQRIPMULTIBANDARBMAGNPHASE   Construct an EQRIPMULTIBANDARBMAGNPHASE
%object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqripmultibandarbmagnphase class
%   fmethod.eqripmultibandarbmagnphase extends fmethod.abstracteqripmultibandarbresponse.
%
%    fmethod.eqripmultibandarbmagnphase properties:
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
%    fmethod.eqripmultibandarbmagnphase methods:
%       actualdesign - Perform the actual design.
%       getexamples -   Get the examples.
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function this = eqripmultibandarbmagnphase

  % this = fmethod.eqripmultibandarbmagnphase;

  this.DesignAlgorithm = 'Equiripple';


  end  % eqripmultibandarbmagnphase

end  % constructor block

methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 

end  % classdef

