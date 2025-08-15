classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) farrowfd < dfilt.abstractfarrowfd
    %FARROWFD Fractional Delay Farrow filter.
    %   Hd = DFILT.FARROWFD(D, COEFFS) constructs a discrete-time fractional
    %   delay Farrow filter with COEFFS coefficients and D delay.
    %
    %   Farrow filters can be designed with the <a href="matlab:help fdesign.fracdelay">fdesign.fracdelay</a> filter designer.
    %
    %   % EXAMPLE #1
    %   coeffs = [-1/6 1/2 -1/3 0;1/2 -1 -1/2 1; -1/2 1/2 1 0;1/6 0 -1/6 0];
    %   Hd = dfilt.farrowfd(.5, coeffs)
    %   y = filter(Hd,1:10)
    %
    %   % EXAMPLE #2: Design a cubic fractional delay filter with the Lagrange method
    %   fdelay = .2; % Fractional delay
    %   d = fdesign.fracdelay(fdelay,'N',3);
    %   Hd = design(d, 'lagrange', 'FilterStructure', 'farrowfd');
    %   fvtool(Hd, 'Analysis', 'grpdelay')
    %
    %   For more information about fractional delay filter implementations, see
    %   the Fractional Delay Filters Using Farrow Structures example.
    %
    %   See also DFILT
    
    %dfilt.farrowfd class
    %   dfilt.farrowfd extends dfilt.abstractfarrowfd.
    %
    %    dfilt.farrowfd properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       FracDelay - Property is of type 'mxArray'
    %       Coefficients - Property is of type 'mxArray'
    %
    %    dfilt.farrowfd methods:
    %       createhdlfilter - Returns the corresponding hdlfiltercomp for HDL Code
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       get_coefficients -   PreGet function for the 'coefficients' property.
    %       getlogreport -   Get the logreport.
    %       nadd - Returns the number of adders
    %       nmult - Returns the number of multipliers
    %       set_coefficients -   PreSet function for the 'coefficients' property.
    
    
    properties (SetObservable)
        %COEFFICIENTS Property is of type 'mxArray'
        Coefficients = [ -1, 1; 1, 0 ];
    end
    
    
    methods  % constructor block
        function this = farrowfd(varargin)
            
            narginchk(0,2);
            this.privfq = dfilt.filterquantizer;
            this.privfilterquantizer = dfilt.filterquantizer;
            this.FilterStructure = 'Farrow Fractional Delay';
            this.Coefficients = [-1 1;1 0];
            this.Arithmetic = 'double';
            this.States = 0;
            this.FracDelay = 0;
            
            if nargin>0
                this.FracDelay = varargin{1};
            end
            if nargin>1
                this.Coefficients =  varargin{2};
            end
            
            
        end  % farrowfd
        
    end  % constructor block
    
    methods
        function value = get.Coefficients(obj)
            value = get_coefficients(obj,obj.Coefficients);
        end
        function set.Coefficients(obj,value)
            obj.Coefficients = set_coefficients(obj,value);
        end
        
    end   % set and get functions
    
    methods (Hidden)
        hF = createhdlfilter(this)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        coefficients = get_coefficients(this,coefficients)
        logreport = getlogreport(this)
        loadreferencecoefficients(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        n = nadd(this)
        n = nmult(this,optimones,optimnegones)
        s = savereferencecoefficients(this)
        [y,z] = secfilter(this,x,d,z)
        c = set_coefficients(this,c)
        n = thisnstates(this)
        verifyautoscalability(this)
    end  % possibly private or hidden
    
end  % classdef

