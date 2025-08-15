classdef hpmin < fspecs.lpmin
%HPMIN   Construct an HPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fspecs.hpmin class
%   fspecs.hpmin extends fspecs.lpmin.
%
%    fspecs.hpmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.hpmin methods:
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measure -   Measure the filter.
%       measureinfo -   Return a structure of information for the measurements.
%       propstoadd -   Returns the properties to add.
%       thisvalidate -   Check that this object is valid.



    methods  % constructor block
        function h = hpmin(varargin)
        %HPMIN   Construct a HPMIN object.
        %   H = HPMIN(Fstop,Fpass,Astop,Apass,Fs) constructs a minimum-order
        %   highpass filter specifications object.
        %
        %   Fstop is the stopband-edge frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fpass is the passband-edge frequency and must be a positive scalar
        %   greater than Fstop and between 0 and 1 if no sampling frequency is
        %   specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Astop is the minimum stopband attenuation in dB. It must be a positive
        %   scalar.
        %
        %   Apass is the maximum passband deviation in dB. It must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % Override factory defaults inherited from lowpass
        if nargin < 1
            varargin{1} = .45;
        end
        if nargin < 2
            varargin{2} = .55;
        end
        
        
        % h = fspecs.hpmin;
        respstr = 'Minimum-order highpass';
        fstart = 1;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        
        end  % hpmin
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    hm = measure(this,Hd,varargin)
    minfo = measureinfo(this)
    p = propstoadd(this)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    ha = analogresp(h)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

