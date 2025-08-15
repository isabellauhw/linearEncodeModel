classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) latticear < dfilt.abstractlattice
    %LATTICEAR Lattice Autoregressive (AR).
    %   Hd = DFILT.LATTICEAR(LATTICE) constructs a discrete-time lattice AR
    %   filter object Hd with lattice coefficients K. If K is not
    %   specified, it defaults to []. In this case, the filter passes the input
    %   through to the output unchanged.
    %
    %   Notice that the DSP System Toolbox, along with the Fixed-Point Designer,
    %   enables fixed-point support.
    %
    %   % EXAMPLE
    %   k = [.66 .7 .44];
    %   Hd = dfilt.latticear(k)
    %   realizemdl(Hd); % Requires Simulink
    %
    %   See also DFILT/STRUCTURES, TF2LATC
    
    %dfilt.latticear class
    %   dfilt.latticear extends dfilt.abstractlattice.
    %
    %    dfilt.latticear properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       Lattice - Property is of type 'mxArray'
    %
    %    dfilt.latticear methods:
    %       blocklib - BLOCKPARAMS Returns the library and source block for BLOCKPARAMS
    %       blockparams - Returns the parameters for BLOCK
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient variables.
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       dispatch -   Returns a LWDFILT.
    %       dispstr - Display string of coefficients.
    %       doFrameProcessing - Returns true if frame processing if supported by realizemdl()
    %       getstates - Overloaded get for the States property.
    %       secfilter - Filter this section.
    %       ss -  Discrete-time filter to state-space conversion.
    %       statespaceab - A and B matrices of statespace realization.
    %       thiscoefficients - Filter coefficients.
    %       thisisreal -  True for filter with real coefficients.
    %       thisisstable -  True if filter is stable.
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       thissetstates - Overloaded set for the States property.
    %       tosysobj - Convert dfilt Lattice AR structure to System object
    %       useconjugategaininorder0 - Whether to use conjugate gain in 0th order case
    
    
    
    methods  % constructor block
        function Hd = latticear(lattice)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.FilterStructure = 'Lattice Autoregressive (AR)';
            Hd.Arithmetic = 'double';
            Hd.Lattice = [];
            Hd.States = [];
            if nargin>=1
                Hd.Lattice = lattice;
            end
            
        end  % latticear
        
    end  % constructor block
    
    methods  % public methods
        [A,B,C,D] = ss(Hd)
    end  % public methods
    
    methods(Hidden)
        [lib,srcblk,hasInputProcessing,hasRateOptions] = blocklib(~,link2obj,forceDigitalFilterBlock)
        s = blockparams(Hd,mapstates,forceDigitalFilterBlock)
        c = coefficientnames(Hd)
        c = coefficientvariables(h)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        s = dispstr(Hd,varargin)
        flag = doFrameProcessing(~)
        S = getstates(Hm,S)
        [y,zf] = secfilter(Hd,x,zi)
        [a,b] = statespaceab(Hd)
        c = thiscoefficients(Hd)
        f = thisisreal(Hd)
        f = thisisstable(Hd)
        n = thisnstates(Hd)
        S = thissetstates(Hd,S)
        Hs = tosysobj(this,returnSysObj)
        b = useconjugategaininorder0(this)
    end
    
end  % classdef

