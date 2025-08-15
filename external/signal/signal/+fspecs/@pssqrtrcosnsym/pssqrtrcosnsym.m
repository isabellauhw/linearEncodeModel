classdef pssqrtrcosnsym < fspecs.abstractpsrcosnsym
%PSSQRTRCOSNSYM   Construct an PSSQRTRCOSNSYM object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.pssqrtrcosnsym class
%   fspecs.pssqrtrcosnsym extends fspecs.abstractpsrcosnsym.
%
%    fspecs.pssqrtrcosnsym properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NumberOfSymbols - Property is of type 'posint user-defined'  
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       RolloffFactor - Property is of type 'udouble user-defined'  
%
%    fspecs.pssqrtrcosnsym methods:
%       getdesignobj - Get the design object



    methods  % constructor block
        function this = pssqrtrcosnsym(varargin)
        %PSRCOSNSYM Construct a PSRCOSNSYM object
        
        
        % this = fspecs.pssqrtrcosnsym;
        
        this.ResponseType = 'Square root raised cosine pulse shaping with filter length in symbols';
        
        this.NumberOfSymbols = 6;
        
        this.setspecs(varargin{:});
        
        
        end  % pssqrtrcosnsym
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
end  % public methods 

end  % classdef

