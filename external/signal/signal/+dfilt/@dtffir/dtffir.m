classdef (Abstract) dtffir < dfilt.dtfwnum
    %DTF Direct-form transfer function FIR filter virtual class.
    %   DTFFIR is a virtual class---it is never intended to be instantiated.
    
    %dfilt.dtffir class
    %   dfilt.dtffir extends dfilt.dtfwnum.
    %
    %    dfilt.dtffir properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Numerator - Property is of type 'mxArray'
    %
    %    dfilt.dtffir methods:
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient variables.
    %       constraincoeffwlfir - Constrain coefficient wordlength.
    %       dispstr - Display string of coefficients.
    %       fir_blockparams -   Return the fir specific block parameters.
    %       getbestprecision - Return best precision for Product and Accumulator
    %       internalsettings - Returns the fixed-point settings viewed by the algorithm.
    %       isblockmapcoeffstoports - True if the object is blockmapcoeffstoports
    %       isblockrequiredst - Check if block method requires a DST license
    %       isfixedptable - True is the structure has an Arithmetic field
    %       ishdlable - True if HDL can be generated for the filter object.
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       optimizecoeffwlfir - OPTIMIZECOEFFWL Optimize coefficient wordlength for FIR filters.
    %       optimizestopbandfir - Optimize stopband.
    %       quantizecoeffs -  Quantize coefficients
    %       savereferencecoefficients -   Save the reference coefficients.
    %       sethdl_dtffir - SETHDLPROPSBASEFILTER Set the common props for HDLFILTER  from filter
    %       thiscoefficients - Filter coefficients.
    %       thisdisp - Object display.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisisfir - True if the filter is FIR
    %       thisisreal -  True for filter with real coefficients.
    %       thisisstable - True if the filter is stable
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       thissfcnparams - Returns the parameters for SDSPFILTER
    %       tosysobj - Convert dfilt FIR structure to System object
    
    methods
       [result,errstr,errorObj] = ishdlable(Hb) 
    end
    
    methods (Hidden)
        c = coefficientnames(Hd)
        c = coefficientvariables(h)
        Hd = constraincoeffwlfir(this,Href,WL,varargin)
        s = dispstr(Hd,varargin)
        s = fir_blockparams(Hd,mapstates,forceDigitalFilterBlock)
        s = getbestprecision(h)
        s = internalsettings(h)
        b = isblockmapcoeffstoports(this)
        isblockrequiredst(~)
        fixflag = isfixedptable(Hd)
        loadreferencecoefficients(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        Hbest = minimizecoeffwlfir(this,Href,varargin)
        [Hbest,mrfflag] = optimizecoeffwlfir(this,Href,varargin)
        Href = optimizestopbandfir(this,Href,wl,varargin)
        quantizecoeffs(h,eventData)
        s = savereferencecoefficients(this)
        sethdl_dtffir(this,hhdl)
        C = thiscoefficients(Hd)
        thisdisp(this)
        constr = thisfiltquant_plugins(h,arith)
        firflag = thisisfir(Hd)
        f = thisisreal(Hd)
        stableflag = thisisstable(Hd)
        n = thisnstates(Hd)
        varargout = thissfcnparams(Hd)
        Hs = tosysobj(this,returnSysObj)
        update(h)
    end  % possibly private or hidden
    
end  % classdef

