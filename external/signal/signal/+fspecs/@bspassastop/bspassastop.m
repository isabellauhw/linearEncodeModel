classdef bspassastop < fspecs.bspass
%BSPASSASTOP   Construct an BSPASASTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bspassastop class
%   fspecs.bspassastop extends fspecs.bspass.
%
%    fspecs.bspassastop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.bspassastop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude properties.
%       measureinfo -   Return a structure of information for the measurements.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function h = bspassastop(varargin)
        %BSPASSASTOP   Construct a BSPASSASTOP object.
        %   H = BSPASSASTOP(N,Fpass1,Fpass2,Apass,Astop,Fs) constructs a bandstop
        %   filter specifications object with passband-edge specifications and
        %   stopband attenuation.
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
        %   Apass is the maximum passband deviation in dB. It must be a positive
        %   scalar.
        %
        %   Astop is the minimum stopband attenuation in dB. It must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % h = fspecs.bspassastop;
        respstr = 'Bandstop with passband-edge specifications and stopband attenuation.';
        fstart = 2;
        fstop = 3;
        nargsnoFs = 5;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bspassastop
        
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
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    [p,s] = magprops(this)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

