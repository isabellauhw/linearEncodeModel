classdef lpcutoff < fspecs.abstractlpcutoff
%LPCUTOFF   Construct an LPCUTOFF object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpcutoff class
%   fspecs.lpcutoff extends fspecs.abstractlpcutoff.
%
%    fspecs.lpcutoff properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpcutoff methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       hiddendesigns -   Returns the designs that are hidden.
%       measureinfo -   Return a structure of information for the measurements.



    methods  % constructor block
        function h = lpcutoff(varargin)
        %LPCUTOFF   Construct a LPCUTOFF object.
        %   H = LPCUTOFF(N,Fcutoff,Fs) constructs a lowpass filter specifications
        %   object with a cutoff frequency.
        %
        %   N is the filter order and must be a positive integer.
        %
        %   Fcutoff is the cutoff frequency and must be a positive scalar between 0
        %   and 1 if no sampling frequency is specified or between 0 and Fs/2 if a
        %   sampling frequency Fs is specified.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        narginchk(0,3);
        
        
        % h = fspecs.lpcutoff;
        
        constructor(h,varargin{:});
        
        h.ResponseType = 'Lowpass with cutoff';
        
        
        end  % lpcutoff
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    hdesigns = hiddendesigns(this)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    constructor(h,varargin)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

