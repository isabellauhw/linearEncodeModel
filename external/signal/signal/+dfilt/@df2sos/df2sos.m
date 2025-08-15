classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) df2sos < dfilt.abstractsos
    %DF2SOS Direct-Form II, Second-Order Sections.
    %   Hd = DFILT.DF2SOS(S) returns a discrete-time, second-order section,
    %   direct-form II filter object, Hd, with coefficients given in the SOS
    %   matrix defined in <a href="matlab: help zp2sos">zp2sos</a>.
    %
    %   Hd = DFILT.DF2SOS(b1,a1,b2,a2,...) returns a discrete-time, second-order
    %   section, direct-form II filter object, Hd, with coefficients for the first
    %   section given in the b1 and a1 vectors, for the second section given in
    %   the b2 and a2 vectors, etc.
    %
    %   Hd = DFILT.DF2SOS(...,g) includes a gain vector g. The elements of g are the
    %   gains for each section. The maximum length of g is the number of sections plus
    %   one. If g is not specified, all gains default to one.
    %
    %   Note that one usually does not construct DFILT filters explicitly.
    %   Instead, one obtains these filters as a result from a design using <a
    %   href="matlab:help fdesign">FDESIGN</a>.
    %
    %   Also, the DSP System Toolbox, along with the Fixed-Point Designer,
    %   enables fixed-point support.
    %
    %   % EXAMPLE #1: Direct instantiation
    %   [z,p,k] = ellip(4,1,60,.4);
    %   [s,g] = zp2sos(z,p,k);
    %   Hd = dfilt.df2sos(s,g)
    %   realizemdl(Hd)    % Requires Simulink
    %
    %   % EXAMPLE #2: Design an elliptic lowpass filter with default specifications
    %   Hd = design(fdesign.lowpass, 'ellip', 'FilterStructure', 'df2sos');
    %   fvtool(Hd)                % Analyze filter
    %   input = randn(100,1);
    %   output = filter(Hd,input); % Process data through the Equiripple filter.
    %
    %   See also DFILT/STRUCTURES.
    
    %dfilt.df2sos class
    %   dfilt.df2sos extends dfilt.abstractsos.
    %
    %    dfilt.df2sos properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       sosMatrix - Property is of type 'mxArray'
    %       ScaleValues - Property is of type 'mxArray'
    %       OptimizeScaleValues - Property is of type 'bool'
    %
    %    dfilt.df2sos methods:
    %       blockparams -   Return the block parameters.
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       getinitialconditions - Get the initial conditions
    %       getstates - Overloaded get for the States property.
    %       getstructure - Get the structure type of second order sections.
    %       lclcscalefactors -   Local cumulative scale factor computation.
    %       qtoolinfo -   Return the information needed by the QTool.
    %       secfilter - Filter this section.
    %       sos -  Convert to second-order-sections.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    
    
    
    methods  % constructor block
        function Hd = df2sos(varargin)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.ncoeffs = 6;
            Hd.FilterStructure = 'Direct-Form II, Second-Order Sections';
            Hd.Arithmetic = 'double';
            
            [msg, msgObj] = parse_inputs(Hd, varargin{:});
            if ~isempty(msg), error(msgObj); end
            
            
        end  % df2sos
        
    end  % constructor block
    
    methods  % public methods
        Hsos = sos(Hd,varargin)
        info = qtoolinfo(this)
    end  % public methods
    
    
    methods (Hidden) % possibly private or hidden
        s = blockparams(Hd,mapstates,varargin)
        hF = createhdlfilter(this)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        ic = getinitialconditions(Hd)
        z = getstates(Hd,dummy)
        struct = getstructure(Hd)
        c = lclcscalefactors(Hd,c,nb,opts)
        sc = scalecheck(Hd,pnorm)
        [y,zf] = secfilter(Hd,x,zi)
        s = shiftsecondary(this)
        constr = thisfiltquant_plugins(h,arith)
        [y,zi,overflows] = thislimitcycle(Hd,x)
        n = thisnstates(Hd)
        unconstrainedscale(this,opts,L)
    end  % possibly private or hidden
    
end  % classdef

