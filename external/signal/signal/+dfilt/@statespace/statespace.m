classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) statespace < dfilt.singleton
    %STATESPACE Discrete-time, state-space filter.
    %   Hd = DFILT.STATESPACE(A, B, C, D) returns a discrete-time state-space
    %   filter, Hd, with rectangular arrays A, B, C and D. A, B, C, and D are
    %   from the matrix or state-space form of a filter's difference equations:
    %
    %   x(n+1) = A*x(n) + B*u(n)
    %   y(n)   = C*x(n) + D*u(n)
    %
    %   where x(n) is the vector states at time n,
    %         u(n) is the input at time n,
    %         y    is the output at time n,
    %         A    is the state-transition matrix,
    %         B    is the input-to-state transmission matrix,
    %         C    is the state-to-output transmission matrix, and
    %         D    is the input-to-output transmission matrix.
    %
    %   If A, B, C or D are not specified, they default to [], [], [] and 1.
    %
    %   % EXAMPLE
    %   [A,B,C,D] = butter(2,.5);
    %   Hd = dfilt.statespace(A,B,C,D)
    %
    %   See also DFILT/STRUCTURES, TF2SS, ZP2SS
    
    %dfilt.statespace class
    %   dfilt.statespace extends dfilt.singleton.
    %
    %    dfilt.statespace properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       A - Property is of type 'mxArray'
    %       B - Property is of type 'mxArray'
    %       C - Property is of type 'mxArray'
    %       D - Property is of type 'mxArray'
    %
    %    dfilt.statespace methods:
    %       coefficient_info -   Get the coefficient information for this filter.
    %       coefficientnames -  Coefficient names.
    %       coefficientvariables - Coefficient variables.
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       dispatch -   Return the LWDFILT.
    %       dispstr - Display string of coefficients.
    %       doFrameProcessing - Returns true if frame processing if supported by realizemdl()
    %       geta - Overloaded get function on the A property.
    %       getb - Overloaded get function on the B property.
    %       getc - Overloaded get function on the C property.
    %       getd - Overloaded get function on the D property.
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       quantizecoeffs -  Quantize coefficients
    %       refvals -   Return the reference values.
    %       savereferencecoefficients -   Save the reference coefficients.
    %       secfilter - Filter this section.
    %       seta - Overloaded set function on the A property.
    %       setb - Overloaded set function on the B property.
    %       setc - Overloaded set function on the C property.
    %       setd - Overloaded set function on the D property.
    %       setrefvals -   Set reference values.
    %       ss -  Convert to state-space.
    %       thiscoefficients - Filter coefficients.
    %       thisdisp - Object display.
    %       thisisfir -  True for FIR filter.
    %       thisisreal - Hd) returns 1 if filter Hd has real coefficients, and 0
    %       thisisrealizable -   Return true if the object is realizable
    %       thisisstable -  True if filter is stable.
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       thisorder - Filter order.
    
    
    properties (Access=protected, SetObservable)
        %PRIVA Property is of type 'signalNumeric user-defined'
        privA = [];
        %PRIVB Property is of type 'signalNumeric user-defined'
        privB = [];
        %PRIVC Property is of type 'signalNumeric user-defined'
        privC = [];
        %PRIVD Property is of type 'double'
        privD = 0;
        %REFA Property is of type 'signalNumeric user-defined'
        refA = [];
        %REFB Property is of type 'signalNumeric user-defined'
        refB = [];
        %REFC Property is of type 'signalNumeric user-defined'
        refC = [];
        %REFD Property is of type 'double'
        refD = 0;
    end
    
    properties (SetObservable)
        %A Property is of type 'mxArray'
        A = [  ];
        %B Property is of type 'mxArray'
        B = zeros( 0, 1 );
        %C Property is of type 'mxArray'
        C = zeros( 1, 0 );
        %D Property is of type 'mxArray'
        D = 1;
    end
    
    
    methods  % constructor block
        function Hd = statespace(A,B,C,D)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.FilterStructure = 'State-Space';
            
            % To allow empty inputs to set the defaults
            if nargin<1, A = []; end
            if nargin<2, B = []; end
            if nargin<3, C = []; end
            if nargin<4, D = []; end
            
            % Set the defaults if empty input.  This also forces the right sizes of
            % empties.
            if isempty(A), A = []; end
            if isempty(B), B = zeros(0,1); end
            if isempty(C), C = zeros(1,0); end
            if isempty(D), D = 1; end
            
            % Validate the consistency of the input before setting the object;
            error(abcdchk(A,B,C,D));
            
            Hd.A = A;
            Hd.B = B;
            Hd.C = C;
            Hd.D = D;
            
        end  % statespace
        
    end  % constructor block
    
    methods
        function value = get.A(obj)
            value = geta(obj,obj.A);
        end
        function set.A(obj,value)
            obj.A = seta(obj,value);
        end
        
        function value = get.B(obj)
            value = getb(obj,obj.B);
        end
        function set.B(obj,value)
            obj.B = setb(obj,value);
        end
        
        function value = get.C(obj)
            value = getc(obj,obj.C);
        end
        function set.C(obj,value)
            obj.C = setc(obj,value);
        end
        
        function value = get.D(obj)
            value = getd(obj,obj.D);
        end
        function set.D(obj,value)
            obj.D = setd(obj,value);
        end
        
        function set.privA(obj,value)
            % User-defined DataType = 'signalNumeric user-defined'
            obj.privA = value;
        end
        
        function set.privB(obj,value)
            % User-defined DataType = 'signalNumeric user-defined'
            obj.privB = value;
        end
        
        function set.privC(obj,value)
            % User-defined DataType = 'signalNumeric user-defined'
            obj.privC = value;
        end
        
        function set.privD(obj,value)
            % DataType = 'double'
            validateattributes(value,{'numeric'}, {'scalar'},'','privD')
            value = double(value); %  convert to double
            obj.privD = value;
        end
        
        function set.refA(obj,value)
            % User-defined DataType = 'signalNumeric user-defined'
            obj.refA = value;
        end
        
        function set.refB(obj,value)
            % User-defined DataType = 'signalNumeric user-defined'
            obj.refB = value;
        end
        
        function set.refC(obj,value)
            % User-defined DataType = 'signalNumeric user-defined'
            obj.refC = value;
        end
        
        function set.refD(obj,value)
            % DataType = 'double'
            validateattributes(value,{'numeric'}, {'scalar'},'','refD')
            value = double(value); %  convert to double
            obj.refD = value;
        end
        
    end   % set and get functions
    
    methods
        [A,B,C,D] = ss(Hd)
    end  % public methods
    
    methods (Hidden)
        [p,v] = coefficient_info(this)
        c = coefficientnames(Hd)
        c = coefficientvariables(h)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        s = dispstr(Hd,varargin)
        flag = doFrameProcessing(~)
        c = evalcost(this)
        A = geta(Hd,A)
        B = getb(Hd,B)
        C = getc(Hd,C)
        D = getd(Hd,D)
        logi = isparallelfilterable(this)
        loadreferencecoefficients(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        [f,offset] = multfactor(this)
        s = objblockparams(this,varname)
        quantizecoeffs(h,eventData)
        rcnames = refcoefficientnames(this)
        rcvals = refvals(this)
        s = savereferencecoefficients(this)
        [y,zf] = secfilter(Hd,x,zi)
        A = seta(Hd,A)
        B = setb(Hd,B)
        C = setc(Hd,C)
        D = setd(Hd,D)
        setrefvals(this,refvals)
        C = thiscoefficients(Hd)
        thisdisp(this)
        f = thisisfir(Hd)
        f = thisisreal(Hd)
        f = thisisrealizable(this)
        f = thisisstable(Hd)
        g = thisnormalize(Hd)
        n = thisnstates(Hd)
        n = thisorder(Hd)
        thisunnormalize(Hd,g)
    end  % possibly private or hidden
    
end  % classdef

