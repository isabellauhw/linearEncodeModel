classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) calatticepc < dfilt.calattice
    %CALATTICEPC Power-complementary coupled-allpass lattice.
    %   Hd = DFILT.CALATTICEPC(K1,K2,BETA) constructs a discrete-time
    %   coupled-allpass lattice with power-complementary output object with K1 as
    %   lattice coefficients in the first allpass, K2 as lattice coefficients in the
    %   second allpas, and scalar BETA.
    %
    %   This structure is only available with the DSP System Toolbox.
    %
    %   Example:
    %     [b,a]=butter(5,.5);
    %     [k1,k2,beta]=tf2cl(b,a);
    %     Hd = dfilt.calatticepc(k1,k2,beta)
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.calatticepc class
    %   dfilt.calatticepc extends dfilt.calattice.
    %
    %    dfilt.calatticepc properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Allpass1 - Property is of type 'mxArray'
    %       Allpass2 - Property is of type 'mxArray'
    %       Beta - Property is of type 'mxArray'
    %
    %    dfilt.calatticepc methods:
    %       coefficientvariables - Coefficient variables.
    %       dispatch -   Returns the LWDFILT.
    %       getcoupledgain - Return the value (string) of the gain that couple the
    %       getcoupledsum - Return the value (string) of the summer that couple the
    %       secfilter - Filter this section.
    %       ss -  Discrete-time filter to state-space conversion.
    %       tosysobj - Convert to a System object
    
    
    
    methods  % constructor block
        function Hd = calatticepc(k1,k2,beta)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.FilterStructure = 'Coupled-Allpass Lattice, Power Complementary Output';
            Hd.Beta = 1;
            
            if nargin>=1
                Hd.Allpass1 = k1;
            end
            
            if nargin>=2
                Hd.Allpass2 = k2;
            end
            
            if nargin>=3
                Hd.Beta = beta;
            end
            
        end  % calatticepc
        
    end  % constructor block
    
    methods  % public methods
        [A,B,C,D] = ss(Hd)
    end
    
    methods(Hidden)
        c = coefficientvariables(h)
        Hd = dispatch(this)
        g = getcoupledgain(Hd)
        str = getcoupledsum(Hd)
        [y,zf] = secfilter(Hd,x,zi)
        Hs = tosysobj(this,returnSysObj)
    end
end  % classdef

