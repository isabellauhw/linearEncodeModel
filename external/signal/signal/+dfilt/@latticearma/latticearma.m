classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) latticearma < dfilt.latticear
    %LATTICEARMA Lattice Autoregressive Moving-Average.
    %   Hd = DFILT.LATTICEARMA(K, V) constructs a Lattice autoregressive
    %   moving-average (ARMA) discrete-time filter object Hd with lattice
    %   coefficients K and ladder coefficients V.  If K or V are not specified,
    %   the defaults [] and 1. In this case, the filter passes the input
    %   through to the output unchanged.
    %
    %   Notice that the DSP System Toolbox, along with the Fixed-Point Designer,
    %   enables fixed-point support.
    %
    %   % EXAMPLE
    %   [b,a] = butter(3,.5);
    %   [k,v] = tf2latc(b,a);
    %   Hd = dfilt.latticearma(k,v)
    %   realizemdl(Hd); % Requires Simulink
    %
    %   See also DFILT/STRUCTURES, TF2LATC
    
    %dfilt.latticearma class
    %   dfilt.latticearma extends dfilt.latticear.
    %
    %    dfilt.latticearma properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       Lattice - Property is of type 'mxArray'
    %       Ladder - Property is of type 'mxArray'
    %
    %    dfilt.latticearma methods:
    %       blockparams - Returns the parameters for BLOCK
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient variables.
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       dispatch -   Return the LWDFILT.
    %       dispstr - Display string of coefficients.
    %       getladder - Overloaded get on the Ladder property.
    %       isblockable - True if the object supports the block method
    %       isfixedptable - True is the structure has an Arithmetic field
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       nadd - Returns the number of adders
    %       parse_coeffstoexport - Store coefficient names and values into hTar for
    %       qtoolinfo -   Return the info for the qtool.
    %       quantizecoeffs -  Quantize coefficients
    %       refladder - Return reference Ladder.
    %       refvals -   Reference coefficient values.
    %       savereferencecoefficients -   Save the reference coefficients.
    %       secfilter - Filter this section.
    %       setladder - Overloaded set on the Ladder property.
    %       setrefvals -   Set reference values.
    %       ss -  Discrete-time filter to state-space conversion.
    %       thiscoefficients - Filter coefficients.
    %       thisdisp - Object display.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisisreal -  True for filter with real coefficients.
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       tosysobj - Convert to a System object
    
    
    properties (Access=protected, SetObservable)
        %PRIVLADDER Property is of type 'DFILTNonemptyVector user-defined'
        privladder = [];
        %REFLADDER Property is of type 'DFILTNonemptyVector user-defined'
        refladder = [];
    end
    
    properties (SetObservable)
        %LADDER Property is of type 'mxArray'
        Ladder = 1;
    end
    
    
    methods  % constructor block
        function Hd = latticearma(k,v)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.FilterStructure = 'Lattice Autoregressive Moving-Average (ARMA)';
            Hd.Ladder = 1;
            Hd.Arithmetic = 'double';
            Hd.Lattice = [];
            Hd.States = [];
            if nargin>=1
                Hd.Lattice = k;
            end
            if nargin>=2
                Hd.Ladder = v;
            end
            
        end  % latticearma
        
    end  % constructor block
    
    methods
        function value = get.Ladder(obj)
            value = getladder(obj,obj.Ladder);
        end
        function set.Ladder(obj,value)
            obj.Ladder = setladder(obj,value);
        end
        
        function set.privladder(obj,value)
            % User-defined DataType = 'DFILTNonemptyVector user-defined'
            obj.privladder = value;
        end
        
        function set.refladder(obj,value)
            % User-defined DataType = 'DFILTNonemptyVector user-defined'
            obj.refladder = setrefladder(obj,value);
        end
        
    end   % set and get functions
    
    methods  % public methods
        [A,B,C,D] = ss(Hd)
        info = qtoolinfo(this)
    end  % public methods
    
    
    methods (Hidden) % possibly private or hidden
        [lib,srcblk,s] = blockparams(Hd,mapstates,varargin)
        c = coefficientnames(Hd)
        c = coefficientvariables(h)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        s = dispstr(Hd,varargin)
        ladder = getladder(Hd,ladder)
        b = isblockable(~)
        fixflag = isfixedptable(Hd)
        loadreferencecoefficients(this,s)
        n = nadd(this)
        [hTar,domapcoeffstoports] = parse_coeffstoexport(Hd,hTar)
        quantizecoeffs(Hd,eventData)
        n = getrefladder(Hd)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        [f,offset] = multfactor(this)
        s = objblockparams(this,varname)
        rcnames = refcoefficientnames(this)
        rcvals = refvals(this)
        s = savereferencecoefficients(this)
        [y,zf] = secfilter(Hd,x,zi)
        ladder = setladder(Hd,ladder)
        refladder = setrefladder(Hd,refladder)
        setrefvals(this,refvals)
        c = thiscoefficients(Hd)
        thisdisp(this)
        constr = thisfiltquant_plugins(h,arith)
        f = thisisreal(Hd)
        g = thisnormalize(Hd)
        n = thisnstates(Hd)
        thisunnormalize(Hd,g)
        Hs = tosysobj(this,returnSysObj)
    end  % possibly private or hidden
    
end  % classdef

