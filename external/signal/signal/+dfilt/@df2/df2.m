classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) df2 < dfilt.dtfiir
    %DF2 Direct-Form II.
    %   Hd = DFILT.DF2(NUM, DEN) constructs a discrete-time direct-form II
    %   filter object Hd, with numerator coefficients NUM and denominator
    %   coefficients DEN. The leading coefficient of the denominator DEN(1)
    %   cannot be 0.
    %
    %   Notice that the DSP System Toolbox, along with the Fixed-Point Designer,
    %   enables fixed-point support.
    %
    %   Also, notice that direct-form implementations of IIR filters can lead
    %   to numerical problems. In many cases, it can be advantageous to avoid
    %   forming the transfer function and to use a <a href="matlab:help dfilt.df2sos">second-order section</a>
    %   implementation.
    %
    %   % EXAMPLE #1: Direct instantiation
    %   [b,a] = butter(4,.5);
    %   Hd = dfilt.df2(b,a)
    %
    %   % EXAMPLE #2: Design a 10th order lowpass filter in section order sections
    %   f = fdesign.lowpass('N,F3dB',10,.5);  % Specifications
    %   Hd = design(f, 'butter', 'Filterstructure', 'df2sos')
    %
    %   See also DFILT/STRUCTURES.
    
    %dfilt.df2 class
    %   dfilt.df2 extends dfilt.dtfiir.
    %
    %    dfilt.df2 properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Numerator - Property is of type 'mxArray'
    %       Denominator - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %
    %    dfilt.df2 methods:
    %       blockparams - Returns the parameters for BLOCK
    %       dfobjsfcnparams - Returns the parameters for SDSPFILTER
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       getstates - Overloaded get for the States property.
    %       internalsettings - Returns the fixed-point settings viewed by the algorithm.
    %       qtoolinfo -   Return the information for the qtool.
    %       secfilter - Filter this section.
    %       setnumerator -   Set the numerator.
    %       sos -  Convert to second-order-sections.
    %       ss -  Discrete-time filter to state-space conversion.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       thissetstates - Overloaded set for the States property.
    %       thissos - Second-order-section version of this class.
    
    
    
    methods  % constructor block
        function Hd = df2(num,den)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.FilterStructure = 'Direct-Form II';
            
            % Tap Index is a vector of two elements. The first element corresponds to
            % the WRITE index the circular buffer. The second index is not used.
            Hd.TapIndex = [0 0];
            
            % Hard code the default number of coefficients to avoid special cases in
            % the thissetstates and getstates methods.
            Hd.ncoeffs = [1 1];
            Hd.Numerator = 1;
            Hd.Denominator = 1;
            Hd.States = [];
            Hd.Arithmetic = 'double';
            
            if nargin>=1
                Hd.Numerator = num;
            end
            
            if nargin>=2
                Hd.Denominator = den;
            end
            
            
        end  % df2
        
    end  % constructor block
    
    methods  % public methods
        Hsos = sos(Hd,varargin)
        [A,B,C,D] = ss(Hd)
        info = qtoolinfo(this)
    end  % public methods
    
    
    methods (Hidden) % possibly private or hidden
        s = blockparams(Hd,mapstates,forceDigitalFilterBlock)
        varargout = dfobjsfcnparams(Hd)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        S = getstates(Hd,S)
        s = internalsettings(h)
        [y,zf] = secfilter(Hd,x,zi)
        num = setnumerator(this,num)
        constr = thisfiltquant_plugins(h,arith)
        [y,zi,overflows] = thislimitcycle(Hd,x)
        n = thisnstates(Hd)
        S = thissetstates(Hd,S)
        Hsos = thissos(Hd,c)
    end  % possibly private or hidden
    
end  % classdef

