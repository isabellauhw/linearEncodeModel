classdef (Abstract) abstractsos < dfilt.singleton
    %ABSTRACTSOS Second-order-section filter virtual class.
    %   ABSTRACTSOS is a virtual class---it is never intended to be instantiated.

    
    %dfilt.abstractsos class
    %   dfilt.abstractsos extends dfilt.singleton.
    %
    %    dfilt.abstractsos properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       sosMatrix - Property is of type 'mxArray'
    %       ScaleValues - Property is of type 'mxArray'
    %       OptimizeScaleValues - Property is of type 'bool'
    %
    %    dfilt.abstractsos methods:
    %       blocklib - BLOCKPARAMS Returns the library and source block for BLOCKPARAMS
    %       cfi -   Return the information for
    %       checkoptimizable - ARGS) Check if optimizations can be carried on
    %       checkoptimizescalevalues - check if optimize scale values is possible
    %       checksv -  Check number of scale values
    %       ciirxform - Complex IIR Transformations.
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient Variables.
    %       cscalefactors -   Cumulative scale factors
    %       cumsec -   Returns a vector of filters for the cumulative sections.
    %       defaulttbstimulus - returns a cell array of stimulus types.
    %       dispatch -   Dispatch to a light weight dfilt.
    %       dispatchsecfilter - Dispatch info for secfilter
    %       dispstr - Display string of coefficients.
    %       doFrameProcessing - Returns true if frame processing if supported by realizemdl()
    %       firxform - FIR Transformations
    %       getbestprecision - Return best precision for Product and Accumulator
    %       getoptimizesv - Get the optimizesv.
    %       getsosmatrix - Get the sosmatrix from the object.
    %       getsv - PreGet function for the scale values
    %       iirbpc2bpc - IIR complex bandpass to complex bandpass transformation
    %       iirlp2bpc - IIR Lowpass to complex bandpass transformation
    %       iirlp2bsc - IIR Lowpass to complex bandstop transformation
    %       iirlp2mbc - IIR Lowpass to complex multiband transformation
    %       iirlp2xc - IIR Lowpass to complex N-Point transformation
    %       iirxform - IIR Transformations
    %       internalsettings - Returns the fixed-point settings viewed by the algorithm.
    %       isblockable - True if the object supports the block method
    %       isblockmapcoeffstoports - True if the object is blockmapcoeffstoports
    %       isfixedptable - True is the structure has an Arithmetic field
    %       ishdlable - True if HDL can be generated for the filter object.
    %       get_isrealizable - True if the structure can be realized by simulink
    %       limitcycle - LIMITCYLE  Detect zero-input limit cycles in IIR quantized filters.
    %       loadpublicinterface -   Load the public interface.
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       nadd - Returns the number of adders
    %       parse_coeffstoexport - Store coefficient names and values into hTar for
    %       parse_inputs - Parse the inputs of the constructor.
    %       quantizecoeffs -  Quantize coefficients
    %       refscalevalues - Return reference scale values
    %       refsos - Return reference sos matrix.
    %       refvals -   Reference coefficient values.
    %       reorder -   Reorder the sections.
    %       savepublicinterface -   Save the public interface.
    %       savereferencecoefficients -   Save the reference coefficients.
    %       scale -  Second-order section scaling.
    %       scaleopts -   Create an options object for second-order section scaling.
    %       secorder - Returns the order of each section.
    %       sethdl_abstractsos - SETHDLPROPSBASEFILTER Set the common props for HDLFILTER  from filter
    %       setoptimizesv -   PreSet function for the 'OptimizeScaleValues' property.
    %       setrefvals -   Set reference values.
    %       setsosmatrix - Set the SOS matrix.
    %       setsv - PreSet function for the ScaleValues property.
    %       singlesection -   Convert to a single section.
    %       sos -  Convert to second-order-sections.
    %       ss -  Discrete-time filter to state-space conversion.
    %       super_getinitialconditions - Get the initial conditions
    %       superparse_filterstates - Store filter states in hTar for df1sos and df1tsos
    %       thiscoefficients - Filter coefficients.
    %       thisdisp - Object display.
    %       thisimpzlength - Length of the impulse response for a digital filter.
    %       thisislinphase -  True for linear phase filter.
    %       thisismaxphase - True if maximum phase.
    %       thisisminphase - True if minimum phase.
    %       thisisreal -  True for filter with real coefficients.
    %       thisisrealizable - True if the structure can be realized by simulink
    %       thisissos -  True if second-order-section.
    %       thisisstable -  True if filter is stable.
    %       thisnsections - Number of sections.
    %       thissetstates - Overloaded set for the States property.
    %       todf1sos -  Convert to direct-form 1 sos.
    %       todf1tsos -  Convert to direct-form 1 transposed sos.
    %       todf2sos -  Convert to direct-form II sos.
    %       todf2tsos -  Convert to direct-form II transposed sos.
    %       tosysobj - Convert dfilt SOS structure to System object
    %       warnsv - Warn if too many scale values.
    %       ziscalarexpand - Expand empty or scalar initial conditions to a vector.
    %       zpk -  Discrete-time filter zero-pole-gain conversion.
    
    
    properties (Access=protected, SetObservable)
        %PRIVOPTIMIZESCALEVALUES Property is of type 'bool'
        privOptimizeScaleValues = true;
        %PRIVNUM Property is of type 'mxArray'
        privNum = [];
        %PRIVDEN Property is of type 'mxArray'
        privDen = [];
        %PRIVSCALEVALUES Property is of type 'DFILTCoefficientVector user-defined'
        privScaleValues = [];
        %ISSVNOTEQ2ONE Property is of type 'bool_vector user-defined'
        issvnoteq2one = [];
        %NUMADDEDSV Property is of type 'double'
        NumAddedSV = 0;
        %REFSOSMATRIX Property is of type 'dfiltsosmatrix user-defined'
        refsosMatrix = [];
        %REFSCALEVALUES Property is of type 'DFILTCoefficientVector user-defined'
        refScaleValues = [];
        %NSECTIONS Property is of type 'int32'
        nsections = 0;
    end
    
    properties (SetObservable)
        %OPTIMIZESCALEVALUES Property is of type 'bool'
        OptimizeScaleValues = true;
    end
    
    properties (Transient, SetObservable)
        %ARITHMETIC Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
        Arithmetic = 'double';
        %SOSMATRIX Property is of type 'mxArray'
        sosMatrix = [];
        %SCALEVALUES Property is of type 'mxArray'
        ScaleValues = [];
    end
    
    
    methods
        function value = get.Arithmetic(obj)
            value = get_arith(obj,obj.Arithmetic);
        end
        function set.Arithmetic(obj,value)
            % Enumerated DataType = 'filterdesign_arith enumeration: {'double','single','fixed'}'
            value = validatestring(value,{'double','single','fixed'},'','Arithmetic');
            obj.Arithmetic = set_arith(obj,value);
        end
        
        function value = get.sosMatrix(obj)
            value = getsosmatrix(obj,obj.sosMatrix);
        end
        function set.sosMatrix(obj,value)
            obj.sosMatrix = setsosmatrix(obj,value);
        end
        
        function value = get.ScaleValues(obj)
            value = getsv(obj,obj.ScaleValues);
        end
        function set.ScaleValues(obj,value)
            obj.ScaleValues = setsv(obj,value);
        end
        
        function value = get.OptimizeScaleValues(obj)
            value = getoptimizesv(obj,obj.OptimizeScaleValues);
        end
        function set.OptimizeScaleValues(obj,value)
            % DataType = 'bool'
            validateattributes(value,{'numeric','logical'}, {'scalar','nonnan'},'','OptimizeScaleValues')
            value = logical(value); %  convert to logical
            obj.OptimizeScaleValues = setoptimizesv(obj,value);
        end
        
        function set.privOptimizeScaleValues(obj,value)
            % DataType = 'bool'
            validateattributes(value,{'numeric','logical'}, {'scalar','nonnan'},'','privOptimizeScaleValues')
            value = logical(value); %  convert to logical
            obj.privOptimizeScaleValues = value;
        end
        
        function set.privScaleValues(obj,value)
            % User-defined DataType = 'DFILTCoefficientVector user-defined'
            obj.privScaleValues = value;
        end
        
        function set.issvnoteq2one(obj,value)
            % User-defined DataType = 'bool_vector user-defined'
            obj.issvnoteq2one = value;
        end
        
        function set.NumAddedSV(obj,value)
            % DataType = 'double'
            validateattributes(value,{'numeric'}, {'scalar'},'','NumAddedSV')
            value = double(value); %  convert to double
            obj.NumAddedSV = value;
        end
        
        function set.refsosMatrix(obj,value)
            % User-defined DataType = 'dfiltsosmatrix user-defined'
            obj.refsosMatrix = setrefsosmatrix(obj,value);
        end
        
        function set.refScaleValues(obj,value)
            % User-defined DataType = 'DFILTCoefficientVector user-defined'
            obj.refScaleValues = setrefscalevalues(obj,value);
        end
        
        function set.nsections(obj,value)
            % DataType = 'int32'
            validateattributes(value,{'int32','double'}, {'scalar'},'','nsections')
            obj.nsections = value;
        end
        
    end   % set and get functions
    
    methods  % public methods
        Hsos = sos(Hd,varargin)
        [A,B,C,D] = ss(Hd)
        [z,p,k] = zpk(Hd)
        [result,errstr,errorObj] = ishdlable(Hb)
    end  % public methods
    
    
    methods (Hidden) % possibly private or hidden
        [lib,srcblk,hasInputProcessing,hasRateOptions] = blocklib(Hd,~)
        fi = cfi(this)
        checkoptimizable(this,hTar)
        variables = checkoptimizescalevalues(this,variables)
        varargout = checksv(Hd)
        [Hout,anum,aden] = ciirxform(Hd,fun,varargin)
        [p,v] = coefficient_info(this)
        c = coefficientnames(Hd)
        c = coefficientvariables(h)
        str = coeffviewstr(this,varargin)
        c = cscalefactors(h,opts)
        sc = cumnorm(Hd,pnorm,secondary)
        varargout = cumsec(this,indices,secondary)
        stimcell = defaulttbstimulus(Hb)
        sc = df1df2tscalecheck(Hd,pnorm)
        df1df2tunconstrainedscale(Hd,opts,L)
        sc = df2df1tscalecheck(Hd,pnorm)
        df2df1tunconstrainedscale(Hd,opts,L)
        Hd = dispatch(this)
        [q,num,den,sv,issvnoteq2one] = dispatchsecfilter(Hd)
        s = dispstr(Hd,varargin)
        flag = doFrameProcessing(~)
        Ht = firxform(Hd,fun,varargin)
        s = getbestprecision(h)
        optimizesv = getoptimizesv(this,optimizesv)
        privvals = getprivvals(this)
        sosm = getsosmatrix(hObj,sosm)
        sv = getsv(Hd,sv)
        [Ht,anum,aden] = iirbpc2bpc(Hd,varargin)
        [Ht,anum,aden] = iirlp2bpc(Hd,varargin)
        [Ht,anum,aden] = iirlp2bsc(Hd,varargin)
        [Ht,anum,aden] = iirlp2mbc(Hd,varargin)
        [Ht,anum,aden] = iirlp2xc(Hd,varargin)
        [Ht,anum,aden] = iirxform(Hd,fun,varargin)
        s = internalsettings(h)
        b = isblockable(~)
        b = isblockmapcoeffstoports(this)
        fixflag = isfixedptable(Hd)
        varargout = limitcycle(Hd,Ntrials,InputLengthFactor,StopCriterion)
        loadpublicinterface(this,s)
        loadreferencecoefficients(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        [f,offset] = multfactor(this)
        n = nadd(this)
        [hTar,domapcoeffstoports] = parse_coeffstoexport(Hd,hTar)
        [msg,msgObj] = parse_inputs(Hd,varargin)
        quantizecoeffs(h,eventData)
        rcnames = refcoefficientnames(this)
        sv = refscalevalues(h)
        s = refsos(h)
        rcvals = refvals(this)
        varargout = reorder(this,numorder,denorder,svorder)
        s = savepublicinterface(this)
        s = savereferencecoefficients(this)
        varargout = scale(this,pnorm,varargin)
        opts = scaleopts(this)
        n = secorder(Hd)
        sethdl_abstractsos(this,hhdl)
        OptimizeScaleValues = setoptimizesv(this,OptimizeScaleValues)
        setprivvals(this,privvals)
        setrefvals(this,refvals)
        refscalevalues = setrefscalevalues(Hd,refscalevalues)
        refsosmatrix = setrefsosmatrix(Hd,refsosmatrix)
        s = setsosmatrix(this,s)
        setsosprivvals(this,privvals)
        sv = setsv(Hd,sv)
        [Hd,str] = singlesection(this)
        pnames = sosprivnames(this)
        privvals = sosprivvals(this)
        s = super_blockparams(Hd)
        ic = super_getinitialconditions(Hd)
        super_unconstrainedscale(Hd,opts,L)
        hTar = superparse_filterstates(Hd,hTar)
        c = thiscoefficients(Hd)
        thisdisp(this)
        len = thisimpzlength(Hd,varargin)
        f = thisislinphase(Hd,tol)
        f = thisismaxphase(Hd,tol)
        f = thisisminphase(Hd,tol)
        f = thisisreal(Hd)
        f = thisisrealizable(Hd)
        f = thisissos(Hd)
        f = thisisstable(Hd)
        g = thisnormalize(Hd)
        nsecs = thisnsections(Hd)
        S = thissetstates(Hd,S)
        thisunnormalize(Hd,g)
        Hd2 = todf1sos(Hd)
        Hd2 = todf1tsos(Hd)
        Hd2 = todf2sos(Hd)
        Hd2 = todf2tsos(Hd)
        Hs = tosysobj(this,returnSysObj)
        warnsv(Hd)
        S = ziscalarexpand(Hd,S)
    end  % possibly private or hidden
    
end  % classdef

function checksosmatrix(s)
%CHECKSOSMATRIX Check if argument is an sos matrix

if ~isnumeric(s)
    error(message('signal:dfilt:abstractsos:schema:MustBeNumeric'));
end

if ~isempty(s) & size(s,2) ~= 6
    error(message('signal:dfilt:abstractsos:schema:InvalidDimensions'));
end

if issparse(s)
    error(message('signal:dfilt:abstractsos:schema:Sparse'));
end
end  % checksosmatrix


%-----------------------------------------------------------------
function checkboolvector(b)

if ~isempty(b) && ~islogical(b)
    error(message('signal:dfilt:abstractsos:schema:InternalError'));
end
end  % checkboolvector


% [EOF]
