classdef lpcutoffwap < fspecs.abstract3db
%LPCUTOFFWAP   Construct an LPCUTOFFWAP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpcutoffwap class
%   fspecs.lpcutoffwap extends fspecs.abstract3db.
%
%    fspecs.lpcutoffwap properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpcutoffwap methods:
%       cheby1 - Chebyshev Type I digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.


properties (AbortSet, SetObservable, GetObservable)
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods  % constructor block
        function this = lpcutoffwap(varargin)
        %LPCUTOFFWAP   Construct a LPCUTOFFWAP object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.lpcutoffwap;
        
        respstr = 'Lowpass with cutoff and passband ripple';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % lpcutoffwap
        
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
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [pass,stop] = magprops(this)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

