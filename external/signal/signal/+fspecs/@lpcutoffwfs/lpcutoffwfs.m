classdef lpcutoffwfs < fspecs.abstract3db
%LPCUTOFFWFS   Construct an LPCUTOFFWFS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpcutoffwfs class
%   fspecs.lpcutoffwfs extends fspecs.abstract3db.
%
%    fspecs.lpcutoffwfs properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpcutoffwfs methods:
%       cheby2 - Chebyshev Type II digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Return the property name to normalize.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %FSTOP Property is of type 'posdouble user-defined' 
    Fstop = .55;
end


    methods  % constructor block
        function this = lpcutoffwfs(varargin)
        %LPCUTOFFWFS   Construct a LPCUTOFFWFS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.lpcutoffwfs;
        
        respstr = 'Lowpass with cutoff and stopband frequency';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % lpcutoffwfs
        
    end  % constructor block

    methods 
        function set.Fstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fstop');
        value = double(value);
        obj.Fstop = value;
        end

    end   % set and get functions 

    methods  % public methods
    Hd = cheby2(this,varargin)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = props2normalize(~)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

