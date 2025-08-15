classdef diffordmbast < fspecs.abstractdiffordmb
%DIFFORDMBAST   Construct an DIFFORDMBAST object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.diffordmbast class
%   fspecs.diffordmbast extends fspecs.abstractdiffordmb.
%
%    fspecs.diffordmbast properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.diffordmbast methods:
%       getdesignobj - Get the designobj.
%       magprops - Returns the passband and stopband magnitude properties.
%       measureinfo - Return a structure of information for the measurements.
%       thisgetspecs - Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function this = diffordmbast(varargin)
        %DIFFORDMBAST Construct a DIFFORDMBAST object.
        
        
        % this = fspecs.diffordmbast;
        
        this.ResponseType = 'Multi-band Differentiator with filter order';
        
        % Defaults
        this.FilterOrder = 30;
        this.Fpass = .7;
        this.Fstop = .9;  
        this.Astop = 60;
        
        this.setspecs(varargin{:});
        
        
        end  % diffordmbast
        
    end  % constructor block

    methods 
        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(~,str)
    [p,s] = magprops(~)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

