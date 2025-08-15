classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) dffirt < dfilt.dtffir
    %DFFIRT Direct-Form FIR Transposed.
    %   Hd = DFILT.DFFIRT(NUM) constructs a discrete-time, direct-form FIR
    %   transposed filter object Hd, with numerator coefficients NUM.
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
    %   Hd = dfilt.dffirt(b)
    %   realizemdl(Hd)    % Requires Simulink
    %
    %   % EXAMPLE #2: Design an equiripple lowpass filter with default specifications
    %   Hd = design(fdesign.lowpass, 'equiripple', 'Filterstructure', 'dffirt');
    %   fvtool(Hd)        % Analyze filter
    %   x = randn(100,1); % Input signal
    %   y = filter(Hd,x); % Apply filter to input signal
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.dffirt class
    %   dfilt.dffirt extends dfilt.dtffir.
    %
    %    dfilt.dffirt properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Numerator - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %
    %    dfilt.dffirt methods:
    %       blockparams - Returns the parameters for BLOCK
    %       createhdlfilter - Returns the corresponding hdlfiltercomp for HDL Code
    %       dfobjsfcnparams - S function parameters for SDSPFILTER
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       firxform - FIR Transformations
    %       getstates - Overloaded get for the States property.
    %       iirxform - IIR Transformations
    %       qtoolinfo -   Returns information for the QTool.
    %       secfilter - Filter this section.
    %       set2int - Scales the coefficients to integer numbers.
    %       setnumerator -   Set the numerator.
    %       ss -  Discrete-time filter to state-space conversion.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisisrealizable - True if the structure can be realized by simulink
    %       thissetstates - Overloaded set for the States property.
    
    
    properties (Transient, SetObservable)
        %ARITHMETIC Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
        Arithmetic = 'double';
    end
    
    
    methods  % constructor block
        function Hd = dffirt(num)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.ncoeffs = 1;
            Hd.FilterStructure = 'Direct-Form FIR Transposed';
            Hd.Arithmetic = 'double';
            Hd.Numerator = 1;
            Hd.States = [];
            
            if nargin>=1
                Hd.Numerator = num;
            end
            
        end  % dffirt
        
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
        hF = createhdlfilter(this)
        s = dfobjsfcnparams(Hd)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Ht = firxform(Ho,fun,varargin)
        S = getstates(Hm,S)
        [Ht,anum,aden] = iirxform(Ho,fun,varargin)
        [y,zf] = secfilter(Hd,x,zi)
        varargout = set2int(this,coeffWL,inWL)
        num = setnumerator(this,num)
        constr = thisfiltquant_plugins(h,arith)
        f = thisisrealizable(Hd)
        S = thissetstates(Hd,S)
    end
    
end  % classdef

