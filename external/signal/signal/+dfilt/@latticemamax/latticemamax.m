classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) latticemamax < dfilt.latticemamin
    %LATTICEMAMAX Lattice Moving-Average for Maximum Phase.
    %   Hd = DFILT.LATTICEMAMAX(K) constructs a Lattice moving-average (MA) for
    %   maximum phase discrete-time filter object Hd with lattice coefficients K.
    %   If K is not specified, it defaults to []. In this case, the filter
    %   passes the input through to the output unchanged.
    %
    %   Notice that if the K coefficients define a maximum phase filter, the
    %   resulting filter in this structure is maximum phase. If your
    %   coefficients do not define a maximum phase filter, placing them in this
    %   structure does not produce a maximum phase filter.
    %
    %   Also, the DSP System Toolbox, along with the Fixed-Point Designer,
    %   enables fixed-point support.
    %
    %   % EXAMPLE
    %   k = [.66 .7 0.44 .33];
    %   Hd = dfilt.latticemamax(k)
    %   ismax = ismaxphase(Hd)
    %   realizemdl(Hd); % Requires Simulink
    %
    %   See also DFILT/STRUCTURES, TF2LATC
    
    %dfilt.latticemamax class
    %   dfilt.latticemamax extends dfilt.latticemamin.
    %
    %    dfilt.latticemamax properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       Lattice - Property is of type 'mxArray'
    %
    %    dfilt.latticemamax methods:
    %       blockparams - Returns the parameters for BLOCK
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       dispatch -   Returns a LWDFILT.
    %       isblockable - True if the object supports the block method
    %       secfilter - Filter this section.
    %       ss -  Discrete-time filter to state-space conversion.
    %       tosysobj - Convert to a System object
    %       useconjugategaininorder0 - Whether to use conjugate gain in 0th order case
    
    
    
    methods  % constructor block
        function Hd = latticemamax(lattice)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.FilterStructure = 'Lattice Moving-Average (MA) For Maximum Phase';
            Hd.Arithmetic = 'double';
            Hd.Lattice = [];
            Hd.States = [];
            if nargin>=1
                Hd.Lattice = lattice;
            end
            
        end  % latticemamax
        
    end  % constructor block
    
    methods
        [A,B,C,D] = ss(Hd)
    end  % public methods
    
    
    methods (Hidden)
        [lib,srcblk,s] = blockparams(Hd,mapstates,varargin)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        b = isblockable(~)
        s = objblockparams(this,varname)
        [y,zf] = secfilter(Hd,x,zi)
        Hs = tosysobj(this,returnSysObj)
        b = useconjugategaininorder0(this)
    end  % possibly private or hidden
    
end  % classdef

