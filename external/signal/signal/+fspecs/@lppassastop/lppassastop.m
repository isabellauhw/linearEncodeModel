classdef lppassastop < fspecs.abstractlppassastop
%LPPASSASTOP   Construct an LPPASSASTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lppassastop class
%   fspecs.lppassastop extends fspecs.abstractlppassastop.
%
%    fspecs.lppassastop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.lppassastop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measure -   Measure the filter.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function h = lppassastop(varargin)
        %LPPASSASTOP   Construct a LPPASSASTOP object.
        %   H = LPPASSASTOP(N,Fpass,Apass,Astop,Fs) constructs a lowpass filter
        %   specifications object with passband-edge specs.
        %
        %   N is the filter order and must be a positive integer.
        %
        %   Fpass is the passband-edge frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Apass is the maximum passband deviation and it must be a positive
        %   scalar.
        %
        %   Astop is the minimum stopband attenuation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % h = fspecs.lppassastop;
        respstr = 'Lowpass with passband-edge specifications and stopband attenuation';
        fstart = 2;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        
        
        
        end  % lppassastop
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    hm = measure(this,hfilter,varargin)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

