classdef multiband < fspecs.abstractmultibandarbmag
%MULTIBAND   Construct an MULTIBAND object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.multiband class
%   fspecs.multiband extends fspecs.abstractmultibandarbmag.
%
%    fspecs.multiband properties:
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
%       FilterOrder - Property is of type 'posint user-defined'  
%
%    fspecs.multiband methods:
%       getdesignobj - Get the design object.
%       getmask - Get the mask.
%       validatespecs - Validate the specs


properties (AbortSet, SetObservable, GetObservable)
    %FILTERORDER Property is of type 'posint user-defined' 
    FilterOrder = 30;
end


    methods  % constructor block
        function this = multiband(varargin)
        %MULTIBAND   Construct a MULTIBAND object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.multiband;
        
        respstr = 'Multi-Band Arbitrary Magnitude';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 2;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % multiband
        
    end  % constructor block

    methods 
        function set.FilterOrder(obj,value)
        % User-defined DataType = 'posint user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive','integer'},'','FilterOrder');    
        obj.FilterOrder = value;
        end

    end   % set and get functions 

    methods  % public methods
    designobj = getdesignobj(this,str,sigonlyflag)
    [F,A] = getmask(this)
    [N,F,E,A,nfpts,Fs,NormFreqFlag] = validatespecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(~)
    pname = orderprop(~)
end  % possibly private or hidden 

end  % classdef

