classdef bscutoffwas < fspecs.abstract3db2
%BSCUTOFFWAS   Construct an BSCUTOFFWAS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bscutoffwas class
%   fspecs.bscutoffwas extends fspecs.abstract3db2.
%
%    fspecs.bscutoffwas properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.bscutoffwas methods:
%       cheby2 - Chebyshev Type II digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       magprops -   Return the magnitude property names.
%       measureinfo -   Return a structure of information for the measurements.


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function this = bscutoffwas(varargin)
        %BSCUTOFFWAS   Construct a BSCUTOFFWAS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bscutoffwas;
        
        respstr = 'Bandstop with cutoff and stopband attenuation';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bscutoffwas
        
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
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

