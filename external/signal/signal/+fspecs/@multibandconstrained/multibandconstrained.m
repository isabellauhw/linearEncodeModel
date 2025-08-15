classdef multibandconstrained < fspecs.abstractmultibandconstrained
%MULTIBANDCONSTRAINED   Construct an MULTIBANDCONSTRAINED object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.multibandconstrained class
%   fspecs.multibandconstrained extends fspecs.abstractmultibandconstrained.
%
%    fspecs.multibandconstrained properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NBands - Property is of type 'posint user-defined'  
%       B1Frequencies - Property is of type 'double_vector user-defined'  
%       B2Frequencies - Property is of type 'double_vector user-defined'  
%       B3Frequencies - Property is of type 'double_vector user-defined'  
%       B4Frequencies - Property is of type 'double_vector user-defined'  
%       B5Frequencies - Property is of type 'double_vector user-defined'  
%       B6Frequencies - Property is of type 'double_vector user-defined'  
%       B7Frequencies - Property is of type 'double_vector user-defined'  
%       B8Frequencies - Property is of type 'double_vector user-defined'  
%       B9Frequencies - Property is of type 'double_vector user-defined'  
%       B10Frequencies - Property is of type 'double_vector user-defined'  
%       B1Amplitudes - Property is of type 'double_vector user-defined'  
%       B2Amplitudes - Property is of type 'double_vector user-defined'  
%       B3Amplitudes - Property is of type 'double_vector user-defined'  
%       B4Amplitudes - Property is of type 'double_vector user-defined'  
%       B5Amplitudes - Property is of type 'double_vector user-defined'  
%       B6Amplitudes - Property is of type 'double_vector user-defined'  
%       B7Amplitudes - Property is of type 'double_vector user-defined'  
%       B8Amplitudes - Property is of type 'double_vector user-defined'  
%       B9Amplitudes - Property is of type 'double_vector user-defined'  
%       B10Amplitudes - Property is of type 'double_vector user-defined'  
%       B1Ripple - Property is of type 'posdouble user-defined'  
%       B2Ripple - Property is of type 'posdouble user-defined'  
%       B3Ripple - Property is of type 'posdouble user-defined'  
%       B4Ripple - Property is of type 'posdouble user-defined'  
%       B5Ripple - Property is of type 'posdouble user-defined'  
%       B6Ripple - Property is of type 'posdouble user-defined'  
%       B7Ripple - Property is of type 'posdouble user-defined'  
%       B8Ripple - Property is of type 'posdouble user-defined'  
%       B9Ripple - Property is of type 'posdouble user-defined'  
%       B10Ripple - Property is of type 'posdouble user-defined'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       B1Constrained - Property is of type 'bool'  
%       B2Constrained - Property is of type 'bool'  
%       B3Constrained - Property is of type 'bool'  
%       B4Constrained - Property is of type 'bool'  
%       B5Constrained - Property is of type 'bool'  
%       B6Constrained - Property is of type 'bool'  
%       B7Constrained - Property is of type 'bool'  
%       B8Constrained - Property is of type 'bool'  
%       B9Constrained - Property is of type 'bool'  
%       B10Constrained - Property is of type 'bool'  
%
%    fspecs.multibandconstrained methods:
%       designopts - Display the design options.
%       getdesignobj - Get the design object.
%       propstoadd - Return the properties to add to the parent object.
%       set_constraints - PostSet function for the 'constraints' property.
%       validatespecs - Validate the specs


properties (AbortSet, SetObservable, GetObservable)
    %FILTERORDER Property is of type 'posint user-defined' 
    FilterOrder = 30;
    %B1CONSTRAINED Property is of type 'bool' 
    B1Constrained
    %B2CONSTRAINED Property is of type 'bool' 
    B2Constrained
    %B3CONSTRAINED Property is of type 'bool' 
    B3Constrained
    %B4CONSTRAINED Property is of type 'bool' 
    B4Constrained
    %B5CONSTRAINED Property is of type 'bool' 
    B5Constrained
    %B6CONSTRAINED Property is of type 'bool' 
    B6Constrained
    %B7CONSTRAINED Property is of type 'bool' 
    B7Constrained
    %B8CONSTRAINED Property is of type 'bool' 
    B8Constrained
    %B9CONSTRAINED Property is of type 'bool' 
    B9Constrained
    %B10CONSTRAINED Property is of type 'bool' 
    B10Constrained
end

properties (AbortSet, SetObservable, GetObservable, Hidden)
    %PRIVB1CONSTRAINED Property is of type 'bool' (hidden)
    privB1Constrained = false;
    %PRIVB2CONSTRAINED Property is of type 'bool' (hidden)
    privB2Constrained = false;
    %PRIVB3CONSTRAINED Property is of type 'bool' (hidden)
    privB3Constrained = false;
    %PRIVB4CONSTRAINED Property is of type 'bool' (hidden)
    privB4Constrained = false;
    %PRIVB5CONSTRAINED Property is of type 'bool' (hidden)
    privB5Constrained = false;
    %PRIVB6CONSTRAINED Property is of type 'bool' (hidden)
    privB6Constrained = false;
    %PRIVB7CONSTRAINED Property is of type 'bool' (hidden)
    privB7Constrained = false;
    %PRIVB8CONSTRAINED Property is of type 'bool' (hidden)
    privB8Constrained = false;
    %PRIVB9CONSTRAINED Property is of type 'bool' (hidden)
    privB9Constrained = false;
    %PRIVB10CONSTRAINED Property is of type 'bool' (hidden)
    privB10Constrained = false;
end

properties (SetAccess=protected, SetObservable, GetObservable, Hidden)
    %PRIVCONSTRAINTS Property is of type 'bool' (hidden)
    privConstraints
end


    methods  % constructor block
        function this = multibandconstrained(varargin)
        %MULTIBANDCONSTRAINED Construct a MULTIBANDCONSTRAINED object.
        
        
        % this = fspecs.multibandconstrained;
        
        respstr = 'Multi-Band Arbitrary Magnitude';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 2;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % multibandconstrained
        
    end  % constructor block

    methods 
        function set.FilterOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','FilterOrder');    
        obj.FilterOrder = value;
        end

        function value = get.B1Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB1Constrained',[]);
        value = fGet(obj,obj.B1Constrained);
        end
        function set.B1Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','B1Constrained')
        value = logical(value);
        obj.B1Constrained = set_fcn(obj,value,'privB1Constrained',@set_constraints);
        end

        function set.privB1Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB1Constrained')
        value = logical(value); 
        obj.privB1Constrained = value;
        end

        function value = get.B2Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB2Constrained',[]);
        value = fGet(obj,obj.B2Constrained);
        end
        function set.B2Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','B2Constrained')
        value = logical(value);
        obj.B2Constrained = set_fcn(obj,value,'privB2Constrained',@set_constraints);
        end

        function set.privB2Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB2Constrained')
        value = logical(value); 
        obj.privB2Constrained = value;
        end

        function value = get.B3Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB3Constrained',[]);
        value = fGet(obj,obj.B3Constrained);
        end
        function set.B3Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','B3Constrained')
        value = logical(value);
        obj.B3Constrained = set_fcn(obj,value,'privB3Constrained',@set_constraints);
        end

        function set.privB3Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB3Constrained')
        value = logical(value); 
        obj.privB3Constrained = value;
        end

        function value = get.B4Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB4Constrained',[]);
        value = fGet(obj,obj.B4Constrained);
        end
        function set.B4Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','B4Constrained')
        value = logical(value);
        obj.B4Constrained = set_fcn(obj,value,'privB4Constrained',@set_constraints);
        end

        function set.privB4Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB4Constrained')
        value = logical(value); 
        obj.privB4Constrained = value;
        end

        function value = get.B5Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB5Constrained',[]);
        value = fGet(obj,obj.B5Constrained);
        end
        function set.B5Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','B5Constrained')
        value = logical(value);
        obj.B5Constrained = set_fcn(obj,value,'privB5Constrained',@set_constraints);
        end

        function set.privB5Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB5Constrained')
        value = logical(value); 
        obj.privB5Constrained = value;
        end

        function value = get.B6Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB6Constrained',[]);
        value = fGet(obj,obj.B6Constrained);
        end
        function set.B6Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical' ,'numeric'}, {'scalar','nonnan'},'','B6Constrained')
        value = logical(value);
        obj.B6Constrained = set_fcn(obj,value,'privB6Constrained',@set_constraints);
        end

        function set.privB6Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB6Constrained')
        value = logical(value); 
        obj.privB6Constrained = value;
        end

        function value = get.B7Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB7Constrained',[]);
        value = fGet(obj,obj.B7Constrained);
        end
        function set.B7Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar''nonnan'},'','B7Constrained')
        value = logical(value);
        obj.B7Constrained = set_fcn(obj,value,'privB7Constrained',@set_constraints);
        end

        function set.privB7Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB7Constrained')
        value = logical(value); 
        obj.privB7Constrained = value;
        end

        function value = get.B8Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB8Constrained',[]);
        value = fGet(obj,obj.B8Constrained);
        end
        function set.B8Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','B8Constrained')
        value = logical(value);
        obj.B8Constrained = set_fcn(obj,value,'privB8Constrained',@set_constraints);
        end

        function set.privB8Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB8Constrained')
        value = logical(value); 
        obj.privB8Constrained = value;
        end

        function value = get.B9Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB9Constrained',[]);
        value = fGet(obj,obj.B9Constrained);
        end
        function set.B9Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','B9Constrained')
        value = logical(value);
        obj.B9Constrained = set_fcn(obj,value,'privB9Constrained',@set_constraints);
        end

        function set.privB9Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB9Constrained')
        value = logical(value); 
        obj.privB9Constrained = value;
        end

        function value = get.B10Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privB10Constrained',[]);
        value = fGet(obj,obj.B10Constrained);
        end
        function set.B10Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','B10Constrained')
        value = logical(value);
        obj.B10Constrained = set_fcn(obj,value,'privB10Constrained',@set_constraints);
        end

        function set.privB10Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privB10Constrained')
        value = logical(value); 
        obj.privB10Constrained = value;
        end

        function set.privConstraints(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privConstraints')
        value = logical(value); 
        obj.privConstraints = value;
        end

    end   % set and get functions 

    methods  % public methods
    s = designopts(this,dmethod)
    designobj = getdesignobj(~,str)
    p = propstoadd(this)
    constraints = set_constraints(this,constraints)
    [N,F,E,A,nfpts,Fs,normFreqFlag] = validatespecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(~)
end  % possibly private or hidden 

end  % classdef

% -------------------------------------------------------------------------
function value = get_fcn(this, privPropName, getfcn)

  % Get the value from the hidden property.
  value = this.(privPropName);

  if ~isempty(getfcn)
      value = feval(getfcn, this, value);
  end
end

% -------------------------------------------------------------------------
function value = set_fcn(this, value, privPropName, setfcn)

  % Cache the old value.
  oldValue = this.(privPropName);

  % Save the new value in the hidden property.
  this.(privPropName) = value;

  % Call the set method and pass in the old value.
  if ~isempty(setfcn)
      feval(setfcn, this, oldValue);
  end
end
