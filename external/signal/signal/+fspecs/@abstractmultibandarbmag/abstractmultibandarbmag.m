classdef (Abstract) abstractmultibandarbmag < fspecs.abstractmultiband
%ABSTRACTMULTIBANDARBMAG   Construct an ABSTRACTMULTIBANDARBMAG object.

%   Copyright 1999-2015 The MathWorks, Inc.  
  
%ABSTRACTMULTIBANDARBMAG   Construct an ABSTRACTMULTIBANDARBMAG object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractmultibandarbmag class
%   fspecs.abstractmultibandarbmag extends fspecs.abstractmultiband.
%
%    fspecs.abstractmultibandarbmag properties:
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
%
%    fspecs.abstractmultibandarbmag methods:
%       formatspecs - Format the specs
%       getspecs - Get the specs.
%       propstoadd - Return the properties to add to the parent object.
%       set_amplitudes - PreSet function for the 'amplitudes' property.


properties (AbortSet, SetObservable, GetObservable)
    %B1AMPLITUDES Property is of type 'double_vector user-defined' 
    B1Amplitudes = [.5 2.3 1 1 .001 .001 1 1];     % Piece wise linear
    %B2AMPLITUDES Property is of type 'double_vector user-defined' 
    B2Amplitudes = .2+18*(1-(0.8:0.01:1)).^2;        % Quadratic
    %B3AMPLITUDES Property is of type 'double_vector user-defined' 
    B3Amplitudes = [ 0, 0 ];
    %B4AMPLITUDES Property is of type 'double_vector user-defined' 
    B4Amplitudes = [ 0, 0 ];
    %B5AMPLITUDES Property is of type 'double_vector user-defined' 
    B5Amplitudes = [ 0, 0 ];
    %B6AMPLITUDES Property is of type 'double_vector user-defined' 
    B6Amplitudes = [ 0, 0 ];
    %B7AMPLITUDES Property is of type 'double_vector user-defined' 
    B7Amplitudes = [ 0, 0 ];
    %B8AMPLITUDES Property is of type 'double_vector user-defined' 
    B8Amplitudes = [ 0, 0 ];
    %B9AMPLITUDES Property is of type 'double_vector user-defined' 
    B9Amplitudes = [ 0, 0 ];
    %B10AMPLITUDES Property is of type 'double_vector user-defined' 
    B10Amplitudes = [ 0, 0 ];
end

properties (SetAccess=protected, AbortSet, SetObservable, GetObservable, Hidden)
    %PRIVACTUALNORMALIZEDFREQUENCYSTATE Property is of type 'bool' (hidden)
    privActualNormalizedFrequencyState
end


    methods 
        function set.B1Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
          validateattributes(value,{'double'},...
          {'vector'},'','B1Amplitudes');
        obj.B1Amplitudes = set_amplitudes(obj,value);
        end

        function set.B2Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','B2Amplitudes');
        obj.B2Amplitudes = set_amplitudes(obj,value);
        end

        function set.B3Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','B3Amplitudes');
        obj.B3Amplitudes = set_amplitudes(obj,value);
        end

        function set.B4Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','B4Amplitudes');
        obj.B4Amplitudes = set_amplitudes(obj,value);
        end

        function set.B5Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','B5Amplitudes');
        obj.B5Amplitudes = set_amplitudes(obj,value);
        end

        function set.B6Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','B6Amplitudes');
        obj.B6Amplitudes = set_amplitudes(obj,value);
        end

        function set.B7Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','B7Amplitudes');
        obj.B7Amplitudes = set_amplitudes(obj,value);
        end

        function set.B8Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','B8Amplitudes');
        obj.B8Amplitudes = set_amplitudes(obj,value);
        end

        function set.B9Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','B9Amplitudes');
        obj.B9Amplitudes = set_amplitudes(obj,value);
        end

        function set.B10Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','B10Amplitudes');
        obj.B10Amplitudes = set_amplitudes(obj,value);
        end

        function set.privActualNormalizedFrequencyState(obj,value)
        % DataType = 'bool'
        validateattributes(value,{'logical','numeric'}, ...
          {'scalar','nonnan'},'','privActualNormalizedFrequencyState')
        value = logical(value);
        obj.privActualNormalizedFrequencyState = value;
        end

    end   % set and get functions 

    methods  % public methods
    [FreqEdgesCell,AmpEdgesCell,Fcell,Acell,NBands] = formatspecs(this)
    specs = getspecs(~)
    p = propstoadd(this)
    amplitudes = set_amplitudes(~,amplitudes)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    cachecurrentnormalizedfreq(this)
    minfo = measureinfo(this)
    [F,E,A,nfpts,Fs,normFreqFlag] = super_validatespecs(this)
end  % possibly private or hidden 

end  % classdef

