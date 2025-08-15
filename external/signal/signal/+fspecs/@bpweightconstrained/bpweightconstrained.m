classdef bpweightconstrained < fspecs.abstractbpweight
%BPWEIGHTCONSTRAINED   Construct an BPWEIGHTCONSTRAINED object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpweightconstrained class
%   fspecs.bpweightconstrained extends fspecs.abstractbpweight.
%
%    fspecs.bpweightconstrained properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%       Stopband1Constrained - Property is of type 'bool'  
%       PassbandConstrained - Property is of type 'bool'  
%       Stopband2Constrained - Property is of type 'bool'  
%       Astop1 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpweightconstrained methods:
%       designopts - Display the design options.
%       getdesignobj - Get the designobj.
%       measureinfo - Return a structure of information for the measurements.
%       propstoadd - Return the properties to add to the parent object.
%       set_constraints - PostSet function for the 'constraints' property.
%       thisprops2add - Return the properties to add to the parent object.


properties (AbortSet, SetObservable, GetObservable)
    %STOPBAND1CONSTRAINED Property is of type 'bool' 
    Stopband1Constrained 
    %PASSBANDCONSTRAINED Property is of type 'bool' 
    PassbandConstrained 
    %STOPBAND2CONSTRAINED Property is of type 'bool' 
    Stopband2Constrained
    %ASTOP1 Property is of type 'posdouble user-defined' 
    Astop1 = 60;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
    %ASTOP2 Property is of type 'posdouble user-defined' 
    Astop2 = 60;
end

properties (AbortSet, SetObservable, GetObservable, Hidden)
    %PRIVSTOPBAND1CONSTRAINED Property is of type 'bool' (hidden)
    privStopband1Constrained = false;
    %PRIVPASSBANDCONSTRAINED Property is of type 'bool' (hidden)
    privPassbandConstrained = false;
    %PRIVSTOPBAND2CONSTRAINED Property is of type 'bool' (hidden)
    privStopband2Constrained = false;
end

properties (SetAccess=protected, SetObservable, GetObservable, Hidden)
    %PRIVCONSTRAINTS Property is of type 'bool' (hidden)
    privConstraints
end


    methods  % constructor block
        function this = bpweightconstrained(varargin)
        %BPWEIGHTCONSTRAINED Construct a BPWEIGHTCONSTRAINED object.
        
        
        % this = fspecs.bpweightconstrained;
        respstr = 'Bandpass';
        fstart = 2;
        fstop = 5;
        nargsnoFs = 8;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bpweightconstrained
        
    end  % constructor block

    methods 
        function value = get.Stopband1Constrained(obj)
        fGet = @(this,value) get_fcn(this,'privStopband1Constrained',[]);
        value = fGet(obj,obj.Stopband1Constrained);
        end
        
        function set.Stopband1Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','Stopband1Constrained')
        value = logical(value);
        obj.Stopband1Constrained = set_fcn(obj,value,'privStopband1Constrained',@set_constraints);
        end

        function set.privStopband1Constrained(obj,value)
         % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privStopband1Constrained')
        value = logical(value);
        obj.privStopband1Constrained = value;
        end

        function value = get.PassbandConstrained(obj)
        fGet = @(this,value)get_fcn(this,'privPassbandConstrained',[]);
        value = fGet(obj,obj.PassbandConstrained);
        end
        
        function set.PassbandConstrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','PassbandConstrained')
        value = logical(value);
        obj.PassbandConstrained = set_fcn(obj,value,'privPassbandConstrained',@set_constraints);
        end

        function set.privPassbandConstrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','privPassbandConstrained')
        value = logical(value);
        obj.privPassbandConstrained = value;
        end

        function value = get.Stopband2Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privStopband2Constrained',[]);
        value = fGet(obj,obj.Stopband2Constrained);
        end
        function set.Stopband2Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','Stopband2Constrained')
        value = logical(value);
        obj.Stopband2Constrained = set_fcn(obj,value,'privStopband2Constrained',@set_constraints);
        end

        function set.privStopband2Constrained(obj,value)
        % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privStopband2Constrained')
        value = logical(value);   
        obj.privStopband2Constrained = value;
        end

        function set.Astop1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop1');
        value = double(value);
        obj.Astop1 = value;
        end

        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
        end

        function set.Astop2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop2');
        value = double(value);
        obj.Astop2 = value;
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
    minfo = measureinfo(this)
    p = propstoadd(this)
    constraints = set_constraints(this,constraints)
    p = thisprops2add(~,varargin)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(~)
    [pass,stop] = magprops(~)
    specs = thisgetspecs(this)
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

  % Call the set method and pass in the old value. This set method is
  % called after the property is modified so that it is a post-set method.
  % The function 'set_constraints' is called, which modifies a property
  % with a listener attached. The listener will add ripple properties
  % dynamically if the band has been specified as constrained. 
  if ~isempty(setfcn)
      feval(setfcn, this, oldValue);
  end
end
