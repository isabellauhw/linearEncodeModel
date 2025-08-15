classdef (CaseInsensitiveProperties=true) basefilter < matlab.mixin.SetGet & ...
        matlab.mixin.Heterogeneous & ...
        handle & dynamicprops
    %BASEFILTER Constructor for this class.
    
    %dfilt.basefilter class
    %    dfilt.basefilter properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %
    %    dfilt.basefilter methods:
    %       base_is - Returns an array for the requested fcn.
    %       base_num -   Gateway for vector support of methods that return numbers.
    %       base_resp - Return the response specified
    %       basefilter_info - BASEFILTER_THISINFO   Get the information for this filter.
    %       block - Generate a DSP System Toolbox block equivalent to the filter object.
    %       blockparams - Returns the parameters for BLOCK
    %       checkoptimizescalevalues - check if optimize scale values is possible
    %       checkrequiredlicense - check required license for realizemdl
    %       classname - Returns the class name of the object
    %       clearmetadata -   Clear the metadata of the object.
    %       coefficient_info -   Get the coefficient information for this filter.
    %       coefficientnames -  Coefficient names.
    %       coefficients - Filter coefficients.
    %       coefficientvariables - Coefficient variables.
    %       coeffs -   Return the coefficients in a structure.
    %       coeffviewstr -   Return the coefficients for the viewer.
    %       constraincoeffwl - Constrain coefficient wordlength.
    %       conv2hdlroundoverflow - Converts the Round & Overflow Mode to HDL Round and
    %       copy -   Copy this object.
    %       createhdlfilter - Returns the corresponding hdlfiltercomp for HDL Code
    %       defaulttbstimulus - returns a cell array of stimulus types.
    %       disp - Object display.
    %       dispatch - Returns the contained DFILT objects.
    %       dispstr - Display string of coefficients.
    %       drawmask -   Draw the mask for the filter specifications.
    %       edit -   Edit the dfilt.
    %       exportdata - Extract data to export.
    %       fcfwrite - Write a filter coefficient file.
    %       fdhdltool - Launch the GUI to generate HDL
    %       filt2struct -   Return a structure representation of the object.
    %       firtype -  Determine the type (1-4) of a linear phase FIR filter.
    %       flatcascade - Add singleton to the flat list of filters Hflat
    %       freqresp -   Discrete-time filter frequency response.
    %       freqrespest -   Frequency response estimate via filtering.
    %       freqrespopts -  Create an options object for frequency response estimate.
    %       freqz -  Discrete-time filter frequency response.
    %       freqzparse - Parser for freqz
    %       generatehdl - Generate HDL.
    %       generatetb - Generate an HDL Test Bench.
    %       generatetbstimulus - Generates and returns HDL Test Bench Stimulus
    %       get_privfdesign -   PreGet function for the 'privfdesign' property.
    %       get_ratechangefactors -   PreGet function for the 'ratechangefactors' property.
    %       get_version -   PreGet function for the 'version' property.
    %       getblockinputprocessingrestrictions - Get input processing restrictions for
    %       getblockraterestrictions - Get rate restrictions for the block method.
    %       getdesignmethod -   Get the designmethod.
    %       getfdesign -   Get the fdesign.
    %       getfmethod -   Get the fmethod.
    %       getinfoheader - Return the header to the info
    %       getratechangefactors -   Get the ratechangefactors.
    %       getrealizemdlraterestrictions - Get rate restrictions for the realizemdl
    %       getresetbeforefiltering -   Get the resetbeforefiltering.
    %       groupdelay - Group delay of a discrete-time filter.
    %       grpdelay - Group delay of a discrete-time filter.
    %       impulse - Impulse response of digital filter
    %       impz - Impulse response of digital filter
    %       impzlength - Length of the impulse response for a digital filter.
    %       info - Information about filter.
    %       isallpass -  True for allpass filter.
    %       isblockable - True if the object supports the block method
    %       isblockmapcoeffstoports - True if the object is blockmapcoeffstoports
    %       isblockrequiredst - Check if block method requires a DST license
    %       iscascade -  True for cascaded filter.
    %       iscoeffwloptimizable - True if the object is coeffwloptimizable
    %       iscoupledallpass - True if the structure is coupled all pass
    %       isfir -  True for FIR filter.
    %       isfromdesignfilt - True if dfilt object was designed usign designfilt function
    %       ishdlable - True if HDL can be generated for the filter object.
    %       islattice - True if lattice structure
    %       islinphase -  True for linear phase filter.
    %       ismaxphase - True if maximum phase.
    %       isminphase - True if minimum phase.
    %       isparallel -  True for filter with parallel sections.
    %       ispolyphase -   Returns true if the filter is polyphase.
    %       isquantizable - Returns true if the object can be quantized
    %       isquantized -   Returns true if it is a quantized DFILT.
    %       isreal -  True for filter with real coefficients.
    %       isrealizable -   Return whether the object is realizable.
    %       isscalar -  True if scalar filter.
    %       isscalarstructure -  True if scalar filter.
    %       issos -  True if second-order-section.
    %       isspecmet -   True if the object's specification has been met by the filter.
    %       isstable - True if the filter is stable
    %       loadarithmetic -   Load the arithmetic settings.
    %       loadmetadata -   Load the meta data.
    %       loadobj -   Load this object.
    %       loadpublicinterface -   Load the public interface.
    %       loadreferencecoefficients -   Load the reference coefficients.
    %       magresp -   Calculate the magnitude response.
    %       maximizestopband - Maximize stopband attenuation.
    %       measure -   Measure the DFILT object.
    %       minimizecoeffwl - Minimize coefficient wordlength.
    %       nadd - Returns the number of adders
    %       nlmgeninput -   Generate input signal for noisepsd and mfreqresp.
    %       nmult - Returns the number of multipliers
    %       noisepsd -   Power spectral density of filter output due to roundoff noise.
    %       noisepsdopts -   Options for noisepsd method.
    %       nominalgain -   Returns the nominal gain if an FDESIGN is present.
    %       norm -   Filter norm.
    %       npolyphase -   Return the number of polyphases for this filter.
    %       nsections - Number of sections in a discrete filter.
    %       optimizecoeffwlfir - Optimize coefficient wordlength for FIR filters.
    %       optimizedg - Optimize directed graph of filter HD
    %       order - Filter order.
    %       parse_coeffstoexport - Store coefficient names and values into hTar for
    %       parse_filterstates - Store filter states in hTar for realizemdl
    %       passbandzoom -   Return the limits for the passbandzoom.
    %       phasedelay -   Compute the phase delay.
    %       phaseresp - PHASE   Phase response of a discrete-time filter.
    %       phasez - Phase response of a discrete-time filter.
    %       privgetfdesign -   Get the fdesign handle without copying.
    %       reffilter -   Return the reference filter.
    %       savemetadata -   Save any meta data.
    %       saveobj -   Save this object.
    %       savepublicinterface -   Save the public interface.
    %       savereferencecoefficients -   Save the reference coefficients.
    %       set_persistentmemory -   PreSet function for the 'persistentmemory' property.
    %       setdesignmethod -   Set the designmethod.
    %       setfdesign -   Set the fdesign.
    %       setfmethod -   Set the fmethod.
    %       sethdl_abstractfilter - SETHDLPROPSBASEFILTER Set the common props for HDLFILTER  from filter
    %       setmeasurements -   Set the measurements.
    %       setprivmeasurements -   Set the privMeasurements.
    %       setresetbeforefiltering - Set function of the ResetBeforeFiltering property.
    %       setsysobjmetadata - Set metadata of generated filter System object
    %       spectrumopts2fvtool -   Convert options for NOISEPSD and FREQRESPEST to
    %       step -   Step response.
    %       stepz -  Discrete-time filter step response.
    %       super_realizemdl_composite - realize composite model
    %       sysobj - Generate a filter System object
    %       temphdlsettopprops - A temperory method - will be removed once
    %       tf -  Convert to transfer function.
    %       thiscoeffs - Get the coefficients.
    %       thisfirtype - FIRTYPE  Determine the type (1-4) of a linear phase FIR filter.
    %       thisimpzlength -   Dispatch and call the method.
    %       thisisallpass - ISALLPASS  True for allpass filter.
    %       thisiscascade -   Returns false by default.
    %       thisisfir -   Dispatch and call the method.
    %       thisislinphase -  True for linear phase filter.
    %       thisismaxphase - True if maximum phase.
    %       thisisminphase - True if minimum phase.
    %       thisisparallel -   Returns false.
    %       thisispolyphase -   Returns false.
    %       thisisquantizable -   Returns isfixedptable.
    %       thisisquantized -   Returns true if the filter is not set to double.
    %       thisisreal -   Dispatch and call the method.
    %       thisisrealizable(this)
    %       thisisscalar -  True if scalar filter.
    %       thisisscalarstructure -   Dispatch and call the method.
    %       thisissos -  True if second-order-section.
    %       thisisstable -   Dispatch and call the method..
    %       thisnpolyphase -   Return the number of polyphases for this filter.
    %       thisnsections - Number of sections in a discrete filter.
    %       thisorder -   Dispatch and recall.
    %       timezparse - Parse the time response inputs
    %       tosysobj - Convert to a System object
    %       warnifreset - Throw a warning if PersistentMemory is false
    %       wloptiminputparse - Parse inputs for wordlength optimization functions.
    %       zerophase - Zero-phase response of a discrete-time filter.
    %       zpk -  Discrete-time filter zero-pole-gain conversion.
    %       zplane - Z-plane zero-pole plot.
    
    
    properties (Access=protected, SetObservable, GetObservable)
        %PRIVRATECHANGEFACTOR Property is of type 'posint_vector user-defined'
        privRateChangeFactor = [ 1, 1 ];
        %VERSION Property is of type 'mxArray'
        version = [];
        %PRIVFDESIGN Property is of type 'mxArray'
        privfdesign = [];
        %PRIVFMETHOD Property is of type 'mxArray'
        privfmethod = [];
        %PRIVDESIGNMETHOD Property is of type 'mxArray'
        privdesignmethod = [];
        %PRIVMEASUREMENTS Property is of type 'mxArray'
        privMeasurements = [];
        %CLEARMETADATALISTENER Property is of type 'handle.listener'
        clearmetadatalistener = [];
    end
    
    properties (SetAccess=protected, SetObservable, GetObservable)
        %NUMSAMPLESPROCESSED capture (read only)
        NumSamplesProcessed = 0;
    end
    
    properties (SetObservable, GetObservable)
        %PERSISTENTMEMORY Property is of type 'bool'
        PersistentMemory = false;
    end
    
    properties (Dependent, SetObservable, GetObservable)
        RateChangeFactor;
    end
    
    properties (SetObservable, GetObservable, Hidden)
        %RESETBEFOREFILTERING Property is of type 'on/off'  (hidden)
        ResetBeforeFiltering = 'on';
        %FROMSYSOBJFLAG Property is of type 'bool'  (hidden)
        FromSysObjFlag = false;
        %SYSTEMOBJPARAMS Property is of type 'mxArray'  (hidden)
        SystemObjParams = [  ];
        %FROMDESIGNFILT Property is of type 'bool'  (hidden)
        FromDesignfilt = false;
        %CONTAINEDSYSOBJ Property is of type 'mxArray'  (hidden)
        ContainedSysObj = [  ];
        %SUPPORTSNLMETHODS Property is of type 'bool'  (hidden)
        SupportsNLMethods = false;
        %FROMFILTERBUILDERFLAG Property is of type 'bool'  (hidden)
        FromFilterBuilderFlag = false;
    end
    
    
    events
        ClearMetaData
    end  % events
    
    methods
        function value = get.ResetBeforeFiltering(obj)
            value = getresetbeforefiltering(obj,obj.ResetBeforeFiltering);
        end
        function set.ResetBeforeFiltering(obj,value)
            % DataType = 'on/off'
            validatestring(value,{'on','off'},'','ResetBeforeFiltering');
            obj.ResetBeforeFiltering = setresetbeforefiltering(obj,value);
        end
        
        function set.PersistentMemory(obj,value)
            % DataType = 'bool'
            validateattributes(value,{'numeric','logical'}, {'scalar','nonnan'},'','PersistentMemory')
            value = logical(value); %  convert to logical
            obj.PersistentMemory = set_persistentmemory(obj,value);
        end
        
        function set.RateChangeFactor(obj, value)
            obj.privRateChangeFactor = value;
        end
        
        function value = get.RateChangeFactor(obj)
            value = obj.privRateChangeFactor;
        end
        
        function value = get.privRateChangeFactor(obj)
            value = get_ratechangefactors(obj,obj.privRateChangeFactor);
        end
        function set.privRateChangeFactor(obj,value)
            % User-defined DataType = 'posint_vector user-defined'
            obj.privRateChangeFactor = setrate(obj,value);
        end
        
        function value = get.version(obj)
            value = get_version(obj,obj.version);
        end
        
        function value = get.privfdesign(obj)
            value = get_privfdesign(obj,obj.privfdesign);
        end
        
        function value = get.privfmethod(obj)
            value = get_privfdesign(obj,obj.privfmethod);
        end
        
        function set.FromSysObjFlag(obj,value)
            % DataType = 'bool'
            validateattributes(value,{'numeric','logical'}, {'scalar','nonnan'},'','FromSysObjFlag')
            value = logical(value); %  convert to logical
            obj.FromSysObjFlag = value;
        end
        
        function set.FromDesignfilt(obj,value)
            % DataType = 'bool'
            validateattributes(value,{'numeric','logical'}, {'scalar','nonnan'},'','FromDesignfilt')
            value = logical(value); %  convert to logical
            obj.FromDesignfilt = value;
        end
        
        
        function set.SupportsNLMethods(obj,value)
            % DataType = 'bool'
            validateattributes(value,{'numeric','logical'}, {'scalar','nonnan'},'','SupportsNLMethods')
            value = logical(value); %  convert to logical
            obj.SupportsNLMethods = value;
        end
        
        function set.FromFilterBuilderFlag(obj,value)
            % DataType = 'bool'
            validateattributes(value,{'numeric','logical'}, {'scalar','nonnan'},'','FromFilterBuilderFlag')
            value = logical(value); %  convert to logical
            obj.FromFilterBuilderFlag = value;
        end
        
        function set.clearmetadatalistener(obj,value)
            % DataType = 'handle.listener'
            validateattributes(value,{'event.listener'}, {'scalar'},'','clearmetadatalistener')
            obj.clearmetadatalistener = value;
        end
    end   % set and get functions
    
    methods(Sealed)
        
        function varargout = set(obj,varargin)
            [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});
            
        end
        %------------------------------------------------------------------------
        function varargout = get(obj,varargin)
            [varargout{1:nargout}] = signal.internal.signalget(obj,varargin{:});
        end
    end % set and get functions
    
    
    methods % public methods
        varargout = block(Hd,varargin)
        filtertype = firtype(Hb)
        varargout = info(this,varargin)
        varargout = phasez(Hb,varargin)
        Hs = sysobj(this,varargin)
        [num,den] = tf(Hb)
        varargout = zerophase(this,varargin)
        varargout = zpk(Hb)
        [z,p,k] = zplane(Hb,varargin)
        [result,errstr,errorObj] = ishdlable(Hb)
    end  % public methods
    
    methods(Sealed)
        s = coeffs(this)
        fcfwrite(h,filename,fmt)
        varargout = freqz(Hb,varargin)
        varargout = grpdelay(Hb,varargin)
        varargout = impz(Hb,N,varargin)
        len = impzlength(Hb,varargin)
        f = isallpass(Hb,varargin)
        f = iscascade(Hb)
        f = isfir(Hb)
        f = islinphase(Hb,varargin)
        f = ismaxphase(Hb,varargin)
        f = isminphase(Hb,varargin)
        f = isparallel(Hb)
        f = isreal(Hb)
        f = isscalar(Hb,varargin)
        f = issos(Hb)
        f = isstable(Hb)
        nsecs = nsections(Hb)
        n = order(Hb)
        varargout = stepz(Hb,N,varargin)
    end
    
    methods (Hidden) % possibly private or hidden
        [p,v] = basefilter_info(this)
        base_loadprivatedata(this,s)
        base_loadpublicinterface(this,s)
        [out,coeffnames,variables] = base_mapcoeffstoports(this,varargin)
        s = base_saveprivatedata(this)
        s = base_savepublicinterface(this)
        [y,T] = basecomputeimpz(this,varargin)
        pnames = basefilterprivnames(this)
        privvals = basefilterprivvals(this)
        [lib,srcblk,hasInputProcessing,hasRateOptions] = blocklib(~,~)
        s = blockparams(Hd,mapstates,varargin)
        checkifspblksisneeded(this)
        variables = checkoptimizescalevalues(this,variables)
        checkrequiredlicense(Hd,hTar)
        fstruct = classname(Hb)
        clearmetadata(this,eventData)
        [p,v] = coefficient_info(this)
        c = coefficientnames(Hb)
        C = coefficients(Hb)
        c = coefficientvariables(Hb)
        str = coeffviewstr(this,varargin)
        [H,w] = compute_freqrespest(this,L,varargin)
        Hpnn = compute_noisepsd(this,L,varargin)
        Hd = constraincoeffwl(this,WL,varargin)
        Hd = constraincoeffwlfir(this,Href,WL,varargin)
        [rnd,ofmode] = conv2hdlroundoverflow(this)
        Hcopy = copy(this)
        hF = createhdlfilter(this)
        stimcell = defaulttbstimulus(Hb)
        Hd = dispatch(Hb)
        s = dispstr(Hb,varargin)
        varargout = drawmask(this,varargin)
        edit(this)
        c = evalcost(this)
        data = exportdata(Hd)
        strs = extrainfostrs(this)
        varargout = fdhdltool(filterobj,varargin)
        s = filt2struct(this)
        varargout = freqresp(this,varargin)
        varargout = freqrespest(this,L,varargin)
        opts = freqrespopts(this)
        inputs = freqzinputs(Hd,varargin)
        generatehdl(filterobj,varargin)
        generatetb(filterobj,varargin)
        inputdata = generatetbstimulus(filterobj,varargin)
        privfdesign = get_privfdesign(this,privfdesign)
        ratechangefactors = get_ratechangefactors(this,ratechangefactors)
        v = get_version(h,v)
        r = getblockinputprocessingrestrictions(~)
        r = getblockraterestrictions(~,inputProcessing)
        designmethod = getdesignmethod(this)
        fdesign = getfdesign(this)
        fmethod = getfmethod(this)
        str = getinfoheader(h)
        rcf = getratechangefactors(this)
        r = getrealizemdlraterestrictions(~,~)
        resetbeforefiltering = getresetbeforefiltering(h,dummy)
        varargout = groupdelay(this,varargin)
        varargout = impulse(this,varargin)
        b = isblockable(~)
        b = isblockmapcoeffstoports(this)
        isblockrequiredst(~)
        args = iscoeffwloptimizable(this)
        b = iscoupledallpass(~)
        flag = isfromdesignfilt(this)
        b = islattice(~)
        flag = ismultirate(~)
        logi = isparallelfilterable(this)
        f = ispolyphase(this)
        f = isquantizable(Hb)
        f = isscalarstructure(Hb)
        b = isspecmet(this,hfdesign,varargin)
        loadarithmetic(this,s)
        loadmetadata(this,s)
        loadprivatedata(this,s)
        loadpublicinterface(this,s)
        loadreferencecoefficients(this,s)
        varargout = magresp(this,varargin)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        Hd = maximizestopband(this,WL,varargin)
        measurements = measure(this,hfdesign,varargin)
        Hbest = minimizecoeffwl(this,varargin)
        [f,offset] = multfactor(this)
        n = nadd(this)
        [vp,Vp] = nlmgeninput(this,M,L)
        [Vp,Yp] = nlminputnoutput(this,L,M)
        n = nmult(this,optimones,optimnegones)
        varargout = noisepsd(this,L,varargin)
        opts = noisepsdopts(this)
        g = nominalgain(this)
        s = norm(Hd,pnorm,tol)
        n = npolyphase(this)
        s = objblockparams(this,varname)
        [Hbest,mrfflag] = optimizecoeffwl(this,varargin)
        [Hbest,mrfflag] = optimizecoeffwlfir(this,varargin)
        DG = optimizedg(Hd,hTar,DG)
        Hd = optimizestopbandfir(this,Href,WL,varargin)
        [hTar,domapcoeffstoports] = parse_coeffstoexport(Hd,hTar)
        hTar = parse_filterstates(Hd,hTar)
        [out,idx] = parse_mapcoeffstoports(~,varargin)
        [x,y] = passbandzoom(this,varargin)
        varargout = phasedelay(this,varargin)
        varargout = phaseresp(this,varargin)
        fdesignhandle = privgetfdesign(this)
        s = savearithmetic(this)
        s = savemetadata(this)
        s = saveobj(this)
        s = saveprivatedata(this)
        s = savepublicinterface(this)
        s = savereferencecoefficients(this)
        persistentmemory = set_persistentmemory(h,persistentmemory)
        setbasefilterprivvals(this,privvals)
        setdesignmethod(this,designmethod)
        setfdesign(this,fdesign)
        setfmethod(this,fmethod)
        sethdl_abstractfilter(this,hhdl)
        setmeasurements(this,measurements)
        setprivmeasurements(this,measurements)
        flag = setresetbeforefiltering(Hd,flag)
        setsysobjmetadata(this,Hs)
        fvtoolopts = spectrumopts2fvtool(~,opts)
        varargout = step(this,varargin)
        [lib,srcblk,s] = superblockparams(Hd,mapstates,link2obj,varname,hTar)
        super_realizemdl_composite(Hd,varargin)
        temphdlsettopprops(this,hF)
        c = thiscoeffs(this)
        [NMult,NAdd,NStates,MPIS,APIS] = thiscost(this,M)
        filtertype = thisfirtype(Hd)
        n = thisimpzlength(this,varargin)
        [p,v] = thisinfo(h)
        f = thisisallpass(Hd,tol)
        b = thisiscascade(this)
        f = thisisfir(this)
        f = thisislinphase(Hd,tol)
        f = thisismaxphase(Hd,tol)
        f = thisisminphase(Hd,tol)
        b = thisisparallel(this)
        b = thisispolyphase(this)
        b = thisisquantizable(this)
        b = thisisquantized(this)
        b = thisisreal(this)
        b = thisisrealizable(this)
        f = thisisscalar(Hd)
        b = thisisscalarstructure(this)
        f = thisissos(Hd)
        b = thisisstable(this)
        n = thisnpolyphase(this)
        nsecs = thisnsections(Hd)
        n = thisorder(this)
        b = thisreffilter(Hd)
        Hs = tosysobj(this,returnSysObj)
        [inputProc,rateOptionsFrameBased,rateOptionsSampleBased] = validinputprocrateoptions(H,type)
        verifyinputprocrateopts(Hd,hTar,type)
        warnifreset(h,prop,value)
        args = wloptiminputparse(this,varargin)
        
        function values = getAllowedStringValues(obj,prop)
            % This function gives the the valid string values for object properties.
            
            switch prop
                case 'Arithmetic'
                    values = {...
                        'double'
                        'fixed'
                        'single'};
                    
                case {'FilterInternals', 'RoundMode','ProductMode','AccumMode','OverflowMode','TapSumMode', ...
                        'OutputMode'}
                    values = getAllowedStringValues(obj.filterquantizer,prop);
                
                otherwise
                    values = {};
            end
            
        end
        
    end  
    
    methods(Hidden,Sealed)
        f = base_is(Hb,fcn,varargin)
        f = base_num(Hb,fcn,varargin)
        [h,w] = base_resp(Hb,fcn,varargin)
        c = cost(this,archobj)
        disp(Hb)
        Hflat = flatcascade(this,Hflat)
        [Hdnew,opts] = freqzparse(Hd,varargin)
        b = isquantized(this)
        b = isrealizable(this)
        Hd = reffilter(this)
        [Hdnew,opts] = timezparse(Hd,varargin)
        vectordisp(this)
    end
    
    methods (Static) % static methods
        this = loadobj(s)
    end  % static methods
    
    methods (Static, Sealed, Access = protected)
        function default_object = getDefaultScalarElement
            default_object = dfilt.basefilter;
        end
    end
end  % classdef

function R = setrate(Hm,R) %#ok<INUSL>
%SETRATE Overloaded set for the RateChangeFactor property.

if length(R)~=2
    error(message('signal:dfilt:basefilter:schema:InternalError'));
end
end  % setrate


%[EOF]
