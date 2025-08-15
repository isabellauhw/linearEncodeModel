classdef (Abstract) abstractarbresponse < fdesign.abstracttypewspecs
%ABSTRACTARBRESPONSE Abstract constructor produces an error.

%   Copyright 2004-2015 The MathWorks, Inc.

%fdesign.abstractarbresponse class
%   fdesign.abstractarbresponse extends fdesign.abstracttypewspecs.
%
%    fdesign.abstractarbresponse properties:
%       Response - Property is of type 'ustring' (read only) 
%       Description - Property is of type 'string vector' (read only) 
%
%    fdesign.abstractarbresponse methods:
%       setcurrentspecs - Pre-Set function for the current specs.


properties (Access=protected, AbortSet, SetObservable, GetObservable)
  %BANDLISTENER Property is of type 'handle.listener vector'
  BandListener = [];
  %CONSTRAINTLISTENER Property is of type 'handle.listener vector'
  ConstraintListener = [];
end


methods 
  function set.BandListener(obj,value)
  % DataType = 'handle.listener vector'
    validateattributes(value,{'event.proplistener'}, {'vector'},'','BandListener')
    obj.BandListener = value;
  end

  function set.ConstraintListener(obj,value)
  % DataType = 'handle.listener vector'
    validateattributes(value,{'event.proplistener'}, {'vector'},'','ConstraintListener')
    obj.ConstraintListener = value;
  end
end   % set and get functions 

methods  % public methods
  newspecs = setcurrentspecs(this,newspecs)
end  % public methods 


methods (Hidden) % possibly private or hidden
  b = haspassbandzoom(~)
end  % possibly private or hidden 

end  % classdef

