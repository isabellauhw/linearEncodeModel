classdef lpmin < fspecs.abstractlpmin
%LPMIN   Construct an LPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpmin class
%   fspecs.lpmin extends fspecs.abstractlpmin.
%
%    fspecs.lpmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpmin methods:
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measure -   Measure the filter.
%       measureinfo -   Return a structure of information for the measurements.



    methods  % constructor block
        function h = lpmin(varargin)
        %LPMIN   Construct a LPMIN object.
        %   H = LPMIN(Fpass,Fstop,Apass,Astop,Fs) constructs a minimum-order
        %   lowpass filter specifications object.
        %
        %   Fpass is the passband-edge frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fstop is the stopband-edge frequency and must be a positive scalar
        %   greater than Fpass and  between 0 and 1 if no sampling frequency is
        %   specified or between 0 and Fs/2 if a sampling frequency Fs is
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
        
        
        % h = fspecs.lpmin;
        respstr = 'Minimum-order lowpass';
        fstart = 1;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        
        
        end  % lpmin
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    hm = measure(this,Hd,varargin)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    ha = analogresp(h)
    c = cparam(h)
end  % possibly private or hidden 

end  % classdef

