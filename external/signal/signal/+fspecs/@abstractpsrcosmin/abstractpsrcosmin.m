classdef (Abstract) abstractpsrcosmin < fspecs.abstractspecwithfs
%ABSTRACTPRCOSMIN   Construct an ABSTRACTPSRCOSMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractpsrcosmin class
%   fspecs.abstractpsrcosmin extends fspecs.abstractspecwithfs.
%
%    fspecs.abstractpsrcosmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       RolloffFactor - Property is of type 'udouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractpsrcosmin methods:
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize - Return the property name to normalize
%       propstoadd - Return the properties to add to the parent object
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %SAMPLESPERSYMBOL Property is of type 'posint user-defined' 
    SamplesPerSymbol = 8;
    %ROLLOFFFACTOR Property is of type 'udouble user-defined' 
    RolloffFactor = 0.25;
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods 
        function set.SamplesPerSymbol(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','SamplesPerSymbol');    
        obj.SamplesPerSymbol = value;
        end

        function set.RolloffFactor(obj,value)
        % User-defined DataType = 'udouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','nonnegative'},'','RolloffFactor'); 
        value = double(value);
        obj.RolloffFactor = setRolloffFactor(obj,value);
        end

        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');  
        value = double(value);
        obj.Astop = value;
        end

    end   % set and get functions 

    methods  % public methods
    minfo = measureinfo(this)
    p = props2normalize(this)
    p = propstoadd(this)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = thispropstosync(this,p)
end  % possibly private or hidden 

end  % classdef

function val = setRolloffFactor(this, val) %#ok<INUSL>
if val > 1
    error(message('signal:fspecs:abstractpsrcosmin:schema:InvalidRolloffFactor'));
end
end  % setRolloffFactor


% [EOF]
