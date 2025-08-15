classdef bppassastop < fspecs.bppass
%BPPASSASTOP   Construct an BPPASSASTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bppassastop class
%   fspecs.bppassastop extends fspecs.bppass.
%
%    fspecs.bppassastop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop1 - Property is of type 'posdouble user-defined'  
%       Astop2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bppassastop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude properties.
%       measureinfo -   Return a structure of information for the measurements.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP1 Property is of type 'posdouble user-defined' 
    Astop1 = 60;
    %ASTOP2 Property is of type 'posdouble user-defined' 
    Astop2 = 60;
end


    methods  % constructor block
        function h = bppassastop(varargin)
        %BPPASSASTOP   Construct a BPPASSASTOP object.
        %   H = BPPASSASTOP(N,Fpass1,Fpass2,Astop1,Apass,Astop2,Fs) constructs a
        %   bandpass filter specifications object with passband-edge specifications
        %   and stopband attenuation.
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
        
        % h = fspecs.bppassastop;
        respstr = 'Bandpass with passband-edge specifications and stopband attenuation.';
        fstart = 2;
        fstop = 3;
        nargsnoFs = 6;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bppassastop
        
    end  % constructor block

    methods 
        function set.Astop1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop1');
        value = double(value);
        obj.Astop1 = value;
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
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    [p,s] = magprops(this)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = propstoadd(this)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

