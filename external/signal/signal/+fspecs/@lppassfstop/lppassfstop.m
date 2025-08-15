classdef lppassfstop < fspecs.abstractlppassfstop
%LPPASSFASTOP   Construct an LPPASSFSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lppassfstop class
%   fspecs.lppassfstop extends fspecs.abstractlppassfstop.
%
%    fspecs.lppassfstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.lppassfstop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.
%       thisvalidate -   Check that this object is valid.



    methods  % constructor block
        function h = lppassfstop(varargin)
        %LPPASSFSTOP   Construct a LPPASSFSTOP object.
        %   H = LPPASSFSTOP(N,Fpass,Fstop,Apass,Fs) constructs a lowpass filter
        %   specifications object with passband-edge specs.
        %
        %   N is the filter order and must be a positive integer.
        %
        %   Fpass is the passband-edge frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fstop is the stopband-edge frequency and must be a positive scalar
        %   greater than Fpass and between 0 and 1 if no sampling frequency is
        %   specified or between 0 and  Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Apass is the maximum passband deviation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % h = fspecs.lppassfstop;
        respstr = 'Lowpass with passband-edge specifications and stopband frequency';
        fstart = 2;
        fstop = 3;
        nargsnoFs = 4;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        
        end  % lppassfstop
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = propstoadd(this)
end  % possibly private or hidden 

end  % classdef

