classdef (Abstract) abstracteqripmultibandarbmagord < fmethod.abstracteqripmultibandarbresponse
%ABSTRACTEQRIPMULTIBANDARBMAGORD Construct an ABSTRACTEQRIPMULTIBANDARBMAGORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstracteqripmultibandarbmagord class
%   fmethod.abstracteqripmultibandarbmagord extends fmethod.abstracteqripmultibandarbresponse.
%
%    fmethod.abstracteqripmultibandarbmagord properties:
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
%    fmethod.abstracteqripmultibandarbmagord methods:
%       getexamples - Get the examples.
%       multiband - Frequency response function called by CFIRPM (twice)
%       validspecobj - Return the name of the valid specification object.


properties (SetAccess=protected, AbortSet, SetObservable, GetObservable, Hidden)
  %PRIVCONSTRAINEDBANDS Property is of type 'double_vector user-defined' (hidden)
  privConstrainedBands = [];
  %PRIVFS Property is of type 'double_vector user-defined' (hidden)
  privFs = [];
  %PRIVACTUALNORMALIZEDFREQ Property is of type 'bool' (hidden)
  privActualNormalizedFreq
end


methods 
  function set.privConstrainedBands(obj,value)
  validateattributes(value,{'double'}, {'vector'},'','privConstrainedBands')
  obj.privConstrainedBands = value;
  end
  %------------------------------------------------------------------------
  function set.privFs(obj,value)
  validateattributes(value,{'double'}, {'vector'},'','privFs')
  obj.privFs = value;
  end
  %------------------------------------------------------------------------
  function set.privActualNormalizedFreq(obj,value)
  validateattributes(value,{'logical'}, {'scalar'},'','privActualNormalizedFreq')
  obj.privActualNormalizedFreq = value;
  end

end   % set and get functions 

methods  % public methods
  examples = getexamples(~)
  [DH,DW] = multiband(~,N,FF,GF,~,A,F,myW,iscomplex,delay)
  vso = validspecobj(~)
end  % public methods 

end  % classdef

