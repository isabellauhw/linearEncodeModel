classdef bscutoffwapas < fspecs.bscutoffwap
%BSCUTOFFWAPAS   Construct an BSCUTOFFWAPAS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bscutoffwapas class
%   fspecs.bscutoffwapas extends fspecs.bscutoffwap.
%
%    fspecs.bscutoffwapas properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.bscutoffwapas methods:
%       getdesignobj -   Get the design object.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function this = bscutoffwapas(varargin)
        %BSCUTOFFWAPAS   Construct a BSCUTOFFWAPAS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bscutoffwapas;
        
        respstr = 'Bandstop with cutoff, passband ripple and stopband attenuation';
        fstart = 2;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        end  % bscutoffwapas
        
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
    designobj = getdesignobj(this,str)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [pass,stop] = magprops(this)
end  % possibly private or hidden 

end  % classdef

