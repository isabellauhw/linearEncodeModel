classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) scalar < dfilt.singleton
    %SCALAR Scalar.
    %   Hd = DFILT.SCALAR(G) constructs a discrete-time scalar
    %   filter object with gain G.
    %
    %   % EXAMPLE
    %   Hd = dfilt.scalar(3)
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.scalar class
    %   dfilt.scalar extends dfilt.singleton.
    %
    %    dfilt.scalar properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       Gain - Property is of type 'mxArray'
    %
    %    dfilt.scalar methods:
    %       blocklib - BLOCKPARAMS Returns the library and source block for BLOCKPARAMS
    %       blockparams -   Return the block parameters.
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient variables.
    %       createhdlfilter - CREATHDLFILTER <short description>
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       dispatch -   Return the lwdfilt.
    %       dispstr - Display string of coefficients.
    %       firxform - FIR Transformations
    %       getinfoheader -   Get the infoheader.
    %       iirxform - IIR Transformations
    %       internalsettings -   Return the internalsettings.
    %       isblockable - True if the object supports the block method
    %       isfixedptable - True is the structure has an Arithmetic field
    %       ishdlable - True if HDL can be generated for the filter object.
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       qtoolinfo -   Return the information for the qtool.
    %       quantizecoeffs -  Quantize coefficients
    %       refgain - Return reference gain.
    %       refvals -   Reference coefficient values.
    %       savereferencecoefficients -   Save the reference coefficients.
    %       secfilter - Filter this section.
    %       setrefgain - Overloaded set on the refgain property.
    %       setrefvals -   Set the refvals.
    %       ss -  Discrete-time filter to state-space conversion.
    %       thiscoefficients - Filter coefficients.
    %       thisdisp - Object display.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisisreal -  True for filter with real coefficients.
    %       thisisrealizable - True if the structure can be realized by simulink
    %       thisisscalarstructure -  True if scalar filter.
    %       thisisstable -  True if filter is stable.
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       ziexpand - Expand initial conditions for multiple channels when necessary
    
    
    properties (Access=protected, SetObservable)
        %PRIVGAIN Property is of type 'DFILTScalar user-defined'
        privgain = [];
        %REFGAIN Property is of type 'DFILTScalar user-defined'
        refgain = [];
    end
    
    properties (SetObservable)
        %GAIN Property is of type 'mxArray'
        Gain = 1;
    end
    
    properties (Transient, SetObservable)
        %ARITHMETIC Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
        Arithmetic = 'double';
    end
    
    
    methods  % constructor block
        function Hd = scalar(g)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            
            Hd.FilterStructure = 'Scalar';
            Hd.Arithmetic = 'double';
            Hd.Gain = 1;
            
            if nargin>=1
                Hd.Gain = g;
            end
        end  % scalar
    end  % constructor block
    
    methods
        function value = get.Arithmetic(obj)
            value = get_arith(obj,obj.Arithmetic);
        end
        function set.Arithmetic(obj,value)
            % Enumerated DataType = 'filterdesign_arith enumeration: {'double','single','fixed'}'
            value = validatestring(value,{'double','single','fixed'},'','Arithmetic');
            obj.Arithmetic = set_arith(obj,value);
        end
        
        function value = get.Gain(obj)
            value = getgain(obj,obj.Gain);
        end
        function set.Gain(obj,value)
            obj.Gain = setgain(obj,value);
        end
        
        function set.privgain(obj,value)
            % User-defined DataType = 'DFILTScalar user-defined'
            obj.privgain = value;
        end
        
        function set.refgain(obj,value)
            % User-defined DataType = 'DFILTScalar user-defined'
            obj.refgain = setrefgain(obj,value);
        end
        
    end   % set and get functions
    
    methods
        [A,B,C,D] = ss(Hd)
        info = qtoolinfo(this)
        [result,errstr,errorObj] = ishdlable(Hb)
    end  % public methods
    
    
    methods (Hidden)
        [lib,srcblk,hasInputProcessing,hasRateOptions] = blocklib(~,~)
        pv = blockparams(this,mapstates,varargin)
        c = coefficientnames(Hd)
        c = coefficientvariables(h)
        hF = createhdlfilter(this)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        s = dispstr(Hd,varargin)
        Ht = firxform(Ho,fun,varargin)
        infoheader = getinfoheader(this)
        g = getgain(Hd,g)
        g = getrefgain(h)
        [Ht,anum,aden] = iirxform(Ho,fun,varargin)
        s = internalsettings(this)
        b = isblockable(~)
        fixflag = isfixedptable(Hd)
        loadreferencecoefficients(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        s = objblockparams(this,varname)
        quantizecoeffs(h,eventData)
        rcnames = refcoefficientnames(this)
        rcvals = refvals(this)
        s = savereferencecoefficients(this)
        [y,zf] = secfilter(Hd,x,zi)
        g = setgain(Hd,g)
        g = setrefgain(Hd,g)
        setrefvals(this,refvals)
        c = thiscoefficients(Hd)
        thisdisp(this)
        constr = thisfiltquant_plugins(h,arith)
        f = thisisreal(Hd)
        f = thisisrealizable(Hd)
        f = thisisscalarstructure(Hd)
        f = thisisstable(Hd)
        g = thisnormalize(Hd)
        n = thisnstates(Hd)
        thisunnormalize(Hd,g)
        zi = ziexpand(Hd,x,zi)
    end  % possibly private or hidden
    
end  % classdef

