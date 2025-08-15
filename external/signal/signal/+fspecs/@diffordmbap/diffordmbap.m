classdef diffordmbap < fspecs.abstractdiffordmb
%DIFFORDMBAP   Construct an DIFFORDMBAP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.diffordmbap class
%   fspecs.diffordmbap extends fspecs.abstractdiffordmb.
%
%    fspecs.diffordmbap properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.diffordmbap methods:
%       getdesignobj - Get the designobj.
%       magprops - Returns the passband and stopband magnitude properties.
%       measureinfo - Return a structure of information for the measurements.
%       thisgetspecs - Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods  % constructor block
        function this = diffordmbap(varargin)
        %DIFFORDMBAP Construct a DIFFORDMBAP object.
        
        
        % this = fspecs.diffordmbap;
        
        this.ResponseType = 'Multi-band Differentiator with filter order';
        
        % Defaults
        this.FilterOrder = 30;
        this.Fpass = .7;
        this.Fstop = .9;  
        this.Apass = 1;
        
        this.setspecs(varargin{:});
        
        
        end  % diffordmbap
        
    end  % constructor block

    methods 
        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(~,str)
    [p,s] = magprops(~)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

