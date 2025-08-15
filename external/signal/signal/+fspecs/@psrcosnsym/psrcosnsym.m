classdef psrcosnsym < fspecs.abstractpsrcosnsym
%PSRCOSNSYM   Construct an PSRCOSNSYM object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.psrcosnsym class
%   fspecs.psrcosnsym extends fspecs.abstractpsrcosnsym.
%
%    fspecs.psrcosnsym properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NumberOfSymbols - Property is of type 'posint user-defined'  
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       RolloffFactor - Property is of type 'udouble user-defined'  
%
%    fspecs.psrcosnsym methods:
%       getdesignobj - Get the design object



    methods  % constructor block
        function this = psrcosnsym(varargin)
        %PSRCOSNSYM Construct a PSRCOSNSYM object
        
        
        % this = fspecs.psrcosnsym;
        
        this.ResponseType = 'Raised cosine pulse shaping with filter length in symbols';
        
        this.NumberOfSymbols = 6;
        
        this.setspecs(varargin{:});
        
        
        end  % psrcosnsym
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
end  % public methods 

end  % classdef

