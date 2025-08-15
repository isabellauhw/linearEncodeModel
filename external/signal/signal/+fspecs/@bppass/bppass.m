classdef bppass < fspecs.abstractspecwithordnfs
%BPPASS   Construct an BPPASS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bppass class
%   fspecs.bppass extends fspecs.abstractspecwithordnfs.
%
%    fspecs.bppass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.bppass methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude properties.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.


properties (AbortSet, SetObservable, GetObservable)
    %FPASS1 Property is of type 'posdouble user-defined' 
    Fpass1 = 0.45;
    %FPASS2 Property is of type 'posdouble user-defined' 
    Fpass2 = 0.55;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods  % constructor block
        function h = bppass(varargin)
        %BPPASS   Construct a BPPASS object.
        %   H = BPPASS(N,Fpass1,Fpass2,Apass,Fs) constructs a bandpass filter
        %   specifications object with passband-edge specifications.
        %
        %   N is the filter order and must be an even positive integer.
        %
        %   Fpass1 is the lower passband-edge frequency and must be a positive
        %   scalar between 0 and 1 if no sampling frequency is specified or between
        %   0 and Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fpass2 is the higher passband-edge frequency and must be a positive
        %   scalar larger than Fpass1 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Apass is the maximum passband deviation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        narginchk(0,5);
        
        % h = fspecs.bppass;
        constructor(h,varargin{:});
        h.ResponseType = 'Bandpass with passband-edge specifications.';
        
        
        
        end  % bppass
        
    end  % constructor block

    methods 
        function set.Fpass1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass1');
        value = double(value);        
        obj.Fpass1 = value;
        end

        function set.Fpass2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass2');
        value = double(value);        
        obj.Fpass2 = value;
        end

        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);        
        obj.Apass = value;
        end

    end   % set and get functions 

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    [p,s] = magprops(this)
    minfo = measureinfo(this)
    p = props2normalize(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    constructor(h,varargin)
    c = cparam(h)
    specs = thisgetspecs(this)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % possibly private or hidden 

end  % classdef

