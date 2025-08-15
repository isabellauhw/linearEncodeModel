classdef bppassfstop < fspecs.bppass
%BPPASSFSTOP   Construct an BPPASSFSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bppassfstop class
%   fspecs.bppassfstop extends fspecs.bppass.
%
%    fspecs.bppassfstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bppassfstop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.


properties (AbortSet, SetObservable, GetObservable)
    %FSTOP1 Property is of type 'posdouble user-defined' 
    Fstop1 = 0.35;
    %FSTOP2 Property is of type 'posdouble user-defined' 
    Fstop2 = 0.65;
end


    methods  % constructor block
        function h = bppassfstop(varargin)
        %BPPASSFSTOP   Construct a BPPASSFSTOP object.
        %   H = BPPASSFSTOP(N,Fstop1,Fpass1,Fpass2,Fstop2,Apass,Fs) constructs a
        %   bandpass filter specifications object with passband-edge
        %   specifications and stopband frequencies.
        %
        %   N is the filter order and must be an even positive integer.
        %
        %   Fstop1 is the lower stopband-edge frequency and must be a positive
        %   scalar between 0 and 1 if no sampling frequency is specified or between
        %   0 and Fs/2 if a sampling frequency Fs is specified.
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
        %   Fstop2 is the higher stopband-edge frequency and must be a positive
        %   scalar between 0 and 1 if no sampling frequency is specified or between
        %   0 and Fs/2 if a sampling frequency Fs is specified.
        %
        %   Apass is the maximum passband deviation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % h = fspecs.bppassfstop;
        respstr = 'Bandpass with passband-edge specifications and stopband frequencies.';
        fstart = 2;
        fstop = 5;
        nargsnoFs = 6;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bppassfstop
        
    end  % constructor block

    methods 
        function set.Fstop1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop1');
        value = double(value);
        obj.Fstop1 = value;
        end

        function set.Fstop2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop2');
        value = double(value);
        obj.Fstop2 = value;
        end

    end   % set and get functions 

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = props2normalize(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = propstoadd(this)
    specs = thisgetspecs(this)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % possibly private or hidden 

end  % classdef

