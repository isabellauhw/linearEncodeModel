classdef pssqrtrcosmin < fspecs.abstractpsrcosmin
%PSSQRTRCOSMIN   Construct an PSSQRTRCOSMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.pssqrtrcosmin class
%   fspecs.pssqrtrcosmin extends fspecs.abstractpsrcosmin.
%
%    fspecs.pssqrtrcosmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       RolloffFactor - Property is of type 'udouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.pssqrtrcosmin methods:
%       getdesignobj - Get the design object



    methods  % constructor block
        function this = pssqrtrcosmin(varargin)
        %PSRCOSMIN Construct a PSSQRTRCOSMIN object
        
        
        % this = fspecs.pssqrtrcosmin;
        
        this.ResponseType = 'Minimum order square root raised cosine pulse shaping';
        
        % This is the half of the default raised cosine stop band attenuation, which is
        % 60 dB.
        this.Astop = 30;
        
        this.setspecs(varargin{:});
        
        end  % pssqrtrcosmin
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
end  % public methods 

end  % classdef

