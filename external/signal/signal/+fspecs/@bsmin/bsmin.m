classdef bsmin < fspecs.abstractspecwithfs
%BSMIN   Construct an BSMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bsmin class
%   fspecs.bsmin extends fspecs.abstractspecwithfs.
%
%    fspecs.bsmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Apass1 - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Apass2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bsmin methods:
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude properties.
%       measure -   Measure the filter.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.
%       setspecs -   Set the specs.
%       thisvalidate -   Checks if this object is valid.


properties (AbortSet, SetObservable, GetObservable)
    %FPASS1 Property is of type 'posdouble user-defined' 
    Fpass1 = 0.35;
    %FSTOP1 Property is of type 'posdouble user-defined' 
    Fstop1 = 0.45;
    %FSTOP2 Property is of type 'posdouble user-defined' 
    Fstop2 = 0.55;
    %FPASS2 Property is of type 'posdouble user-defined' 
    Fpass2 = 0.65;
    %APASS1 Property is of type 'posdouble user-defined' 
    Apass1 = 1;
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
    %APASS2 Property is of type 'posdouble user-defined' 
    Apass2 = 1;
end


    methods  % constructor block
        function h = bsmin(varargin)
        %BSMIN   Construct a BSMIN object.
        %   H = BPMIN(Fpass1,Fstop1,Fstop2,Fpass2,Apass1,Astop,Apass2,Fs)
        %   constructs a minimum-order bandstop filter specifications object.
        %
        %   Fpass1 is the lower passband-edge frequency and must be a positive
        %   scalar   between 0 and 1 if no sampling frequency is specified or
        %   between 0 and Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fstop1 is the lower stopband-edge frequency and must be a positive
        %   scalar greater than Fpass1 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Fstop2 is the higher stopband-edge frequency and must be a positive
        %   scalar greater than Fstop1 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Fpass2 is the higher passband-edge frequency and must be a positive
        %   scalar greater than Fstop2 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Apass1 is the maximum lower-passband deviation in dB. It must be a
        %   positive scalar.
        %
        %   Astop is the minimum stopband attenuation in dB. It must be a positive
        %   scalar.
        %
        %   Apass2 is the maximum higher-passband deviation in dB. It must be a
        %   positive scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % h = fspecs.bsmin;
        respstr = 'Minimum-order bandstop';
        fstart = 1;
        fstop = 4;
        nargsnoFs = 7;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        
        end  % bsmin
        
    end  % constructor block

    methods 
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

        function set.Apass1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass1');
        value = double(value);
        obj.Apass1 = value;
        end

        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
        end

        function set.Apass2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass2');
        value = double(value);
        obj.Apass2 = value;
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
    p = propstoadd(this,varargin)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

