classdef (Abstract) abstractmultibandconstrained < fspecs.abstractmultibandarbmag
%ABSTRACTMULTIBANDCONSTRAINED   Construct an ABSTRACTMULTIBANDCONSTRAINED object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractmultibandconstrained class
%   fspecs.abstractmultibandconstrained extends fspecs.abstractmultibandarbmag.
%
%    fspecs.abstractmultibandconstrained properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NBands - Property is of type 'posint user-defined'  
%       B1Frequencies - Property is of type 'double_vector user-defined'  
%       B2Frequencies - Property is of type 'double_vector user-defined'  
%       B3Frequencies - Property is of type 'double_vector user-defined'  
%       B4Frequencies - Property is of type 'double_vector user-defined'  
%       B5Frequencies - Property is of type 'double_vector user-defined'  
%       B6Frequencies - Property is of type 'double_vector user-defined'  
%       B7Frequencies - Property is of type 'double_vector user-defined'  
%       B8Frequencies - Property is of type 'double_vector user-defined'  
%       B9Frequencies - Property is of type 'double_vector user-defined'  
%       B10Frequencies - Property is of type 'double_vector user-defined'  
%       B1Amplitudes - Property is of type 'double_vector user-defined'  
%       B2Amplitudes - Property is of type 'double_vector user-defined'  
%       B3Amplitudes - Property is of type 'double_vector user-defined'  
%       B4Amplitudes - Property is of type 'double_vector user-defined'  
%       B5Amplitudes - Property is of type 'double_vector user-defined'  
%       B6Amplitudes - Property is of type 'double_vector user-defined'  
%       B7Amplitudes - Property is of type 'double_vector user-defined'  
%       B8Amplitudes - Property is of type 'double_vector user-defined'  
%       B9Amplitudes - Property is of type 'double_vector user-defined'  
%       B10Amplitudes - Property is of type 'double_vector user-defined'  
%       B1Ripple - Property is of type 'posdouble user-defined'  
%       B2Ripple - Property is of type 'posdouble user-defined'  
%       B3Ripple - Property is of type 'posdouble user-defined'  
%       B4Ripple - Property is of type 'posdouble user-defined'  
%       B5Ripple - Property is of type 'posdouble user-defined'  
%       B6Ripple - Property is of type 'posdouble user-defined'  
%       B7Ripple - Property is of type 'posdouble user-defined'  
%       B8Ripple - Property is of type 'posdouble user-defined'  
%       B9Ripple - Property is of type 'posdouble user-defined'  
%       B10Ripple - Property is of type 'posdouble user-defined'  
%
%    fspecs.abstractmultibandconstrained methods:
%       getmask - Get the mask.


properties (AbortSet, SetObservable, GetObservable)
    %B1RIPPLE Property is of type 'posdouble user-defined' 
    B1Ripple = 0.2;
    %B2RIPPLE Property is of type 'posdouble user-defined' 
    B2Ripple = 0.2;
    %B3RIPPLE Property is of type 'posdouble user-defined' 
    B3Ripple = 0.2;
    %B4RIPPLE Property is of type 'posdouble user-defined' 
    B4Ripple = 0.2;
    %B5RIPPLE Property is of type 'posdouble user-defined' 
    B5Ripple = 0.2;
    %B6RIPPLE Property is of type 'posdouble user-defined' 
    B6Ripple = 0.2;
    %B7RIPPLE Property is of type 'posdouble user-defined' 
    B7Ripple = 0.2;
    %B8RIPPLE Property is of type 'posdouble user-defined' 
    B8Ripple = 0.2;
    %B9RIPPLE Property is of type 'posdouble user-defined' 
    B9Ripple = 0.2;
    %B10RIPPLE Property is of type 'posdouble user-defined' 
    B10Ripple = 0.2;
end


    methods 
        function set.B1Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B1Ripple');
        value = double(value);
        obj.B1Ripple = value;
        end

        function set.B2Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B2Ripple');
        value = double(value);
        obj.B2Ripple = value;
        end

        function set.B3Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B3Ripple');
        value = double(value);
        obj.B3Ripple = value;
        end

        function set.B4Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B4Ripple');
        value = double(value);
        obj.B4Ripple = value;
        end

        function set.B5Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B5Ripple');
        value = double(value);
        obj.B5Ripple = value;
        end

        function set.B6Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B6Ripple');
        value = double(value);
        obj.B6Ripple = value;
        end

        function set.B7Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B7Ripple');
        value = double(value);
        obj.B7Ripple = value;
        end

        function set.B8Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B8Ripple');
        value = double(value);
        obj.B8Ripple = value;
        end

        function set.B9Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
          validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B9Ripple');
        value = double(value);
        obj.B9Ripple = value;
        end

        function set.B10Ripple(obj,value)
        % User-defined DataType = 'posdouble user-defined'
          validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','B10Ripple');
        value = double(value);
        obj.B10Ripple = value;
        end

    end   % set and get functions 

    methods  % public methods
    [F,A] = getmask(this)
end  % public methods 

end  % classdef

