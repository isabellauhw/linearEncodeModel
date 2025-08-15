classdef bsstop < fspecs.bpstop
%BPSTOP   Construct an BPSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bsstop class
%   fspecs.bsstop extends fspecs.bpstop.
%
%    fspecs.bsstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.bsstop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.



    methods  % constructor block
        function h = bsstop(varargin)
        %BSSTOP   Construct a BSSTOP object.
        %   H = BSSTOP(N,Fstop1,Fstop2,Astop,Fs) constructs a bandstop filter
        %   specifications object with stopband-edge specifications.
        %
        %   N is the filter order and must be an even positive integer.
        %
        %   Fstop1 is the lower stopband-edge frequency and must be a positive
        %   scalar between 0 and 1 if no sampling frequency is specified or between
        %   0 and Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fstop2 is the higher stopband-edge frequency and must be a positive
        %   scalar larger than Fstop1 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Astop is the minimum stopband attenuation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        narginchk(0,5);
        % h = fspecs.bsstop;
        constructor(h,varargin{:});
        h.ResponseType = 'Bandstop with stopband-edge specifications.';
        
        end  % bsstop
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

