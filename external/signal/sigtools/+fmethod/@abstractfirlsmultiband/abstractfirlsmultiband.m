classdef (Abstract) abstractfirlsmultiband < fmethod.abstractfirlsarbmag
%ABSTRACTFIRLSMULTIBAND   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractfirlsmultiband class
%   fmethod.abstractfirlsmultiband extends fmethod.abstractfirlsarbmag.
%
%    fmethod.abstractfirlsmultiband properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
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
%    fmethod.abstractfirlsmultiband methods:
%       getdesiredresponse - Get the desiredresponse.


properties (AbortSet, SetObservable, GetObservable)
  %B1WEIGHTS Property is of type 'double_vector user-defined' 
  B1Weights = 1;
  %B2WEIGHTS Property is of type 'double_vector user-defined' 
  B2Weights = 1;
  %B3WEIGHTS Property is of type 'double_vector user-defined' 
  B3Weights = 1;
  %B4WEIGHTS Property is of type 'double_vector user-defined' 
  B4Weights = 1;
  %B5WEIGHTS Property is of type 'double_vector user-defined' 
  B5Weights = 1;
  %B6WEIGHTS Property is of type 'double_vector user-defined' 
  B6Weights = 1;
  %B7WEIGHTS Property is of type 'double_vector user-defined' 
  B7Weights = 1;
  %B8WEIGHTS Property is of type 'double_vector user-defined' 
  B8Weights = 1;
  %B9WEIGHTS Property is of type 'double_vector user-defined' 
  B9Weights = 1;
  %B10WEIGHTS Property is of type 'double_vector user-defined' 
  B10Weights = 1;
end

properties (SetAccess=protected, AbortSet, SetObservable, GetObservable, Hidden)
  %PRIVNBANDS Property is of type 'int' (hidden)
  privNBands
end


methods 
  function set.B1Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B1Weights')
  obj.B1Weights = value;
  end
  %------------------------------------------------------------------------
  function set.B2Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B2Weights')
  obj.B2Weights = value;
  end
  %------------------------------------------------------------------------
  function set.B3Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B3Weights')
  obj.B3Weights = value;
  end
  %------------------------------------------------------------------------
  function set.B4Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B4Weights')
  obj.B4Weights = value;
  end
  %------------------------------------------------------------------------
  function set.B5Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B5Weights')
  obj.B5Weights = value;
  end
  %------------------------------------------------------------------------
  function set.B6Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B6Weights')
  obj.B6Weights = value;
  end
  %------------------------------------------------------------------------
  function set.B7Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B7Weights')
  obj.B7Weights = value;
  end
  %------------------------------------------------------------------------
  function set.B8Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B8Weights')
  obj.B8Weights = value;
  end
  %------------------------------------------------------------------------
  function set.B9Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B9Weights')
  obj.B9Weights = value;
  end
  %------------------------------------------------------------------------
  function set.B10Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','B10Weights')
  obj.B10Weights = value;
  end
  %------------------------------------------------------------------------
  function set.privNBands(obj,value)
  validateattributes(value,{'numeric'},{'scalar'},'','privNBands')
  value = round(value); %  round to obtain an integer
  obj.privNBands = value;
  end

end   % set and get functions 

methods  % public methods
  [N,F,D,W,nfpts] = getdesiredresponse(this,hspecs)
end  % public methods 


methods (Hidden) % possibly private or hidden
  s = thisdesignopts(this,s,N)
end  % possibly private or hidden 

end  % classdef

