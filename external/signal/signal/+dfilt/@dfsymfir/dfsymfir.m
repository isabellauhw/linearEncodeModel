classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) dfsymfir < dfilt.abstractdfsymfir
    %DFSYMFIR Direct-Form Symmetric FIR.
    %   Hd = DFILT.DFSYMFIR(NUM) constructs a discrete-time, direct-form
    %   symmetric FIR filter object Hd, with numerator coefficients NUM.
    %
    %   Note that one usually does not construct DFILT filters explicitly.
    %   Instead, one obtains these filters as a result from a design using <a
    %   href="matlab:help fdesign">FDESIGN</a>.
    %
    %   Also, the DSP System Toolbox, along with the Fixed-Point Designer,
    %   enables fixed-point support.
    %
    %   % EXAMPLE #1: Direct instantiation
    %   b = [-0.008 0.06 0.44 0.44 0.06 -0.008];
    %   Hd = dfilt.dfsymfir(b)
    %   realizemdl(Hd)    % Requires Simulink
    %
    %   % EXAMPLE #2: Design an equiripple lowpass filter with default specifications
    %   Hd = design(fdesign.lowpass, 'equiripple', 'Filterstructure', 'dfsymfir');
    %   fvtool(Hd)        % Analyze filter
    %   x = randn(100,1); % Input signal
    %   y = filter(Hd,x); % Apply filter to input signal
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.dfsymfir class
    %   dfilt.dfsymfir extends dfilt.abstractdfsymfir.
    %
    %    dfilt.dfsymfir properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Numerator - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %
    %    dfilt.dfsymfir methods:
    %       blockparams - Returns the parameters for BLOCK
    %       createhdlfilter - Returns the corresponding hdlfiltercomp for HDL Code
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       dispatch -   Dispatch to the lwdfilt object.
    %       nadd - Returns the number of adders
    %       qtoolinfo -   Returns information for the QTool.
    %       secfilter - Filter this section.
    %       setnumerator - Overloaded set on the Numerator property.
    %       sumstr - Returns the list of signs for the summer block.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    
    
    
    methods  % constructor block
        function Hd = dfsymfir(num)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.ncoeffs = 1;
            Hd.TapIndex = 0;
            Hd.FilterStructure = 'Direct-Form Symmetric FIR';
            Hd.Arithmetic = 'double';
            Hd.Numerator = 1;
            Hd.States = [];
            
            if nargin>=1
                Hd.Numerator = num;
            end  % dfsymfir
        end
    end  % constructor block
    
    methods
        info = qtoolinfo(this)
    end %public methods
    
    methods (Hidden) % possibly private or hidden
        s = blockparams(Hd,mapstates,forceDigitalFilterBlock)
        hF = createhdlfilter(this)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        [f,offset] = multfactor(this)
        n = nadd(this)
        [y,zf] = secfilter(Hd,x,zi)
        num = setnumerator(Hd,num)
        str = sumstr(Hd)
        constr = thisfiltquant_plugins(h,arith)
    end  % possibly private or hidden
    
end  % classdef

