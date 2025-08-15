classdef bspass < fspecs.bppass
%BSPASS   Construct an BSPASS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bspass class
%   fspecs.bspass extends fspecs.bppass.
%
%    fspecs.bspass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.bspass methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.



    methods  % constructor block
        function h = bspass(varargin)
        %BSPASS   Construct a BSPASS object.
        %   H = BSPASS(N,Fpass1,Fpass2,Apass,Fs) constructs a bandstop filter
        %   specifications object with passband-edge specifications.
        %
        %   N is the filter order and must be an even positive integer.
        %
        %   Fpass1 is the lower passband-edge frequency and must be a positive
        %   scalar between 0 and 1 if no sampling frequency is specified or between
        %   0 and Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fpass2 is the higher passband-edge frequency and must be a positive
        %   scalar larger than Fpass1 and between 0 and 1 if no sampling frequency
        %   is specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Apass is the maximum passband deviation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        narginchk(0,5);
        % h = fspecs.bspass;
        constructor(h,varargin{:});
        h.ResponseType = 'Bandstop with passband-edge specifications.';
        
        
        end  % bspass
        
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

