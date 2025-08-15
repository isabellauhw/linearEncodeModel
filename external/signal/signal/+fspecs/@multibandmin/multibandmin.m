classdef multibandmin < fspecs.abstractmultibandconstrained
%MULTIBANDMIN   Construct an MUTLIBANDMIN object.

%   Copyright 1999-2015 The MathWorks, Inc

%fspecs.multibandmin class
%   fspecs.multibandmin extends fspecs.abstractmultibandconstrained.
%
%    fspecs.multibandmin properties:
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
%    fspecs.multibandmin methods:
%       getdesignobj - Get the design object.
%       propstoadd - Return the properties to add to the parent object.
%       validatespecs - Validate the specs



    methods  % constructor block
        function this = multibandmin(varargin)
        %MULTIBANDMIN Construct a MULTIBANDMIN object.
        
        
        % this = fspecs.multibandmin;
        
        respstr = 'Multi-Band Arbitrary Magnitude';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 2;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % multibandmin
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str)
    p = propstoadd(this)
    R = validatespecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    description = describe(~)
end  % possibly private or hidden 

end  % classdef

