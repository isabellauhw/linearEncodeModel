classdef lpstop < fspecs.abstractlpstop
%LPSTOP   Construct an LPSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpstop class
%   fspecs.lpstop extends fspecs.abstractlpstop.
%
%    fspecs.lpstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpstop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function h = lpstop(varargin)
        %LPSTOP   Construct a LPSTOP object.
        %   H = LPSTOP(N,Fstop,Astop,Fs) constructs a lowpass filter specifications
        %   object with stopband-edge specs.
        %
        %   N is the filter order and must be a positive integer.
        %
        %   Fstop is the stopband-edge frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Astop is the minimum stopband attenuation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        
        %   Author(s): R. Losada
        
        narginchk(0,4);
            
        % h = fspecs.lpstop;
        
        constructor(h,varargin{:});
        
        h.ResponseType = 'Lowpass with stopband-edge specifications';
        
        
        
        
        end  % lpstop
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    constructor(h,varargin)
    c = cparam(h)
end  % possibly private or hidden 

end  % classdef

