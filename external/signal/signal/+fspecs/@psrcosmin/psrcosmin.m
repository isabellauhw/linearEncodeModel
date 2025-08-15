classdef psrcosmin < fspecs.abstractpsrcosmin
%PSRCOSMIN   Construct an PSRCOSMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.psrcosmin class
%   fspecs.psrcosmin extends fspecs.abstractpsrcosmin.
%
%    fspecs.psrcosmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       RolloffFactor - Property is of type 'udouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%
%    fspecs.psrcosmin methods:
%       getdesignobj - Get the design object



    methods  % constructor block
        function this = psrcosmin(varargin)
        %PSRCOSMIN Construct a PSRCOSMIN object
        
        
        % this = fspecs.psrcosmin;
        
        this.ResponseType = 'Minimum order raised cosine pulse shaping';
        
        this.Astop = 60;
        
        this.setspecs(varargin{:});
        
        
        end  % psrcosmin
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
end  % public methods 

end  % classdef

