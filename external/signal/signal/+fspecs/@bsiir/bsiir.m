classdef bsiir < fspecs.abstractspecwithfs
%BSIIR   Construct an BSIIR object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bsiir class
%   fspecs.bsiir extends fspecs.abstractspecwithfs.
%
%    fspecs.bsiir properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NumOrder - Property is of type 'posint user-defined'  
%       DenOrder - Property is of type 'posint user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bsiir methods:
%       getdesignobj -   Get the design object.
%       measure -   Get the measurements.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Return the property name to normalize.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %NUMORDER Property is of type 'posint user-defined' 
    NumOrder = 8;
    %DENORDER Property is of type 'posint user-defined' 
    DenOrder = 8;
    %FPASS1 Property is of type 'posdouble user-defined' 
    Fpass1 = 0.35;
    %FSTOP1 Property is of type 'posdouble user-defined' 
    Fstop1 = 0.45;
    %FSTOP2 Property is of type 'posdouble user-defined' 
    Fstop2 = 0.55;
    %FPASS2 Property is of type 'posdouble user-defined' 
    Fpass2 = 0.65;
end


    methods  % constructor block
        function this = bsiir(varargin)
        %BSIIR   Construct a BSIIR object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bsiir;
        respstr = 'Bandstop';
        fstart = 3;
        fstop = 5;
        nargsnoFs = 8;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bsiir
        
    end  % constructor block

    methods 
        function set.NumOrder(obj,value)
        % User-defined DataType = nonnegint
        validateattributes(value,{'numeric'},...
          {'scalar','nonnegative','integer'},'','NumOrder');    
        obj.NumOrder = value;
        end

        function set.DenOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','DenOrder');    
        obj.DenOrder = value;
        end

        function set.Fpass1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass1');
        value = double(value);
        obj.Fpass1 = value;
        end

        function set.Fstop1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop1');
        value = double(value);
        obj.Fstop1 = value;
        end

        function set.Fstop2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop2');
        value = double(value);
        obj.Fstop2 = value;
        end

        function set.Fpass2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass2');
        value = double(value);
        obj.Fpass2 = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(this,str)
    measurements = measure(this,hd,hm)
    minfo = measureinfo(this)
    p = props2normalize(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(this)
    p = propstoadd(this,varargin)
end  % possibly private or hidden 

end  % classdef

