classdef bpcutoffwas < fspecs.abstract3db2
%BPCUTOFFWAS   Construct an BPCUTOFFWAS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpcutoffwas class
%   fspecs.bpcutoffwas extends fspecs.abstract3db2.
%
%    fspecs.bpcutoffwas properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpcutoffwas methods:
%       cheby2 - Chebyshev Type II digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude property names.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function this = bpcutoffwas(varargin)
        %BPCUTOFFWAS   Construct a BPCUTOFFWAS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bpcutoffwas;
        
        respstr = 'Bandpass with cutoff and stopband attenuation';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bpcutoffwas
        
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
    [pass,stop] = magprops(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

