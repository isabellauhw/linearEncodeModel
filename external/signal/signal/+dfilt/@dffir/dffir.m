classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) dffir < dfilt.dtffir
    %DFFIR Direct-Form FIR.
    %   Hd = DFILT.DFFIR(NUM) constructs a discrete-time, direct-form FIR filter
    %   object Hd, with numerator coefficients NUM.
    %
    %   Note that one usually does not construct DFILT filters explicitly.
    %   Instead, one obtains these filters as a result from a design using <a
    %   href="matlab:help fdesign">FDESIGN</a>.
    %
    %   Also, the DSP System Toolbox, along with the Fixed-Point Designer,
    %   enables fixed-point support.
    %
    %   % EXAMPLE #1: Direct instantiation
    %   b = [0.05 0.9 0.05];
    %   Hd = dfilt.dffir(b)
    %   realizemdl(Hd)    % Requires Simulink
    %
    %   % EXAMPLE #2: Design an equiripple lowpass filter with default specifications
    %   Hd = design(fdesign.lowpass, 'equiripple', 'Filterstructure', 'dffir');
    %   fvtool(Hd)        % Analyze filter
    %   x = randn(100,1); % Input signal
    %   y = filter(Hd,x); % Apply filter to input signal
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.dffir class
    %   dfilt.dffir extends dfilt.dtffir.
    %
    %    dfilt.dffir properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Numerator - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %
    %    dfilt.dffir methods:
    %       blockparams - Returns the parameters for BLOCK
    %       coewrite - Write a XILINX CORE Generator(tm) coefficient (.COE) file.
    %       createhdlfilter - Returns the corresponding hdlfiltercomp for HDL Code
    %       dfobjsfcnparams - S function parameters for SDSPFILTER
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       firxform - FIR Transformations
    %       getstates - Overloaded get for the States property.
    %       get_isrealizable - True if the structure can be realized by simulink
    %       iirxform - IIR Transformations
    %       qtoolinfo -   Returns information for the QTool.
    %       secfilter - Filter this section.
    %       set2int - Scales the coefficients to integer numbers.
    %       ss -  Discrete-time filter to state-space conversion.
    %       thissetstates - Overloaded set for the States property.
    
    
    properties (Transient, SetObservable)
        %ARITHMETIC Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
        Arithmetic = 'double';
    end
    
    methods  % constructor block
        function Hd = dffir(num)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.ncoeffs = 1;
            Hd.TapIndex = 0;
            Hd.FilterStructure = 'Direct-Form FIR';
            Hd.Arithmetic = 'double';
            Hd.Numerator = 1;
            Hd.States = [];
            
            if nargin>=1
                Hd.Numerator = num;
            end
            
        end  % dffir
        
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
        
    end   % set and get functions
    
    methods
        [A,B,C,D] = ss(Hd)
        info = qtoolinfo(this)
    end  % public methods
    
    methods(Hidden)
        s = blockparams(Hd,mapstates,forceDigitalFilterBlock)
        coewrite(Hq,radix,filename)
        hF = createhdlfilter(this)
        s = dfobjsfcnparams(Hd)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Ht = firxform(Ho,fun,varargin)
        realizeflag = get_isrealizable(Hd)
        S = getstates(Hm,S)
        [Ht,anum,aden] = iirxform(Ho,fun,varargin)
        [y,zf] = secfilter(Hd,x,zi)
        varargout = set2int(this,coeffWL,inWL)
        f = thisisrealizable(Hd)
        S = thissetstates(Hd,S)
    end
end  % classdef

