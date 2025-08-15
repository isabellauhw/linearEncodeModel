classdef invfreqz < fmethod.abstractiir
%INVFREQZ   Construct an INVFREQZ object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.invfreqz class
%   fmethod.invfreqz extends fmethod.abstractiir.
%
%    fmethod.invfreqz properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.invfreqz methods:
%       actualdesign - Perform the actual design.
%       getexamples -   Get the examples.
%       getfilterorders -   Get the filterorders.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Return the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
    %WEIGHTS Property is of type 'double_vector user-defined' 
    Weights = 1;
end


methods  % constructor block
    function this = invfreqz

    % this = fmethod.invfreqz;
    this.FilterStructure = 'df2';
    this.DesignAlgorithm = 'IIR least-squares';


    end  % invfreqz

end  % constructor block

methods 
  function set.Weights(obj,value)
  validateattributes(value,{'double'},{'vector'},'','Weights')
  obj.Weights = value;
  end

end   % set and get functions 

methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
  examples = getexamples(this)
  [NumOrder,DenOrder] = getfilterorders(this,hspecs)
  validstructs = getvalidstructs(this)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

