classdef hppass < fspecs.lppass
%HPPASS   Construct an HPPASS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hppass class
%   fspecs.hppass extends fspecs.lppass.
%
%    fspecs.hppass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.hppass methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function h = hppass(varargin)
        %HPPASS   Construct a HPPASS object.
        %   H = HPPASS(N,Fpass,Apass,Fs) constructs a highpass filter specifications
        %   object with passband-edge specs.
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
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        narginchk(0,4);
        
        % h = fspecs.hppass;
        
        constructor(h,varargin{:});
        
        h.ResponseType = 'Highpass with passband-edge specifications';
        
        
        end  % hppass
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

