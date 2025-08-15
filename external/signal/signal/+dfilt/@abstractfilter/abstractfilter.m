classdef (Abstract, CaseInsensitiveProperties=true) abstractfilter < dfilt.basefilter & dynamicprops
    %ABSTRACTFILTER Abstract class
    
    %dfilt.abstractfilter class
    %   dfilt.abstractfilter extends dfilt.basefilter.
    %
    %    dfilt.abstractfilter properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %
    %    dfilt.abstractfilter methods:
    %       abstract_loadarithmetic -   Load the arithmetic information.
    %       abstract_loadpublicinterface -   Load the public interface.
    %       abstract_savepublicinterface -   Save the public interface.
    %       cfi -   Return the Current Filter Information.
    %       checkoptimizable - Check if optimizations can be carried on
    %       defaultarithmetic -   Returns the default arithmetic.
    %       doFrameProcessing - Returns true if frame processing if supported by realizemdl()
    %       double -   Cast filter to a double-precision arithmetic version.
    %       extrainfostrs -   Return the extra info strings.
    %       filter - Discrete-time filter.
    %       filtquant_plugins - Table of filterquantizer plugins
    %       forcecopy -   Force a copy, i.e., new memory allocation.
    %       get_arith -   PreGet function for the Arithmetic property.
    %       get_filterquantizer -   PreGet function for the 'filterquantizer' property.
    %       getinitialconditions - Get the initial conditions.
    %       getlogreport -   Get the logreport.
    %       getstates - Overloaded get for the States property.
    %       loadarithmetic -   Load the arithmetic.
    %       loadmetadata -   Load the metadata.
    %       loadpublicinterface -   Load the public interface.
    %       minwordlength - Minimum-wordlength design.
    %       nstates -  Number of states in discrete-time filter.
    %       parallel - Connect filters in parallel.
    %       parse_filterstates - Store filter states in hTar for realizemdl
    %       privnports - Number of input ports of the realizemdl model
    %       qreport - Quantization report.
    %       realizemdl - Filter realization (Simulink diagram).
    %       refvals -   Return the reference values.
    %       reset - Reset the filter.
    %       savearithmetic -   Save the arithmetic information.
    %       savemetadata -   Save the metadata.
    %       savepublicinterface -   Save the public interface.
    %       secfilter - Discrete-time filter.
    %       set_arith -   SetFunction for the Arithmetic property.
    %       set_filterquantizer -   PreSet function for the 'filterquantizer' property.
    %       set_privarith -   SetFunction for the 'privArithmetic' property.
    %       set_privfq -   PreSet function for the 'privfq' property.
    %       set_tapindex -   PreSet function for the 'tapindex' property.
    %       sethdl_abstractfarrow - Set the properties of hdlfiltercomp (hhdl) from the
    %       sethdl_abstractfilter - SETHDLPROPSBASEFILTER Set the common props for HDLFILTER  from filter
    %       super_filter - FILTER Discrete-time filter.
    %       thisdisp - Object display.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisisrealizable - True if the structure can be realized by simulink
    %       thisnstates -   Return the number of states
    %       thisreffilter -   Returns the double representation of the filter object.
    %       thisreset - "Local" Reset.
    %       thissetstates - Overloaded set for the States property.
    %       ziexpand - Expand initial conditions for multiple channels when necessary
    %       ziscalarexpand - Expand empty or scalar initial conditions to a vector.
    
    
    properties (Access=protected, SetObservable, GetObservable)
        %PRIVFQ Property is of type 'dfilt.filterquantizer vector'
        privfq = [];
        %PRIVFILTERQUANTIZER Property is of type 'dfilt.filterquantizer'
        privfilterquantizer = [];
        %FILTERQUANTIZERLISTENERS Property is of type 'handle.listener vector'
        filterquantizerlisteners = [];
        %PRIVARITHMETIC Property is of type 'ustring'
        privArithmetic = '';
        %HIDDENSTATES Property is of type 'mxArray'
        HiddenStates = [];
        %TAPINDEX Property is of type 'mxArray'
        TapIndex = [  ];
        %NCOEFFS Property is of type 'mxArray'
        ncoeffs = [];
        %NCHANNELS Property is of type 'mxArray'
        nchannels = [];
    end
    
    properties (SetObservable, GetObservable)
        %FILTERSTRUCTURE Property is of type 'ustring'  (read only)
        FilterStructure = '';
    end
    
    properties (SetObservable, GetObservable)
        %STATES Property is of type 'mxArray'
        States = [];
    end
    
    properties(Hidden)
        %FILTERQUANTIZER Property is of type 'dfilt.filterquantizer'
        filterquantizer = []; 
    end
    
    
    methods
        function set.privfq(obj,value)
            % DataType = 'dfilt.filterquantizer vector'
            validateattributes(value,{'dfilt.filterquantizer'}, {'vector'},'','privfq')
            if isrow(value)
                value = value';
            end
            obj.privfq = set_privfq(obj,value);
        end
        
        function value = get.filterquantizer(obj)
            value = get_filterquantizer(obj,obj.filterquantizer);
        end
        function set.filterquantizer(obj,value)
            % DataType = 'dfilt.filterquantizer'
            validateattributes(value,{'dfilt.filterquantizer'}, {'scalar'},'','filterquantizer')
            obj.filterquantizer = set_filterquantizer(obj,value);
        end
        
        function set.privfilterquantizer(obj,value)
            % DataType = 'dfilt.filterquantizer'
            validateattributes(value,{'dfilt.filterquantizer'}, {'scalar'},'','privfilterquantizer')
            obj.privfilterquantizer = value;
        end
        
        function set.filterquantizerlisteners(obj,value)
            % DataType = 'handle.listener vector'
            validateattributes(value,{'event.listener'}, {'vector'},'','filterquantizerlisteners')
            obj.filterquantizerlisteners = value;
        end
        
        function set.FilterStructure(obj,value)
            % DataType = 'ustring'
            % no cell string checks yet'
            obj.FilterStructure = set_filterstructure(obj,value);
        end
        
        function value = get.privArithmetic(obj)
            value = get_privarith(obj,obj.privArithmetic);
        end
        function set.privArithmetic(obj,value)
            % DataType = 'ustring'
            % no cell string checks yet'
            obj.privArithmetic = set_privarith(obj,value);
        end
        
        function value = get.States(obj)
            value = getstates(obj,obj.States);
        end
        function set.States(obj,value)
            obj.States = setstates(obj,value);
        end
        
        function set.TapIndex(obj,value)
            obj.TapIndex = set_tapindex(obj,value);
        end
        
        function set.ncoeffs(obj,value)
            obj.ncoeffs = check_length(obj,value);
        end
        
    end   % set and get functions
    
    methods  % public methods
        y = filter(varargin)
        realizemdl(Hd,varargin)
    end  % public methods
    
    
    methods (Hidden) % possibly private or hidden
        pnames = absfilterprivnames(this)
        privvals = absfilterprivvals(this)
        abstract_loadarithmetic(this,s)
        abstract_loadpublicinterface(this,s)
        s = abstract_savepublicinterface(this)
        varargout = autoscale(this,x)
        BL = blocklength(Hd)
        fi = cfi(this)
        check_if_optimizezeros_possible(this,hTar)
        checkoptimizable(this,hTar)
        da = defaultarithmetic(this)
        flag = doFrameProcessing(~)
        h = double(this)
        strs = extrainfostrs(this)
        constr = filtquant_plugins(h,arith)
        hcopy = forcecopy(this,h)
        arith = get_arith(q,arith)
        fq = get_filterquantizer(this,fq)
        ic = getinitialconditions(Hd)
        logreport = getlogreport(this)
        xi = getnonprocessedsamples(Hd)
        S = getstates(Hm,S)
        loadarithmetic(this,s)
        loadmetadata(this,s)
        loadpublicinterface(this,s)
        minwordlength(h,args)
        n = naddp1(h)
        hTar = parse_filterstates(Hd,hTar)
        n = privnports(this)
        R = qreport(this)
        quantizestates(h,eventData)
        v = refvals(this)
        reset(Hm)
        s = savearithmetic(this)
        s = savemetadata(this)
        s = savepublicinterface(this)
        secfilter(Hm,varargin)
        str = set_arith(h,str)
        newfq = set_filterquantizer(this,newfq)
        newarith = set_privarith(this,newarith)
        privfq = set_privfq(this,privfq)
        tapindex = set_tapindex(H,tapindex)
        setabsfilterprivvals(this,privvals)
        setnonprocessedsamples(Hd,xf)
        sethdl_abstractfarrow(this,hhdl)
        sethdl_abstractfilter(this,hhdl)
        specifyall(this,flag)
        y = super_filter(Hd,x,dim)
        super_quantizecoeffs(this,eventData)
        thisdisp(this)
        constr = thisfiltquant_plugins(h,arith)
        [p,v] = thisinfo(this)
        realizeflag = thisisrealizable(Hd)
        n = thisnstates(this)
        Hd = thisreffilter(this)
        thisreset(Hm)
        S = thissetstates(Hm,S)
        validatestates(h)
        verifyautoscalability(this)
        zi = ziexpand(Hd,x,zi)
        S = ziscalarexpand(Hm,S)       
    end  % possibly private or hidden
    
    methods(Sealed)
       Hd = parallel(varargin)
       n = nstates(Hd)
    end
end  % classdef

function pa = get_privarith(this, pa)

if isempty(pa)
    pa = defaultarithmetic(this);
end
end  % get_privarith


%----------------------------------------------------
function fd = get_privfdesign(~, privfdesign)

if isempty(privfdesign)
    fd = [];
else
    fd = copy(privfdesign);
end
end  % get_privfdesign


%----------------------------------------------------
function fm = get_privfmethod(~, privfmethod)

if isempty(privfmethod)
    fm = [];
else
    fm = copy(privfmethod);
end
end  % get_privfmethod


%----------------------------------------------------
function S = setstates(Hm,S)
%SETSTATES Overloaded set for the States property.

S = ziscalarexpand(Hm,S);

thissetstates(Hm,S);

S = [];
end  % setstates
% Make it phantom

%----------------------------------------------------
function ncoeffs = check_length(~,ncoeffs)

if length(ncoeffs)>2
    error(message('signal:dfilt:abstractfilter:schema:InternalError'));
end
end  % check_length


%----------------------------------------------------
function str = set_filterstructure(~,str)

if ~isdeployed
    if ~license('checkout','Signal_Toolbox')
        error(message('signal:dfilt:abstractfilter:schema:LicenseRequired'));
    end
end
end  % set_filterstructure


% [EOF]
