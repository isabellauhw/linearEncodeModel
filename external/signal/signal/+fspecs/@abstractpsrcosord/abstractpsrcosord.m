classdef (Abstract) abstractpsrcosord < fspecs.abstractspecwithordnfs
%ABSTRACTSPRCOSORD   Construct an ABSTRACTPSRCOSORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractpsrcosord class
%   fspecs.abstractpsrcosord extends fspecs.abstractspecwithordnfs.
%
%    fspecs.abstractpsrcosord properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       RolloffFactor - Property is of type 'udouble user-defined'  
%
%    fspecs.abstractpsrcosord methods:
%       getFilterOrder - Get the filterOrder.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize - Return the property name to normalize
%       propstoadd - Return the properties to add to the parent object
%       set_filterorder - PreSet function for the 'FilterOrder' property
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %SAMPLESPERSYMBOL Property is of type 'posint user-defined' 
    SamplesPerSymbol = 8;
    %ROLLOFFFACTOR Property is of type 'udouble user-defined' 
    RolloffFactor = 0.25;
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

    end   % set and get functions 

    methods  % public methods
    filterOrder = getFilterOrder(this)
    minfo = measureinfo(this)
    p = props2normalize(this)
    p = propstoadd(this)
    filterOrder = set_filterorder(this,filterOrder)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

function val = setRolloffFactor(this, val) %#ok<INUSL>
if val > 1
    error(message('signal:fspecs:abstractpsrcosord:schema:InvalidRolloffFactor'));
end
end  % setRolloffFactor


% [EOF]
