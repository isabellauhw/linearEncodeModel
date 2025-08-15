classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) latticemamin < dfilt.abstractlattice
    %LATTICEMAMIN Lattice Moving-Average for Minimum Phase.
    %   Hd = DFILT.LATTICEMAMIN(K) constructs a Lattice moving-average (MA) for
    %   minimum phase discrete-time filter object Hd with lattice coefficients K.
    %   If K is not specified, it defaults to []. In this case, the filter
    %   passes the input through to the output unchanged.
    %
    %   Notice that if the K coefficients define a minimum phase filter, the
    %   resulting filter in this structure is minimum phase. If your
    %   coefficients do not define a minimum phase filter, placing them in this
    %   structure does not produce a minimum phase filter.
    %
    %   Also, the DSP System Toolbox, along with the Fixed-Point Designer,
    %   enables fixed-point support.
    %
    %   % EXAMPLE
    %   k = [.66 .7 0.44];
    %   Hd = dfilt.latticemamin(k)
    %   ismin = isminphase(Hd)
    %   realizemdl(Hd); % Requires Simulink
    %
    %   See also DFILT/STRUCTURES, TF2LATC
    
    %dfilt.latticemamin class
    %   dfilt.latticemamin extends dfilt.abstractlattice.
    %
    %    dfilt.latticemamin properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       Lattice - Property is of type 'mxArray'
    %
    %    dfilt.latticemamin methods:
    %       blockparams - Returns the parameters for BLOCK
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient variables.
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       dispstr - Display string of coefficients.
    %       getstates - Overloaded get for the States property.
    %       isblockrequiredst - Check if block method requires a DST license
    %       secfilter - Filter this section.
    %       setlattice - Overloaded set on the Lattice property.
    %       ss -  Discrete-time filter to state-space conversion.
    %       super_ss -  Discrete-time filter to state-space conversion.
    %       thiscoefficients - Filter coefficients.
    %       thisisfir -  True for FIR filter.
    %       thisisreal -  True for filter with real coefficients.
    %       thisisstable -  True if stable.
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       thissetstates - Overloaded set for the States property.
    %       tosysobj - Convert dfilt FIR structure to System object
    %       useconjugategaininorder0 - Whether to use conjugate gain in 0th order case
    
    
    
    methods  % constructor block
        function Hd = latticemamin(lattice)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.FilterStructure = 'Lattice Moving-Average (MA) For Minimum Phase';
            Hd.Arithmetic = 'double';
            Hd.Lattice = [];
            Hd.States = [];
            if nargin>=1
                Hd.Lattice = lattice;
            end
            
        end  % latticemamin
        
    end  % constructor block
    
    methods  % public methods
        [A,B,C,D] = ss(Hd)
    end  % public methods
    
    methods(Hidden)
        s = blockparams(Hd,mapstates,forceDigitalFilterBlock)
        c = coefficientnames(Hd)
        c = coefficientvariables(h)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        s = dispstr(Hd,varargin)
        S = getstates(Hm,S)
        isblockrequiredst(~)
        [y,zf] = secfilter(Hd,x,zi)
        lattice = setlattice(this,lattice)
        [A,B,C,D] = super_ss(Hd)
        C = thiscoefficients(Hd)
        f = thisisfir(Hd)
        f = thisisreal(Hd)
        f = thisisstable(Hd)
        n = thisnstates(Hd)
        S = thissetstates(Hd,S)
        Hs = tosysobj(this,returnSysObj)
        b = useconjugategaininorder0(this)
    end
    
end  % classdef

