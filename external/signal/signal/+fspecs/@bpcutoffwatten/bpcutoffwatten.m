classdef bpcutoffwatten < fspecs.abstractspecwithordnfs
%BPCUTOFFWATTEN   Construct an BPCUTOFFWATTEN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpcutoffwatten class
%   fspecs.bpcutoffwatten extends fspecs.abstractspecwithordnfs.
%
%    fspecs.bpcutoffwatten properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff1 - Property is of type 'posdouble user-defined'  
%       Fcutoff2 - Property is of type 'posdouble user-defined'  
%       Astop1 - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpcutoffwatten methods:
%       getdesignobj -   Get the design object.
%       props2normalize -   Properties to normalize frequency.
%       thisgetspecs -   Get the specs. This is used by FVTOOL for drawing the mask. 
%       thisvalidate -   Check that this object is valid.


properties (AbortSet, SetObservable, GetObservable)
    %FCUTOFF1 Property is of type 'posdouble user-defined' 
    Fcutoff1 = 0.4;
    %FCUTOFF2 Property is of type 'posdouble user-defined' 
    Fcutoff2 = 0.6;
    %ASTOP1 Property is of type 'posdouble user-defined' 
    Astop1 = 60;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
    %ASTOP2 Property is of type 'posdouble user-defined' 
    Astop2 = 60;
end


    methods  % constructor block
        function this = bpcutoffwatten(varargin)
        %BPCUTOFFWATTEN   Construct a BPCUTOFFWATTEN object.
        
        
        % this = fspecs.bpcutoffwatten;
        
        respstr = 'Bandpass with cutoff and attenuation';
        fstart = 2;
        fstop = 3;
        nargsnoFs = 6;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        end  % bpcutoffwatten
        
    end  % constructor block

    methods 
        function set.Fcutoff1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fcutoff1');
        value = double(value);
        obj.Fcutoff1 = value;
        end

        function set.Fcutoff2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Fcutoff2');
        value = double(value);
        obj.Fcutoff2 = value;
        end

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
    designobj = getdesignobj(~,str,sigonlyflag)
    p = props2normalize(h)
    specs = thisgetspecs(this)
    [isvalid,errmsg,errid] = thisvalidate(h)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [pass,stop] = magprops(this)
    minfo = measureinfo(this)
end  % possibly private or hidden 

end  % classdef

