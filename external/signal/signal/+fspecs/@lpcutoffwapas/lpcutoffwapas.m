classdef lpcutoffwapas < fspecs.lpcutoffwap
%LPCUTOFFWAPAS   Construct an LPCUTOFFWAPAS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpcutoffwapas class
%   fspecs.lpcutoffwapas extends fspecs.lpcutoffwap.
%
%    fspecs.lpcutoffwapas properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpcutoffwapas methods:
%       ellip - Elliptic digital filter design.
%       getdesignobj -   Get the design object.
%       measureinfo -   Return a structure of information for the measurements.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function this = lpcutoffwapas(varargin)
        %LPCUTOFFWAPAS   Construct a LPCUTOFFWAPAS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.lpcutoffwapas;
        
        respstr = 'Lowpass with cutoff, passband ripple and stopband attenuation';
        fstart = 2;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % lpcutoffwapas
        
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
    Hd = ellip(this,varargin)
    designobj = getdesignobj(this,str)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [pass,stop] = magprops(this)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

