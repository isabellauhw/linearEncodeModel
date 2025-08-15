classdef (Abstract) abstractmultiband < fspecs.abstractspecwithfs
%ABSTRACTMULTIBAND   Construct an ABSTRACTMULTIBAND object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractmultiband class
%   fspecs.abstractmultiband extends fspecs.abstractspecwithfs.
%
%    fspecs.abstractmultiband properties:
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
%
%    fspecs.abstractmultiband methods:
%       designopts -   Display the design options.
%       props2normalize -   Return the property name to normalize.
%       propstoadd -   Return the properties to add to the parent object.
%       set_bands -   PreSet function for the 'bands' property.
%       set_frequencies -   PreSet function for the 'frequencies' property.


properties (AbortSet, SetObservable, GetObservable)
    %NBANDS Property is of type 'posint user-defined' 
    NBands = 1;
    %B1FREQUENCIES Property is of type 'double_vector user-defined' 
    B1Frequencies = [.2 .38 .4 .55 .562 .585 .6 .78];;
    %B2FREQUENCIES Property is of type 'double_vector user-defined' 
    B2Frequencies = 0.8:0.01:1;
    %B3FREQUENCIES Property is of type 'double_vector user-defined' 
    B3Frequencies = [ 1, 1 ];
    %B4FREQUENCIES Property is of type 'double_vector user-defined' 
    B4Frequencies = [ 1, 1 ];
    %B5FREQUENCIES Property is of type 'double_vector user-defined' 
    B5Frequencies = [ 1, 1 ];
    %B6FREQUENCIES Property is of type 'double_vector user-defined' 
    B6Frequencies = [ 1, 1 ];
    %B7FREQUENCIES Property is of type 'double_vector user-defined' 
    B7Frequencies = [ 1, 1 ];
    %B8FREQUENCIES Property is of type 'double_vector user-defined' 
    B8Frequencies = [ 1, 1 ];
    %B9FREQUENCIES Property is of type 'double_vector user-defined' 
    B9Frequencies = [ 1, 1 ];
    %B10FREQUENCIES Property is of type 'double_vector user-defined' 
    B10Frequencies = [ 1, 1 ];
end


    methods 
        function set.NBands(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','NBands');    
        obj.NBands = set_bands(obj,value);
        end

        function set.B1Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
        validateattributes(value,{'double'},...
          {'vector'},'','B1Frequencies');
        obj.B1Frequencies = set_frequencies(obj,value);
        end

        function set.B2Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B2Frequencies');
        obj.B2Frequencies = set_frequencies(obj,value);
        end

        function set.B3Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B3Frequencies');
        obj.B3Frequencies = set_frequencies(obj,value);
        end

        function set.B4Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B4Frequencies');
        obj.B4Frequencies = set_frequencies(obj,value);
        end

        function set.B5Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B5Frequencies');
        obj.B5Frequencies = set_frequencies(obj,value);
        end

        function set.B6Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B6Frequencies');
        obj.B6Frequencies = set_frequencies(obj,value);
        end

        function set.B7Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B7Frequencies');
        obj.B7Frequencies = set_frequencies(obj,value);
        end

        function set.B8Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B8Frequencies');
        obj.B8Frequencies = set_frequencies(obj,value);
        end

        function set.B9Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B9Frequencies');
        obj.B9Frequencies = set_frequencies(obj,value);
        end

        function set.B10Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B10Frequencies');
        obj.B10Frequencies = set_frequencies(obj,value);
        end

    end   % set and get functions 

    methods  % public methods
    s = designopts(this,dmethod,sigonlyflag)
    p = props2normalize(this)
    p = propstoadd(this)
    bands = set_bands(this,bands)
    frequencies = set_frequencies(this,frequencies)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = thisprops2add(this,varargin)
end  % possibly private or hidden 

end  % classdef

