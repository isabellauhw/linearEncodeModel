classdef hpcutoffwfs < fspecs.abstract3db
%HPCUTOFFWFS   Construct an HPCUTOFFWFS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hpcutoffwfs class
%   fspecs.hpcutoffwfs extends fspecs.abstract3db.
%
%    fspecs.hpcutoffwfs properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.hpcutoffwfs methods:
%       cheby2 - Chebyshev Type II digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Return the property name to normalize.
%       propstoadd -   Return the properties to add to the parent object.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %FSTOP Property is of type 'posdouble user-defined' 
    Fstop = .45;
end


    methods  % constructor block
        function this = hpcutoffwfs(varargin)
        %HPCUTOFFWFS   Construct a HPCUTOFFWFS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.hpcutoffwfs;
        
        respstr = 'Highpass with cutoff and stopband frequency';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % hpcutoffwfs
        
    end  % constructor block

    methods 
        function set.Fstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop');
        obj.Fstop = value;
        end

    end   % set and get functions 

    methods  % public methods
    Hd = cheby2(this,varargin)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = props2normalize(~)
    p = propstoadd(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

