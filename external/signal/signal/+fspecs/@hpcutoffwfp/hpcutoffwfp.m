classdef hpcutoffwfp < fspecs.abstract3db
%HPCUTOFFWFP   Construct an HPCUTOFFWFP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hpcutoffwfp class
%   fspecs.hpcutoffwfp extends fspecs.abstract3db.
%
%    fspecs.hpcutoffwfp properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%
%    fspecs.hpcutoffwfp methods:
%       cheby1 - Chebyshev Type I digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Return the property name to normalize.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %FPASS Property is of type 'posdouble user-defined' 
    Fpass = .55;
end


    methods  % constructor block
        function this = hpcutoffwfp(varargin)
        %HPCUTOFFWFP   Construct a HPCUTOFFWFP object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.hpcutoffwfp;
        
        respstr = 'Highpass with cutoff and passband frequency';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % hpcutoffwfp
        
    end  % constructor block

    methods 
        function set.Fpass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fpass');
        value = double(value);
        obj.Fpass = value;
        end

    end   % set and get functions 

    methods  % public methods
    Hd = cheby1(this,varargin)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = props2normalize(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

