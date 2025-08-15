classdef bpcutoffwbwp < fspecs.abstract3db2
%BPCUTOFFWBWP   Construct an BPCUTOFFWBWP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpcutoffwbwp class
%   fspecs.bpcutoffwbwp extends fspecs.abstract3db2.
%
%    fspecs.bpcutoffwbwp properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%       BWpass - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpcutoffwbwp methods:
%       cheby1 - Chebyshev Type I digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       props2normalize -   Return the property name to normalize.


properties (AbortSet, SetObservable, GetObservable)
    %BWPASS Property is of type 'posdouble user-defined' 
    BWpass = .15;
end


    methods  % constructor block
        function this = bpcutoffwbwp(varargin)
        %BPCUTOFFWBWP   Construct a BPCUTOFFWBWP object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bpcutoffwbwp;
        
        respstr = 'Bandpass with cutoff and passband width';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bpcutoffwbwp
        
    end  % constructor block

    methods 
        function set.BWpass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','BWpass');
        value = double(value);
        obj.BWpass = value;
        end

    end   % set and get functions 

    methods  % public methods
    Hd = cheby1(this,varargin)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    p = props2normalize(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

