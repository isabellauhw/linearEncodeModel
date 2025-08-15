classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) latticeallpass < dfilt.latticear
    %LATTICEALLPASS Lattice Allpass.
    %   Hd = DFILT.LATTICEALLPASS(LATTICE) constructs a discrete-time lattice
    %   allpass filter object Hd with lattice coefficients K. If K is not
    %   specified, it defaults to []. In this case, the filter passes the input
    %   through to the output unchanged.
    %
    %   Notice that the DSP System Toolbox, along with the Fixed-Point Designer,
    %   enables fixed-point support.
    %
    %   % EXAMPLE
    %   k = [.66 .7 .44];
    %   Hd = dfilt.latticeallpass(k)
    %   realizemdl(Hd); % Requires Simulink
    %
    %   See also DFILT/STRUCTURES, TF2LATC
    
    %dfilt.latticeallpass class
    %   dfilt.latticeallpass extends dfilt.latticear.
    %
    %    dfilt.latticeallpass properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       Lattice - Property is of type 'mxArray'
    %
    %    dfilt.latticeallpass methods:
    %       blockparams - Returns the parameters for BLOCK
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       dispatch -   Return the lightweight DFILT.
    %       isblockable - True if the object supports the block method
    %       secfilter - Filter this section.
    %       ss -  Discrete-time filter to state-space conversion.
    %       tosysobj - Convert to a System object
    %       usepairinorder0 - Whether to use both gain and its conjugate in order 0
    
    
    
    methods  % constructor block
        function Hd = latticeallpass(lattice)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.FilterStructure = 'Lattice Allpass';
            Hd.Arithmetic = 'double';
            Hd.Lattice = [];
            Hd.States = [];
            if nargin>=1
                Hd.Lattice = lattice;
            end
            
        end  % latticeallpass
        
    end  % constructor block
    
    methods  % public methods
        [A,B,C,D] = ss(Hd)
    end  % public methods
    
    
    methods (Hidden) % possibly private or hidden
        [lib,srcblk,s] = blockparams(Hd,mapstates,varargin)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        b = isblockable(~)
        [f,offset] = multfactor(this)
        s = objblockparams(this,varname)
        [y,zf] = secfilter(Hd,x,zi)
        Hs = tosysobj(this,returnSysObj)
        b = usepairinorder0(this)
    end  % possibly private or hidden
    
end  % classdef

