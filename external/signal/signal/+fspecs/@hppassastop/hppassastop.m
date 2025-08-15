classdef hppassastop < fspecs.hppass
%HPPASSASTOP   Construct an HPPASSASTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hppassastop class
%   fspecs.hppassastop extends fspecs.hppass.
%
%    fspecs.hppassastop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.hppassastop methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude properties.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function h = hppassastop(varargin)
        %HPPASSASTOP   Construct a HPPASSASTOP object.
        %   H = HPPASSASTOP(N,Fpass,Astop,Apass,Fs) constructs a highpass filter
        %   specifications object with passband-edge specs.
        %
        %   N is the filter order and must be a positive integer.
        %
        %   Fpass is the passband-edge frequency and must be a positive scalar
        %   between 0 and 1 if no sampling frequency is specified or between 0 and
        %   Fs/2 if a sampling frequency Fs is specified.
        %
        %   Astop is the minimum stopband attenuation and it must be a positive
        %   scalar.
        %
        %   Apass is the maximum passband deviation and it must be a positive
        %   scalar.
        %
        %   Fs is the sampling frequency. If Fs is not specified, normalized
        %   frequency is assumed. If Fs is specified, it must be a positive scalar.
        
        %   Author(s): R. Losada
        
        % h = fspecs.hppassastop;
        respstr = 'Highpass with passband-edge specifications and stopband attenuation';
        fstart = 2;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(h,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        
        
        
        end  % hppassastop
        
    end  % constructor block

    methods 
        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
        end

    end   % set and get functions 

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    s = getdesignpanelstate(this)
    [p,s] = magprops(this)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = propstoadd(this)
end  % possibly private or hidden 

end  % classdef

