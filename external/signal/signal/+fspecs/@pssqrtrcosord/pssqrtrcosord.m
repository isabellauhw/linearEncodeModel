classdef pssqrtrcosord < fspecs.abstractpsrcosord
%PSSQRTRCOSORD   Construct an PSSQRTRCOSORD object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.pssqrtrcosord class
%   fspecs.pssqrtrcosord extends fspecs.abstractpsrcosord.
%
%    fspecs.pssqrtrcosord properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       RolloffFactor - Property is of type 'udouble user-defined'  
%
%    fspecs.pssqrtrcosord methods:
%       getdesignobj - Get the design object



    methods  % constructor block
        function this = pssqrtrcosord(varargin)
        %PSRCOSORD Construct a PSSQRTRCOSORD object
        
        
        % this = fspecs.pssqrtrcosord;
        
        this.ResponseType = 'Square root raised cosine pulse shaping with filter order';
        
        this.FilterOrder = 48;  % (SamplesPerSymbol * NumberOfSymbols = 8*6)
        
        this.setspecs(varargin{:});
        
        
        end  % pssqrtrcosord
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
end  % public methods 

end  % classdef

