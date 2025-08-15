classdef bsweightconstrained < fspecs.abstractbsweight
%BSWEIGHTCONSTRAINED   Construct an BSWEIGHTCONSTRAINED object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bsweightconstrained class
%   fspecs.bsweightconstrained extends fspecs.abstractbsweight.
%
%    fspecs.bsweightconstrained properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Passband1Constrained - Property is of type 'bool'  
%       StopbandConstrained - Property is of type 'bool'  
%       Passband2Constrained - Property is of type 'bool'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Apass1 - Property is of type 'posdouble user-defined'  
%       Apass2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bsweightconstrained methods:
%       designopts - Display the design options.
%       getdesignobj - Get the designobj.
%       measureinfo - Return a structure of information for the measurements.
%       propstoadd - Return the properties to add to the parent object.
%       set_constraints - PostSet function for the 'constraints' property.
%       thisprops2add - Return the properties to add to the parent object.


properties (AbortSet, SetObservable, GetObservable)
    %PASSBAND1CONSTRAINED Property is of type 'bool' 
    Passband1Constrained 
    %STOPBANDCONSTRAINED Property is of type 'bool' 
    StopbandConstrained 
    %PASSBAND2CONSTRAINED Property is of type 'bool' 
    Passband2Constrained 
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
    %APASS1 Property is of type 'posdouble user-defined' 
    Apass1 = 1;
    %APASS2 Property is of type 'posdouble user-defined' 
    Apass2 = 1;
end

properties (AbortSet, SetObservable, GetObservable, Hidden)
    %PRIVPASSBAND1CONSTRAINED Property is of type 'bool' (hidden)
    privPassband1Constrained = false;
    %PRIVSTOPBANDCONSTRAINED Property is of type 'bool' (hidden)
    privStopbandConstrained = false;
    %PRIVPASSBAND2CONSTRAINED Property is of type 'bool' (hidden)
    privPassband2Constrained = false;
end

properties (SetAccess=protected, SetObservable, GetObservable, Hidden)
    %PRIVCONSTRAINTS Property is of type 'bool' (hidden)
    privConstraints
end


    methods  % constructor block
        function this = bsweightconstrained(varargin)
        %BSWEIGHTCONSTRAINED Construct a BSWEIGHTCONSTRAINED object.
        
        
        % this = fspecs.bsweightconstrained;
        
        respstr = 'Bandstop';
        fstart = 2;
        fstop = 5;
        nargsnoFs = 8;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bsweightconstrained
        
    end  % constructor block

    methods 
        function value = get.Passband1Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privPassband1Constrained',[]);
        value = fGet(obj,obj.Passband1Constrained);
        end
        function set.Passband1Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','Passband1Constrained')
        value = logical(value);
        obj.Passband1Constrained = set_fcn(obj,value,'privPassband1Constrained',@set_constraints);
        end

        function set.privPassband1Constrained(obj,value)
        % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privPassband1Constrained')
        value = logical(value);    
        obj.privPassband1Constrained = value;
        end

        function value = get.StopbandConstrained(obj)
        fGet = @(this,value)get_fcn(this,'privStopbandConstrained',[]);
        value = fGet(obj,obj.StopbandConstrained);
        end
        function set.StopbandConstrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','StopbandConstrained')
        value = logical(value);
        obj.StopbandConstrained = set_fcn(obj,value,'privStopbandConstrained',@set_constraints);
        end

        function set.privStopbandConstrained(obj,value)
        % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privStopbandConstrained')
        value = logical(value);
        obj.privStopbandConstrained = value;
        end

        function value = get.Passband2Constrained(obj)
        fGet = @(this,value)get_fcn(this,'privPassband2Constrained',[]);
        value = fGet(obj,obj.Passband2Constrained);
        end
        function set.Passband2Constrained(obj,value)
            % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','Passband2Constrained')
        value = logical(value);
        obj.Passband2Constrained = set_fcn(obj,value,'privPassband2Constrained',@set_constraints);
        end

        function set.privPassband2Constrained(obj,value)
        % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privPassband2Constrained')
        value = logical(value);
        obj.privPassband2Constrained = value;
        end

        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
        end

        function set.Apass1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass1');
        value = double(value);
        obj.Apass1 = value;
        end

        function set.Apass2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass2');
        value = double(value);
        obj.Apass2 = value;
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

  % Call the set method and pass in the old value.
  if ~isempty(setfcn)
      feval(setfcn, this, oldValue);
  end
end

