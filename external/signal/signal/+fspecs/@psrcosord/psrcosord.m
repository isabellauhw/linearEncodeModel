classdef psrcosord < fspecs.abstractpsrcosord
%PSRCOSORD   Construct an PSRCOSORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.psrcosord class
%   fspecs.psrcosord extends fspecs.abstractpsrcosord.
%
%    fspecs.psrcosord properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       RolloffFactor - Property is of type 'udouble user-defined'  
%
%    fspecs.psrcosord methods:
%       getdesignobj - Get the design object



    methods  % constructor block
        function this = psrcosord(varargin)
        %PSRCOSORD Construct a PSRCOSORD object
        
        
        % this = fspecs.psrcosord;
        
        this.ResponseType = 'Raised cosine pulse shaping with filter order';
        
        this.FilterOrder = 48;  % (SamplesPerSymbol * NumberOfSymbols = 8*6)
        
        this.setspecs(varargin{:});
        
        
        end  % psrcosord
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
end  % public methods 

end  % classdef

