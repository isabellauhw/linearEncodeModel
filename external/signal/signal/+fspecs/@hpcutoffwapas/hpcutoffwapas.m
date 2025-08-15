classdef hpcutoffwapas < fspecs.hpcutoffwas
%HPCUTOFFWAPAS   Construct an HPCUTOFFWAPAS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hpcutoffwapas class
%   fspecs.hpcutoffwapas extends fspecs.hpcutoffwas.
%
%    fspecs.hpcutoffwapas properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.hpcutoffwapas methods:
%       ellip - Elliptic digital filter design.
%       getdesignobj -   Get the design object.
%       measureinfo -   Return a structure of information for the measurements.


properties (AbortSet, SetObservable, GetObservable)
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods  % constructor block
        function this = hpcutoffwapas(varargin)
        %HPCUTOFFWAPAS   Construct a HPCUTOFFWAPAS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.hpcutoffwapas;
        
        respstr = 'Highpass with cutoff, passband ripple and stopband attenuation';
        fstart = 2;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % hpcutoffwapas
        
    end  % constructor block

    methods 
        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
        end

    end   % set and get functions 

    methods  % public methods
    Hd = ellip(this,varargin)
    designobj = getdesignobj(this,str)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [pass,stop] = magprops(this)
    p = propstoadd(this,varargin)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

