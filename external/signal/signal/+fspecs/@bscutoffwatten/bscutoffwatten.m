classdef bscutoffwatten < fspecs.abstractspecwithordnfs
%BSCUTOFFWATTEN   Construct an BSCUTOFFWATTEN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bscutoffwatten class
%   fspecs.bscutoffwatten extends fspecs.abstractspecwithordnfs.
%
%    fspecs.bscutoffwatten properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fcutoff1 - Property is of type 'posdouble user-defined'  
%       Fcutoff2 - Property is of type 'posdouble user-defined'  
%       Apass1 - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Apass2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bscutoffwatten methods:
%       getdesignobj -   Get the design object.
%       props2normalize -   Properties to normalize frequency.
%       thisgetspecs -   Get the specs. This is used by FVTOOL for drawing the mask.
%       thisvalidate -   Check that this object is valid.


properties (AbortSet, SetObservable, GetObservable)
    %FCUTOFF1 Property is of type 'posdouble user-defined' 
    Fcutoff1 = 0.4;
    %FCUTOFF2 Property is of type 'posdouble user-defined' 
    Fcutoff2 = 0.6;
    %APASS1 Property is of type 'posdouble user-defined' 
    Apass1 = 1;
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
    %APASS2 Property is of type 'posdouble user-defined' 
    Apass2 = 1;
end


    methods  % constructor block
        function this = bscutoffwatten(varargin)
        %BSCUTOFFWATTEN   Construct a BSCUTOFFWATTEN object.
        
        
        % this = fspecs.bscutoffwatten;
        
        respstr = 'Bandstop with cutoff and attenuation';
        fstart = 2;
        fstop = 3;
        nargsnoFs = 6;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        end  % bscutoffwatten
        
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

        function set.Apass1(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass1');
        value = double(value);
        obj.Apass1 = value;
        end

        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
        end

        function set.Apass2(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass2');
        value = double(value);
        obj.Apass2 = value;
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

