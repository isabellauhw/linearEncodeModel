classdef (Abstract) abstractlattice < dfilt.singleton
    %ABSTRACTLATTICE Abstract class
    
    %dfilt.abstractlattice class
    %   dfilt.abstractlattice extends dfilt.singleton.
    %
    %    dfilt.abstractlattice properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       Lattice - Property is of type 'mxArray'
    %
    %    dfilt.abstractlattice methods:
    %       dispatch -   Return the LWDFILT.
    %       getbestprecision - Return best precision for Product and Accumulator
    %       getlattice - Overloaded get on the Lattice property.
    %       internalsettings - Returns the fixed-point settings viewed by the algorithm.
    %       get_isrealizable - True if the structure can be realized by simulink
    %       isblockable - True if the object supports the block method
    %       isblockmapcoeffstoports - True if the object is blockmapcoeffstoports
    %       isfixedptable - True is the structure has an Arithmetic field
    %       islattice - True if lattice structure
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       nadd - Returns the number of adders
    %       parse_coeffstoexport - Store coefficient names and values into hTar for
    %       qtoolinfo -   Return the information for the qtool.
    %       quantizecoeffs - Quantize coefficients
    %       reflattice - Return reference Lattice.
    %       refvals -   Reference coefficient values.
    %       savereferencecoefficients -   Save the reference coefficients.
    %       setlattice - Overloaded set on the Lattice property.
    %       setrefvals -   Set reference values.
    %       thisdisp - Object display.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisisrealizable - True if the structure can be realized by simulink
    %       usepairinorder0 - Whether to use both gain and its conjugate in order 0
    
    
    properties (Access=protected, SetObservable)
        %PRIVLATTICE Property is of type 'DFILTCoefficientVector user-defined'
        privlattice = [];
        %PRIVCONJLATTICE Property is of type 'DFILTCoefficientVector user-defined'
        privconjlattice = [];
        %REFLATTICE Property is of type 'DFILTCoefficientVector user-defined'
        reflattice = [];
    end
    
    properties (SetObservable)
        %LATTICE Property is of type 'mxArray'
        Lattice = [];
    end
    
    properties (Transient, SetObservable)
        %ARITHMETIC Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
        Arithmetic = 'double';
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
        
        function value = get.Lattice(obj)
            value = getlattice(obj,obj.Lattice);
        end
        function set.Lattice(obj,value)
            obj.Lattice = setlattice(obj,value);
        end
        
        function set.privlattice(obj,value)
            % User-defined DataType = 'DFILTCoefficientVector user-defined'
            obj.privlattice = value;
        end
        
        function set.privconjlattice(obj,value)
            % User-defined DataType = 'DFILTCoefficientVector user-defined'
            obj.privconjlattice = value;
        end
        
        function set.reflattice(obj,value)
            % User-defined DataType = 'DFILTCoefficientVector user-defined'
            obj.reflattice = setreflattice(obj,value);
        end
        
    end   % set and get functions
    
    methods 
       info = qtoolinfo(this) 
    end %public methods
    
    methods (Hidden)
        rcnames = abslatticerefcoefficientnames(this)
        Hd = dispatch(this)
        s = getbestprecision(h)
        lat = getlattice(Hd,lat)
        n = getreflattice(h)
        s = internalsettings(h)
        b = isblockable(~)
        b = isblockmapcoeffstoports(this)
        fixflag = isfixedptable(Hd)
        b = islattice(~)
        loadreferencecoefficients(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        [f,offset] = multfactor(this)
        n = nadd(this)
        [hTar,domapcoeffstoports] = parse_coeffstoexport(Hd,hTar)
        quantizecoeffs(Hd,eventData)
        rcnames = refcoefficientnames(this)
        rcvals = refvals(this)
        s = savereferencecoefficients(this)
        lattice = setlattice(Hd,lattice)
        reflattice = setreflattice(Hd,reflattice)
        setrefvals(this,refvals)
        thisdisp(this)
        constr = thisfiltquant_plugins(h,arith)
        f = thisisrealizable(Hd)
        g = thisnormalize(Hd)
        thisunnormalize(Hd,g)
        b = usepairinorder0(this)
    end  % possibly private or hidden
    
end  % classdef

