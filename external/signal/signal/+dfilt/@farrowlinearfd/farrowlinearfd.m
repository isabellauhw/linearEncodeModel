classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) farrowlinearfd < dfilt.abstractfarrowfd
    %FARROWLINEARFD Farrow Linear Fractional Delay filter.
    %   Hd = DFILT.FARROWLINEARFD(D) constructs a discrete-time linear
    %   fractional delay Farrow filter with the delay D.
    %
    %   % EXAMPLE
    %   Hd = dfilt.farrowlinearfd(.5)
    %   y = filter(Hd,1:10)
    %
    %   For more information about fractional delay filter implementations, see
    %   the Fractional Delay Filters Using Farrow Structures example.
    %
    %   See also DFILT
    
    %dfilt.farrowlinearfd class
    %   dfilt.farrowlinearfd extends dfilt.abstractfarrowfd.
    %
    %    dfilt.farrowlinearfd properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       FracDelay - Property is of type 'mxArray'
    %       Coefficients - Property is of type 'mxArray'  (read only)
    %
    %    dfilt.farrowlinearfd methods:
    %       createhdlfilter - Returns the corresponding hdlfiltercomp for HDL Code
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       nadd - Returns the number of adders
    %       nmult - Returns the number of multipliers
    %       thisdisp -   Display this object.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    
    
    properties (SetAccess=protected, SetObservable)
        %COEFFICIENTS Property is of type 'mxArray'  (read only)
        Coefficients = [ -1, 1; 1, 0 ];
    end
    
    
    methods  % constructor block
        function this = farrowlinearfd(varargin)
            
            narginchk(0,1);
            this.privfq = dfilt.filterquantizer;
            this.privfilterquantizer = dfilt.filterquantizer;
            this.FilterStructure = 'Farrow Linear Fractional Delay';
            this.Coefficients = [-1 1;1 0];
            this.Arithmetic = 'double';
            this.States = 0;
            this.FracDelay = 0;
            
            if nargin==1
                this.FracDelay = varargin{1};
            end
            
        end  % farrowlinearfd
    end  % constructor block
    
    methods (Hidden)
        n = coefficientnames(this)
        hF = createhdlfilter(this)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        Hd = dispatch(this)
        loadreferencecoefficients(this,s)
        n = nadd(this)
        n = nmult(this,optimones,optimnegones)
        n = refcoefficientnames(this)
        s = savereferencecoefficients(this)
        [y,z] = secfilter(this,x,d,z)
        thisdisp(this)
        constr = thisfiltquant_plugins(h,arith)
        n = thisnstates(this)
    end  % possibly private or hidden
    
end  % classdef

