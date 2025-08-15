classdef (Abstract) abstractfirlssbarbmag < fmethod.abstractfirlsarbmag
%ABSTRACTFIRLSSBARBMAG   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractfirlssbarbmag class
%   fmethod.abstractfirlssbarbmag extends fmethod.abstractfirlsarbmag.
%
%    fmethod.abstractfirlssbarbmag properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.abstractfirlssbarbmag methods:
%       getdesiredresponse - Get the desiredresponse.


properties (AbortSet, SetObservable, GetObservable)
  %WEIGHTS Property is of type 'double_vector user-defined' 
  Weights = 1;
end


methods 
  function set.Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','Weights')
  obj.Weights = value;
  end

end   % set and get functions 

methods  % public methods
  [N,F,D,W,nfpts] = getdesiredresponse(this,hspecs)
end  % public methods 

end  % classdef

