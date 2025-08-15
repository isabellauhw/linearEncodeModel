classdef hpcutoff < fspecs.lpcutoff
%HPCUTOFF   Construct an HPCUTOFF object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hpcutoff class
%   fspecs.hpcutoff extends fspecs.lpcutoff.
%
%    fspecs.hpcutoff properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff - Property is of type 'posdouble user-defined'  
%
%    fspecs.hpcutoff methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function h = hpcutoff(varargin)
        %HPCUTOFF   Construct a HPCUTOFF object.
        %   H = HPCUTOFF(N,Fcutoff,Fs) constructs a highpass filter specifications
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
        
        % h = fspecs.hpcutoff;
        
        constructor(h,varargin{:});
        
        
        h.ResponseType = 'Highpass with cutoff';
        
        
        end  % hpcutoff
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    hdesigns = hiddendesigns(this)
end  % possibly private or hidden 

end  % classdef

