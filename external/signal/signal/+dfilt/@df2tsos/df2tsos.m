classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) df2tsos < dfilt.abstractsos
    %DF2TSOS Direct-Form II Transposed, Second-Order Sections.
    %   Hd = DFILT.DF2TSOS(S) returns a discrete-time, second-order section,
    %   direct-form II transposed filter object, Hd, with coefficients given in
    %   the SOS matrix defined in <a href="matlab: help zp2sos">zp2sos</a>.
    %
    %   Hd = DFILT.DF2TSOS(b1,a1,b2,a2,...) returns a discrete-time, second-order
    %   section, direct-form II transposed filter object, Hd, with coefficients for
    %   the first section given in the b1 and a1 vectors, for the second section given
    %   in the b2 and a2 vectors, etc.
    %
    %   Hd = DFILT.DF2TSOS(...,g) includes a gain vector g. The elements of g are the
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
    %   Hd = dfilt.df2tsos(s,g)
    %   realizemdl(Hd)    % Requires Simulink
    %
    %   % EXAMPLE #2: Design an elliptic lowpass filter with default specifications
    %   Hd = design(fdesign.lowpass, 'ellip', 'FilterStructure', 'df2tsos');
    %   fvtool(Hd)                % Analyze filter
    %   input = randn(100,1);
    %   output = filter(Hd,input); % Process data through the Equiripple filter.
    %
    %   See also DFILT/STRUCTURES.
    
    %dfilt.df2tsos class
    %   dfilt.df2tsos extends dfilt.abstractsos.
    %
    %    dfilt.df2tsos properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       sosMatrix - Property is of type 'mxArray'
    %       ScaleValues - Property is of type 'mxArray'
    %       OptimizeScaleValues - Property is of type 'bool'
    %
    %    dfilt.df2tsos methods:
    %       blockparams - Returns the parameters for BLOCK
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       getinitialconditions - Get the initial conditions
    %       getstates - Overloaded get for the States property.
    %       getstructure - Get the structure type of second order sections.
    %       lclcscalefactors -   Local cumulative scale factor computation.
    %       qtoolinfo -   Return the information needed by the QTool.
    %       secfilter - Filter this section.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       thissfcnparams - Returns the parameters for SDSPFILTER
    
    
    
    methods  % constructor block
        function Hd = df2tsos(varargin)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.ncoeffs = 6;
            Hd.FilterStructure = 'Direct-Form II Transposed, Second-Order Sections';
            Hd.Arithmetic = 'double';
            
            [msg, msgObj] = parse_inputs(Hd, varargin{:});
            if ~isempty(msg), error(msgObj); end
            
            
        end  % df2tsos
        
    end  % constructor block
    
    methods
        info = qtoolinfo(this)
    end %public methods
    
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
        varargout = thissfcnparams(Hd)
        unconstrainedscale(this,opts,L)
    end  % possibly private or hidden
    
end  % classdef

