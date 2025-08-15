classdef hppassfstop < fspecs.hppass
%HPPASSFASTOP   Construct an HPPASSFSTOP object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fspecs.hppassfstop class
%   fspecs.hppassfstop extends fspecs.hppass.
%
%    fspecs.hppassfstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.hppassfstop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Properties to normalize frequency.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %FSTOP Property is of type 'posdouble user-defined' 
    Fstop = .4;
end


    methods  % constructor block
        function h = hppassfstop(varargin)
        %HPPASSFSTOP   Construct a HPPASSFSTOP object.
        %   H = HPPASSFSTOP(N,Fstop,Fpass,Apass,Fs) constructs a highpass filter
        %   specifications object with passband-edge specs.
        %
        %   N is the filter order and must be a positive integer.
        %
        %   Fstop is the stopband-edge frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Fpass is the passband-edge frequency and must be a positive scalar
        %   greater than Fstop and between 0 and 1 if no sampling frequency is
        %   specified or between 0 and Fs/2 if a sampling frequency Fs is
        %   specified.
        %
        %   Apass is the maximum passband deviation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % Override defaults inherited from lowpass
        
        if nargin < 1
            varargin{1} = 10;
        end
        
        if nargin < 2
            varargin{2} = .4;
        end
        
        if nargin < 3
            varargin{3} = .6;
        end
        
        % h = fspecs.hppassfstop;
        respstr = 'Highpass with passband-edge specifications and stopband frequency';
        fstart = 2;
        fstop = 3;
        nargsnoFs = 4;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        
        end  % hppassfstop
        
    end  % constructor block

    methods 
        function set.Fstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop');
        value = double(value);
        obj.Fstop = value;
        end

    end   % set and get functions 

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = props2normalize(h)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = propstoadd(this)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % possibly private or hidden 

end  % classdef

