classdef bpmin < fspecs.abstractspecwithfs
%BPMIN   Construct an BPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpmin class
%   fspecs.bpmin extends fspecs.abstractspecwithfs.
%
%    fspecs.bpmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%       Astop1 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpmin methods:
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude properties.
%       measure -   Measure the filter.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.
%       setspecs -   Set the specs.
%       thisvalidate -   Checks if this object is valid.


properties (AbortSet, SetObservable, GetObservable)
    %FSTOP1 Property is of type 'posdouble user-defined' 
    Fstop1 = 0.35;
    %FPASS1 Property is of type 'posdouble user-defined' 
    Fpass1 = 0.45;
    %FPASS2 Property is of type 'posdouble user-defined' 
    Fpass2 = 0.55;
    %FSTOP2 Property is of type 'posdouble user-defined' 
    Fstop2 = 0.65;
    %ASTOP1 Property is of type 'posdouble user-defined' 
    Astop1 = 60;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
    %ASTOP2 Property is of type 'posdouble user-defined' 
    Astop2 = 60;
end


    methods  % constructor block
        function h = bpmin(varargin)
        %BPMIN   Construct a BPMIN object.
        %   H = BPMIN(Fstop1,Fpass1,Fpass2,Fstop2,Astop1,Apass,Astop2,Fs)
        %   constructs a minimum-order bandpass filter specifications object.
        %
        %   Fstop1 is the lower stopband-edge frequency and must be a positive
        %   scalar   between 0 and 1 if no sampling frequency is specified or
        %   between 0 and Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fpass1 is the lower passband-edge frequency and must be a positive
        %   scalar greater than Fstop1 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Fpass2 is the higher passband-edge frequency and must be a positive
        %   scalar greater than Fpass1 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Fstop2 is the higher stopband-edge frequency and must be a positive
        %   scalar greater than Fpass2 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Astop1 is the minimum lower-stopband attenuation in dB. It must be a
        %   positive scalar.
        %
        %   Apass is the maximum passband deviation in dB. It must be a positive
        %   scalar.
        %
        %   Astop2 is the minimum higher-stopband attenuation in dB. It must be a
        %   positive scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % h = fspecs.bpmin;
        respstr = 'Minimum-order bandpass';
        fstart = 1;
        fstop = 4;
        nargsnoFs = 7;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        
        
        end  % bpmin
        
    end  % constructor block

    methods 
        function set.Fstop1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop1');
        value = double(value);
        obj.Fstop1 = value;
        end

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

        function set.Fstop2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop2');
        value = double(value);
        obj.Fstop2 = value;
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

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    [p,s] = magprops(this)
    hm = measure(this,Hd,varargin)
    minfo = measureinfo(this)
    p = props2normalize(h)
    setspecs(this,varargin)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    ha = analogresp(h)
    c = cparam(h)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

