classdef bpstop < fspecs.abstractspecwithordnfs
%BPSTOP   Construct an BPSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpstop class
%   fspecs.bpstop extends fspecs.abstractspecwithordnfs.
%
%    fspecs.bpstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpstop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude properties.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.


properties (AbortSet, SetObservable, GetObservable)
    %FSTOP1 Property is of type 'posdouble user-defined' 
    Fstop1 = 0.35;
    %FSTOP2 Property is of type 'posdouble user-defined' 
    Fstop2 = 0.65;
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function h = bpstop(varargin)
        %BPSTOP   Construct a BPSTOP object.
        %   H = BPSTOP(N,Fstop1,Fstop2,Astop,Fs) constructs a bandpass filter
        %   specifications object with stopband-edge specifications.
        %
        %   N is the filter order and must be an even positive integer.
        %
        %   Fstop1 is the lower stopband-edge frequency and must be a positive
        %   scalar between 0 and 1 if no sampling frequency is specified or between
        %   0 and Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fstop2 is the higher stopband-edge frequency and must be a positive
        %   scalar larger than Fstop1 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Astop is the minimum stopband attenuation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        narginchk(0,5);
        
        % h = fspecs.bpstop;
        constructor(h,varargin{:});
        h.ResponseType = 'Bandpass with stopband-edge specifications.';
        
        
        
        end  % bpstop
        
    end  % constructor block

    methods 
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

        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
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

