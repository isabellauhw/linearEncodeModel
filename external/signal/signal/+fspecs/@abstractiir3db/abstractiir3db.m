classdef (Abstract) abstractiir3db < fspecs.abstractspecwithfs
%ABSTRACTIIR3DB   Construct an ABSTRACTIIR3DB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractiir3db class
%   fspecs.abstractiir3db extends fspecs.abstractspecwithfs.
%
%    fspecs.abstractiir3db properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NumOrder - Property is of type 'posint user-defined'  
%       DenOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractiir3db methods:
%       measureinfo - Return a structure of information for the measurements.
%       props2normalize - Properties to normalize frequency.
%       thisgetspecs - Get the specs  - used in FVTOOL for drawing the mask.


properties (AbortSet, SetObservable, GetObservable)
    %NUMORDER Property is of type 'posint user-defined' 
    NumOrder = 8;
    %DENORDER Property is of type 'posint user-defined' 
    DenOrder = 8;
    %F3DB Property is of type 'posdouble user-defined' 
    F3dB = 0.5;
end


    methods 
        function set.NumOrder(obj,value)
        % User-defined DataType = non-negative integer
        validateattributes(value,{'numeric'},...
          {'scalar','nonnegative','integer'},'','NumOrder');    
        obj.NumOrder = value;
        end

        function set.DenOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','DenOrder');    
        obj.DenOrder = value;
        end

        function set.F3dB(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','F3dB');
        value = double(value);
        obj.F3dB = value;
        end

    end   % set and get functions 

    methods  % public methods
    minfo = measureinfo(~)
    p = props2normalize(~)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    constructor(h,varargin)
    description = describe(~)
end  % possibly private or hidden 

end  % classdef

