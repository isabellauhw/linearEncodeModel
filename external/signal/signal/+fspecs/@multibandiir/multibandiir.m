classdef multibandiir < fspecs.abstractmultibandarbmag
%MULTIBANDIIR   Construct an MUTLIBANDIIR object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.multibandiir class
%   fspecs.multibandiir extends fspecs.abstractmultibandarbmag.
%
%    fspecs.multibandiir properties:
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
%       NumOrder - Property is of type 'posint user-defined'  
%       DenOrder - Property is of type 'posint user-defined'  
%
%    fspecs.multibandiir methods:
%       getdesignobj -   Get the design object.
%       getmask - Get the mask.
%       set_frequencies -   PreSet function for the 'frequencies' property.
%       validatespecs -   Validate the specs


properties (AbortSet, SetObservable, GetObservable)
    %NUMORDER Property is of type 'posint user-defined' 
    NumOrder = 8;
    %DENORDER Property is of type 'posint user-defined' 
    DenOrder = 8;
end


    methods  % constructor block
        function this = multibandiir(varargin)
        %MULTIBAND   Construct a MULTIBAND object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.multibandiir;
        
        respstr = 'Multi-Band Arbitrary Magnitude IIR';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % multiband
        
    end  % constructor block

    methods 
        function set.NumOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
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

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(this,str)
    [F,A] = getmask(this)
    frequencies = set_frequencies(this,frequencies)
    [Nb,Na,F,E,A,nfpts] = validatespecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(this)
    pname = orderprop(this)
end  % possibly private or hidden 

end  % classdef

