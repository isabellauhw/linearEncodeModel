classdef lpiir < fspecs.abstractspecwithfs
%LPIIR   Construct an LPIIR object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpiir class
%   fspecs.lpiir extends fspecs.abstractspecwithfs.
%
%    fspecs.lpiir properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NumOrder - Property is of type 'posint user-defined'  
%       DenOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpiir methods:
%       getdesignobj -   Get the design object.
%       measure -   Get the measurements.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %NUMORDER Property is of type 'posint user-defined' 
    NumOrder = 8;
    %DENORDER Property is of type 'posint user-defined' 
    DenOrder = 8;
    %FPASS Property is of type 'posdouble user-defined' 
    Fpass = 0.45;
    %FSTOP Property is of type 'posdouble user-defined' 
    Fstop = 0.55;
end


    methods  % constructor block
        function this = lpiir(varargin)
        %LPIIR   Construct a LPIIR object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.lpiir;
        
        respstr = 'Lowpass';
        fstart = 3;
        fstop = 4;
        nargsnoFs = 6;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % lpiir
        
    end  % constructor block

    methods 
        function set.NumOrder(obj,value)
        % User-defined DataType = 'nonnegint'
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

        function set.Fpass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass');
        value = double(value);
        obj.Fpass = value;
        end

        function set.Fstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop');
        value = double(value);
        obj.Fstop = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(this,str)
    measurements = measure(this,hd,hm)
    minfo = measureinfo(this)
    p = props2normalize(h)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(this)
end  % possibly private or hidden 

end  % classdef

