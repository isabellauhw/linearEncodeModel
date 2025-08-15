classdef lpcutoffwas < fspecs.abstract3db
%LPCUTOFFWAS   Construct an LPCUTOFFWAS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpcutoffwas class
%   fspecs.lpcutoffwas extends fspecs.abstract3db.
%
%    fspecs.lpcutoffwas properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpcutoffwas methods:
%       cheby2 - Chebyshev Type II digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function this = lpcutoffwas(varargin)
        %LPCUTOFFWAS   Construct a LPCUTOFFWAS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.lpcutoffwas;
        
        respstr = 'Lowpass with cutoff and stopband attenuation';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % lpcutoffwas
        
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
    Hd = cheby2(this,varargin)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [pass,stop] = magprops(this)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

