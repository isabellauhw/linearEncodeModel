classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) df1tsos < dfilt.abstractsos
    %DF1TSOS Direct-Form I Transposed, Second-Order Sections.
    %   Hd = DFILT.DF1TSOS(S) returns a discrete-time, second-order section,
    %   direct-form I transposed filter object, Hd, with coefficients given in
    %   the SOS matrix defined in <a href="matlab: help zp2sos">zp2sos</a>.
    %
    %   Hd = DFILT.DF1TSOS(b1,a1,b2,a2,...) returns a discrete-time, second-order
    %   section, direct-form I transposed filter object, Hd, with coefficients for
    %   the first section given in the b1 and a1 vectors, for the second section given
    %   in the b2 and a2 vectors, etc.
    %
    %   Hd = DFILT.DF1TSOS(...,g) includes a gain vector g. The elements of g are the
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
    %   Hd = dfilt.df1tsos(s,g)
    %   realizemdl(Hd)    % Requires Simulink
    %
    %   % EXAMPLE #2: Design an elliptic lowpass filter with default specifications
    %   Hd = design(fdesign.lowpass, 'ellip', 'FilterStructure', 'df1tsos');
    %   fvtool(Hd)                % Analyze filter
    %   input = randn(100,1);
    %   output = filter(Hd,input); % Process data through the Equiripple filter.
    %
    %   See also DFILT/STRUCTURES.
    
    %dfilt.df1tsos class
    %   dfilt.df1tsos extends dfilt.abstractsos.
    %
    %    dfilt.df1tsos properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       sosMatrix - Property is of type 'mxArray'
    %       ScaleValues - Property is of type 'mxArray'
    %       OptimizeScaleValues - Property is of type 'bool'
    %
    %    dfilt.df1tsos methods:
    %       blockparams - Returns the parameters for BLOCK
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       getinitialconditions - Get the initial conditions
    %       getstates - Overloaded get for the States property.
    %       getstructure - Get the structure type of second order sections.
    %       isfixedptable - True is the structure has an Arithmetic field
    %       lclcscalefactors -   Local cumulative scale factor computation.
    %       parse_filterstates - Store filter states in hTar for realizemdl
    %       qtoolinfo -   Return the information needed by the QTool.
    %       secfilter - Filter this section.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisnstates - NSTATES  Number of states in discrete-time filter.
    %       thissetstates - Overloaded set for the States property.
    %       ziexpand - Expand initial conditions for multiple channels when necessary
    %       ziscalarexpand - Expand empty or scalar initial conditions to a vector.
    
    
    
    methods  % constructor block
        function Hd = df1tsos(varargin)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.ncoeffs = 6;
            Hd.FilterStructure = 'Direct-Form I Transposed, Second-Order Sections';
            Hd.Arithmetic = 'double';
            
            [msg, msgObj]= parse_inputs(Hd, varargin{:});
            if ~isempty(msg), error(msgObj); end
            
        end  % df1tsos
        
    end  % constructor block
    
    methods
        info = qtoolinfo(this)
    end % public methods
    methods (Hidden) % possibly private or hidden
        s = blockparams(Hd,mapstates,varargin)
        hF = createhdlfilter(this)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        ic = getinitialconditions(Hd)
        zh = getstates(Hd,dummy)
        struct = getstructure(Hd)
        fixflag = isfixedptable(Hd)
        c = lclcscalefactors(Hd,c,nb,opts)
        hTar = parse_filterstates(Hd,hTar)
        sc = scalecheck(Hd,pnorm)
        [y,zf] = secfilter(Hd,x,zi)
        s = shiftsecondary(this)
        constr = thisfiltquant_plugins(h,arith)
        [y,zi,overflows] = thislimitcycle(Hd,x)
        n = thisnstates(Hd)
        S = thissetstates(Hd,S)
        unconstrainedscale(this,opts,L)
        zi = ziexpand(Hd,x,zi)
        S = ziscalarexpand(Hd,S)
    end  % possibly private or hidden
    
end  % classdef

