classdef bscutoff < fspecs.bpcutoff
%BSCUTOFF   Construct an BSCUTOFF object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bscutoff class
%   fspecs.bscutoff extends fspecs.bpcutoff.
%
%    fspecs.bscutoff properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff1 - Property is of type 'posdouble user-defined'  
%       Fcutoff2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bscutoff methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.



    methods  % constructor block
        function h = bscutoff(varargin)
        %BSCUTOFF   Construct a BSCUTOFF object.
        %   H = BSCUTOFF(N,Fcutoff1,Fcutoff2,Fs) constructs a bandstop filter
        %   specifications object with cutoff frequencies.
        %
        %   N is the filter order and must be an even positive integer.
        %
        %   Fcutoff1 is the lower cutoff frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fcutoff2 is the higher cutoff frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % h = fspecs.bscutoff;
        constructor(h,varargin{:});
        h.ResponseType = 'Bandstop with cutoff';
        
        end  % bscutoff
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    hdesigns = hiddendesigns(this)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

