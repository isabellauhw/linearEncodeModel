classdef bpcutoffwapas < fspecs.abstract3db2
%BPCUTOFFWAPAS   Construct an BPCUTOFFWAPAS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpcutoffwapas class
%   fspecs.bpcutoffwapas extends fspecs.abstract3db2.
%
%    fspecs.bpcutoffwapas properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%       Astop1 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpcutoffwapas methods:
%       getdesignobj -   Get the design object.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP1 Property is of type 'posdouble user-defined' 
    Astop1 = 60;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
    %ASTOP2 Property is of type 'posdouble user-defined' 
    Astop2 = 60;
end


    methods  % constructor block
        function this = bpcutoffwapas(varargin)
        %BPCUTOFFWAPAS   Construct a BPCUTOFFWAPAS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bpcutoffwapas;
        
        respstr = 'Bandpass with cutoff, passband ripple and stopband attenuation';
        fstart = 2;
        fstop = 2;
        nargsnoFs = 4;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bpcutoffwapas
        
    end  % constructor block

    methods 
        function set.Astop1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop1');
        value = double(value);
        obj.Astop1 = value;
        end

        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
        end

        function set.Astop2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop2');
        value = double(value);
        obj.Astop2 = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(this,str)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [pass,stop] = magprops(this)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

