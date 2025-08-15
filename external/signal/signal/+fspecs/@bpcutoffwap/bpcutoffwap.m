classdef bpcutoffwap < fspecs.abstract3db2
%BPCUTOFFWAP   Construct an BPCUTOFFWAP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpcutoffwap class
%   fspecs.bpcutoffwap extends fspecs.abstract3db2.
%
%    fspecs.bpcutoffwap properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpcutoffwap methods:
%       cheby1 - Chebyshev Type I digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude property names.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods  % constructor block
        function this = bpcutoffwap(varargin)
        %BPCUTOFFWAP   Construct a BPCUTOFFWAP object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bpcutoffwap;
        
        respstr = 'Bandpass with cutoff and passband ripple';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bpcutoffwap
        
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
    Hd = cheby1(this,varargin)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    [pass,stop] = magprops(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    minfo = measureinfo(this)
end  % possibly private or hidden 

end  % classdef

