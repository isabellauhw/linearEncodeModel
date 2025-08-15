classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) delay < dfilt.singleton
    %DELAY Integer delay.
    %   Hd = DFILT.DELAY(D) constructs a discrete-time integer delay object
    %   with a latency of D.
    %
    %   % EXAMPLE
    %   Hd = dfilt.delay(2)
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.delay class
    %   dfilt.delay extends dfilt.singleton.
    %
    %    dfilt.delay properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       Latency - Property is of type 'mxArray'
    %
    %    dfilt.delay methods:
    %       blocklib - BLOCKPARAMS Returns the library and source block for BLOCKPARAMS
    %       blockparams -   Return the block parameters.
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient variables.
    %       createhdlfilter - CREATHDLFILTER <short description>
    %       dgdfgen - Generates the dg_dfilt structure
    %       dispatch -   Return the lwdfilt.
    %       get_latency -   PreGet function for the 'latency' property.
    %       iirxform -   IIR Transformations.
    %       isblockable - True if the object supports the block method
    %       ishdlable - True if HDL can be generated for the filter object.
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       quantizecoeffs -  Quantize coefficients
    %       savereferencecoefficients -   Save the reference coefficients.
    %       secfilter - Filter this section.
    %       set_latency -   PreSet function for the 'latency' property.
    %       thiscoefficients - Filter coefficients.
    %       thisdisp - Object display.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisisrealizable - True if the structure can be realized by simulink
    %       thisisstable -  True if filter is stable.
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    
    
    properties (Access=protected, Transient, SetObservable)
        %PRIVNSTATES Property is of type 'spt_uint32 user-defined'
        privnstates = [];
    end
    
    properties (SetObservable)
        %LATENCY Property is of type 'mxArray'
        Latency = 1;
    end
    
    properties (Transient, SetObservable)
        %ARITHMETIC Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
        Arithmetic = 'double';
    end
    
    
    methods  % constructor block
        function this = delay(lat)
            
            this.privfq = dfilt.filterquantizer;
            this.privfilterquantizer = dfilt.filterquantizer;
            this.FilterStructure = 'Delay';
            this.Latency = 1;
            this.Arithmetic = 'double';
            this.States = [];
            if nargin>=1
                this.Latency = lat;
            end
            
            
        end  % delay
        
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
        
        function value = get.Latency(obj)
            value = get_latency(obj,obj.Latency);
        end
        function set.Latency(obj,value)
            obj.Latency = set_latency(obj,value);
        end
        
        function set.privnstates(obj,value)
            % User-defined DataType = 'spt_uint32 user-defined'
            obj.privnstates = value;
        end
        
    end   % set and get functions
    
    methods
        [result,errstr,errorObj] = ishdlable(Hb)
    end
    
    methods (Hidden)
        [lib,srcblk,hasInputProcessing,hasRateOptions] = blocklib(~,~)
        pv = blockparams(this,mapstates,varargin)
        c = coefficientnames(Hd)
        c = coefficientvariables(~)
        hF = createhdlfilter(this)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        latency = get_latency(this,latency)
        [Ht,anum,aden] = iirxform(Ho,fun,varargin)
        b = isblockable(~)
        loadreferencecoefficients(this,s)
        [f,offset] = multfactor(this)
        s = objblockparams(this,varname)
        labels = propnames(this)
        coeffs = propvalues(this)
        quantizecoeffs(h,eventData)
        s = savereferencecoefficients(this)
        [y,zf] = secfilter(this,x,zi)
        latency = set_latency(this,latency)
        c = thiscoefficients(this)
        thisdisp(this)
        constr = thisfiltquant_plugins(h,arith)
        [p,v] = thisinfo(this)
        f = thisisreal(this)
        f = thisisrealizable(Hd)
        f = thisisstable(Hd)
        n = thisnstates(this)
    end  % possibly private or hidden
    
end  % classdef

