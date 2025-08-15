classdef (Abstract) abstractcascadeallpass < dfilt.abstractallpass
    %ABSTRACTCASCADEALLPASS Abstract class
    
    %dfilt.abstractcascadeallpass class
    %   dfilt.abstractcascadeallpass extends dfilt.abstractallpass.
    %
    %    dfilt.abstractcascadeallpass properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       AllpassCoefficients - Property is of type 'mxArray'
    %
    %    dfilt.abstractcascadeallpass methods:
    %       constr -   Constructor for cascade allpass
    %       dispstr - Display string of coefficients.
    %       get_coeffs -   PreGet function for the 'coeffs' property.
    %       iirxform - IIR Transformations
    %       set_coeffs -   PreSet function for the 'coeffs' property.
    %       thisisreal -   True if the object is real.
    %       thisisstable -   True if the object is stable.
    %       validate_coeffs -   Validate the coeffs
    %       zpk -  Discrete-time filter zero-pole-gain conversion.
    
    
    
    methods
        [z,p,k] = zpk(this)
    end  % public methods
    
    methods (Hidden) 
        [p,v] = coefficient_info(this)
        c = coefficients(this)
        constr(this,varargin)
        s = dispstr(this,varargin)
        coeffs = get_coeffs(this,coeffs)
        [Ht,anum,aden] = iirxform(Hd,fun,varargin)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        [f,offset] = multfactor(this)
        n = nadd(this)
        n = thisnsections(this)
        labels = propnames(this)
        quantizecoeffs(this)
        coeffs = set_coeffs(this,coeffs)
        b = thisisreal(this)
        b = thisisstable(this)
        h = tocascadeallpass(this)
        h = tocascadewdfallpass(this)
        varargout = validate_coeffs(this,coeffs)
    end  % possibly private or hidden
    
end  % classdef

