classdef (Abstract) dtfiir < dfilt.dtfwnum
    %DTFIIR Abstract class
    
    %dfilt.dtfiir class
    %   dfilt.dtfiir extends dfilt.dtfwnum.
    %
    %    dfilt.dtfiir properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Numerator - Property is of type 'mxArray'
    %       Denominator - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %
    %    dfilt.dtfiir methods:
    %       blocklib - BLOCKPARAMS Returns the library and source block for BLOCKPARAMS
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient variables.
    %       dispatch -   Return the LWDFILT.
    %       dispstr - Display string of coefficients.
    %       doFrameProcessing - Returns true if frame processing if supported by realizemdl()
    %       firxform - FIR Transformations
    %       getbestprecision - Return best precision for Product and Accumulator
    %       getdenominator - Overloaded get on the Denominator property.
    %       iir_blockparams -   Get the IIR-specific block parameters.
    %       iir_qtoolinfo -   Return the IIR specific info.
    %       iirxform - IIR Transformations
    %       isblockmapcoeffstoports - True if the object is blockmapcoeffstoports
    %       isblockrequiredst - Check if block method requires a DST license
    %       isfixedptable -   True if the object is fixedptable.
    %       limitcycle - LIMITCYLE  Detect zero-input limit cycles in IIR quantized filters.
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       nadd - Returns the number of adders
    %       parse_coeffstoexport - Store coefficient names and values into hTar for
    %       quantizecoeffs -  Quantize coefficients
    %       refdenominator - Return reference denominator.
    %       refvals -   Reference coefficient values.
    %       savereferencecoefficients -   Save the reference coefficients.
    %       setdenominator - Overloaded set on the Denominator property.
    %       setrefden - SETREFNUM Overloaded set on the refden property.
    %       setrefvals -   Set reference values.
    %       sos -  Convert to second-order-sections.
    %       superparse_filterstates - Store filter states in hTar for df1sos and df1tsos
    %       thiscoefficients - Filter coefficients.
    %       thisdisp - Object display.
    %       thisisreal -  True for filter with real coefficients.
    %       thisisstable -  True if filter is stable.
    %       thisisrealizable - True if the structure can be realized by simulink
    %       thissfcnparams - Returns the parameters for SDSPFILTER
    %       todf1sos -   Convert to a DF1SOS.
    %       todf1tsos -   Convert to a DF1TSOS.
    %       todf2sos -   Convert to a DF2SOS.
    %       todf2tsos -   Convert to a DF2TSOS.
    %       tosysobj - Convert dfilt IIR structure to System object
    
    
    properties (Access=protected, SetObservable)
        %PRIVDEN Property is of type 'DFILTNonemptyVector user-defined'
        privden = [];
        %REFDEN Property is of type 'DFILTNonemptyVector user-defined'
        refden = [];
    end
    
    properties (SetObservable)
        %DENOMINATOR Property is of type 'mxArray'
        Denominator = 1;
    end
    
    properties (Transient, SetObservable)
        %ARITHMETIC Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
        Arithmetic = 'double';
    end
    
    
    methods
        function value = get.Denominator(obj)
            value = getdenominator(obj,obj.Denominator);
        end
        function set.Denominator(obj,value)
            obj.Denominator = setdenominator(obj,value);
        end
        
        function set.privden(obj,value)
            % User-defined DataType = 'DFILTNonemptyVector user-defined'
            obj.privden = value;
        end
        
        function set.refden(obj,value)
            % User-defined DataType = 'DFILTNonemptyVector user-defined'
            obj.refden = setrefden(obj,value);
        end
        
        function value = get.Arithmetic(obj)
            value = get_arith(obj,obj.Arithmetic);
        end
        function set.Arithmetic(obj,value)
            % Enumerated DataType = 'filterdesign_arith enumeration: {'double','single','fixed'}'
            value = validatestring(value,{'double','single','fixed'},'','Arithmetic');
            obj.Arithmetic = set_arith(obj,value);
        end
        
    end   % set and get functions
    
    methods  % public methods
        Hsos = sos(Hd,varargin)
    end  % public methods
    
    
    methods (Hidden) % possibly private or hidden
        
        [lib,srcblk,hasInputProcessing,hasRateOptions] = blocklib(~,link2obj,forceDigitalFilterBlock)
        c = coefficientnames(Hd)
        c = coefficientvariables(h)
        Hd = dispatch(this)
        s = dispstr(Hd,varargin)
        flag = doFrameProcessing(~)
        Ht = firxform(Ho,fun,varargin)
        s = getbestprecision(h)
        den = getdenominator(Hd,den)
        s = iir_blockparams(Hd,forceDigitalFilterBlock)
        info = iir_qtoolinfo(this)
        [Ht,anum,aden] = iirxform(Ho,fun,varargin)
        b = isblockmapcoeffstoports(this)
        isblockrequiredst(~)
        b = isfixedptable(h)
        varargout = limitcycle(Hd,Ntrials,InputLengthFactor,StopCriterion)
        loadreferencecoefficients(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        [f,offset] = multfactor(this)
        n = nadd(this)
        [hTar,domapcoeffstoports] = parse_coeffstoexport(Hd,hTar)
        quantizecoeffs(h,eventData)
        rcnames = refcoefficientnames(this)
        d = refdenominator(h)
        rcvals = refvals(this)
        s = savereferencecoefficients(this)
        den = setdenominator(Hd,den)
        den = setrefden(Hd,den)
        setrefvals(this,refvals)
        hTar = superparse_filterstates(Hd,hTar)
        c = thiscoefficients(Hd)
        thisdisp(this)
        f = thisisreal(Hd)
        f = thisisrealizable(Hd)
        isstableflag = thisisstable(Hd)
        varargout = thissfcnparams(Hd)
        Hd = todf1sos(this)
        Hd = todf1tsos(this)
        Hd = todf2sos(this)
        Hd = todf2tsos(this)
        Hs = tosysobj(this,returnSysObj)
    end  % possibly private or hidden
    
end  % classdef

