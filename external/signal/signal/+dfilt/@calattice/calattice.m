classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) calattice < dfilt.coupledallpass
    %CALATTICE Coupled-allpass lattice.
    %   Hd = DFILT.CALATTICE(K1,K2,BETA) constructs a discrete-time
    %   coupled-allpass lattice filter object with K1 as lattice coefficients in
    %   the first allpass, K2 as lattice coefficients in the second allpass, and
    %   scalar BETA.
    %
    %   This structure is only available with the DSP System Toolbox.
    %
    %   Example:
    %     [b,a]=butter(5,.5);
    %     [k1,k2,beta]=tf2cl(b,a);
    %     Hd = dfilt.calattice(k1,k2,beta)
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.calattice class
    %   dfilt.calattice extends dfilt.coupledallpass.
    %
    %    dfilt.calattice properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Allpass1 - Property is of type 'mxArray'
    %       Allpass2 - Property is of type 'mxArray'
    %       Beta - Property is of type 'mxArray'
    %
    %    dfilt.calattice methods:
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient variables.
    %       dispatch -   Returns the LWDFILT.
    %       dispstr - Display string of coefficients.
    %       getallpass1 - Overloaded get on the Allpass1 property
    %       getallpass2 - Overloaded get on the Allpass2 property
    %       getbeta - Overloaded get on the Beta property
    %       getcoupledgain - Return the value (string) of the gain that couple the
    %       getcoupledsum - Return the value (string) of the summer that couple the
    %       getstates - Overloaded get for the States property.
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       quantizecoeffs -  Quantize coefficients
    %       refvals -   Return the reference values.
    %       savereferencecoefficients -   Save the reference coefficients.
    %       secfilter - Filter this section.
    %       setallpass1 - Overloaded set on the Allpass1 property
    %       setallpass1q - Overloaded set on the Allpass1q property
    %       setallpass2 - Overloaded set on the Allpass2 property
    %       setallpass2q - Overloaded set on the Allpass2q property
    %       setbeta - Overloaded set on the Beta property
    %       setrefvals -   Set reference values.
    %       ss -  Discrete-time filter to state-space conversion.
    %       thiscoefficients - Filter coefficients.
    %       thisdisp - Object display.
    %       thisisfir -  True for FIR filter.
    %       thisisreal -  True for filter with real coefficients.
    %       thisisstable -  True if filter is stable.
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       thissetstates - Overloaded set for the States property.
    %       tosysobj - Convert to a System object
    
    
    properties (Access=protected, SetObservable)
        %ALLPASS1Q Property is of type 'DFILTCoefficientVector user-defined'
        Allpass1q = [];
        %ALLPASS2Q Property is of type 'DFILTCoefficientVector user-defined'
        Allpass2q = [];
        %PRIVBETA Property is of type 'DFILTScalar user-defined'
        privBeta = [];
        %REFALLPASS1 Property is of type 'DFILTCoefficientVector user-defined'
        refAllpass1 = [];
        %REFALLPASS2 Property is of type 'DFILTCoefficientVector user-defined'
        refAllpass2 = [];
        %REFBETA Property is of type 'DFILTScalar user-defined'
        refBeta = [];
        %PRIVALLPASS1 Property is of type 'dfilt.latticeallpass'
        privAllpass1 = dfilt.latticeallpass;
        %PRIVALLPASS2 Property is of type 'dfilt.latticeallpass'
        privAllpass2 = dfilt.latticeallpass;
    end
    
    properties (SetObservable)
        %ALLPASS1 Property is of type 'mxArray'
        Allpass1 = [];
        %ALLPASS2 Property is of type 'mxArray'
        Allpass2 = [];
        %BETA Property is of type 'mxArray'
        Beta = [];
    end
    
    
    methods  % constructor block
        function Hd = calattice(k1,k2,beta)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            
            Hd.FilterStructure = 'Coupled-Allpass Lattice';
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
            
        end  % calattice
    end  % constructor block
    
    methods
        function value = get.Allpass1(obj)
            value = getallpass1(obj,obj.Allpass1);
        end
        function set.Allpass1(obj,value)
            obj.Allpass1 = setallpass1(obj,value);
        end
        
        function value = get.Allpass2(obj)
            value = getallpass2(obj,obj.Allpass2);
        end
        function set.Allpass2(obj,value)
            obj.Allpass2 = setallpass2(obj,value);
        end
        
        function value = get.Beta(obj)
            value = getbeta(obj,obj.Beta);
        end
        function set.Beta(obj,value)
            obj.Beta = setbeta(obj,value);
        end
        
        function set.Allpass1q(obj,value)
            % User-defined DataType = 'DFILTCoefficientVector user-defined'
            obj.Allpass1q = setallpass1q(obj,value);
        end
        
        function set.Allpass2q(obj,value)
            % User-defined DataType = 'DFILTCoefficientVector user-defined'
            obj.Allpass2q = setallpass2q(obj,value);
        end
        
        function set.privBeta(obj,value)
            % User-defined DataType = 'DFILTScalar user-defined'
            obj.privBeta = setprivbeta(obj,value);
        end
        
        function set.refAllpass1(obj,value)
            % User-defined DataType = 'DFILTCoefficientVector user-defined'
            obj.refAllpass1 = value;
        end
        
        function set.refAllpass2(obj,value)
            % User-defined DataType = 'DFILTCoefficientVector user-defined'
            obj.refAllpass2 = value;
        end
        
        function set.refBeta(obj,value)
            % User-defined DataType = 'DFILTScalar user-defined'
            obj.refBeta = value;
        end
        
        function set.privAllpass1(obj,value)
            % DataType = 'dfilt.latticeallpass'
            validateattributes(value,{'dfilt.latticeallpass'}, {'scalar'},'','privAllpass1')
            obj.privAllpass1 = value;
        end
        
        function set.privAllpass2(obj,value)
            % DataType = 'dfilt.latticeallpass'
            validateattributes(value,{'dfilt.latticeallpass'}, {'scalar'},'','privAllpass2')
            obj.privAllpass2 = value;
        end
        
    end   % set and get functions
    
    methods
        [A,B,C,D] = ss(Hd)
    end  % public methods
    
    
    methods (Hidden)
        c = coefficientnames(Hd)
        c = coefficientvariables(h)
        Hd = dispatch(this)
        s = dispstr(Hd,varargin)
        coeffs = getallpass1(Hd,coeffs)
        coeffs = getallpass2(Hd,coeffs)
        coeffs = getbeta(Hd,coeffs)
        g = getcoupledgain(Hd)
        str = getcoupledsum(Hd)
        S = getstates(Hm,S)
        loadreferencecoefficients(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        quantizecoeffs(h,eventData)
        rcnames = refcoefficientnames(this)
        rcvals = refvals(this)
        s = savereferencecoefficients(this)
        [y,zf] = secfilter(Hd,x,zi)
        coeffs = setallpass1(Hd,coeffs)
        coeffs = setallpass1q(Hd,coeffs)
        coeffs = setallpass2(Hd,coeffs)
        coeffs = setallpass2q(Hd,coeffs)
        coeffs = setbeta(Hd,coeffs)
        setrefvals(this,refvals)
        c = thiscoefficients(Hd)
        thisdisp(this)
        f = thisisfir(Hd)
        f = thisisreal(Hd)
        f = thisisstable(Hd)
        g = thisnormalize(Hd)
        n = thisnstates(Hd)
        S = thissetstates(Hm,S)
        thisunnormalize(Hd,g)
        Hs = tosysobj(this,returnSysObj)
    end  % possibly private or hidden
    
end  % classdef

function beta = setprivbeta(~, beta)

if ~isdeployed
    if ~license('checkout','Signal_Blocks')
        error(message('signal:dfilt:calattice:schema:LicenseRequired'));
    end
end
end  % setprivbeta

