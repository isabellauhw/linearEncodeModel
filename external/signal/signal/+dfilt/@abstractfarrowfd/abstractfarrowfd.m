classdef (Abstract) abstractfarrowfd < dfilt.abstractfilter
    %ABSTRACTFARROWFD Abstract class
    
    %dfilt.abstractfarrowfd class
    %   dfilt.abstractfarrowfd extends dfilt.abstractfilter.
    %
    %    dfilt.abstractfarrowfd properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %       FracDelay - Property is of type 'mxArray'
    %
    %    dfilt.abstractfarrowfd methods:
    %       dispstr - Display string of coefficients.
    %       get_delay -   PreGet function for the 'delay' property.
    %       isfixedptable - True is the structure has an Arithmetic field
    %       ishdlable - True if HDL can be generated for the filter object.
    %       quantizecoeffs -  Quantize coefficients
    %       refvals -   Reference coefficient values.
    %       set_delay -   PreSet function for the 'delay' property.
    %       set_filterquantizer -   PreSet function for the 'filterquantizer' property.
    %       set_privfq -   PreSet function for the 'privfq' property.
    %       setfarrowhdlcommonprops - Set the farrowhdlcommonprops
    %       setprivmeasurements -   Set the privmeasurements.
    %       setrefcoeffs -   Set the refcoeffs.
    %       setreffracdelay -   Set the reffracdelay.
    %       super_set_delay -   PreSet function for the 'delay' property.
    %       thisdisp -   Display this object.
    %       thisfiltquant_plugins - FILTQUANT_PLUGINS Table of filterquantizer plugins
    %       thisisreal -   True if the object is real.
    %       thisisrealizable - True if the structure can be realized by simulink
    %       thisisstable -   True if the object is stable.
    %       thissetstates - Overloaded set for the States property.
    
    
    properties (Access=protected, SetObservable)
        %PRIVFRACDELAY Property is of type 'DFILTNonemptyVector user-defined'
        privfracdelay = [];
        %REFFRACDELAY Property is of type 'DFILTNonemptyVector user-defined'
        reffracdelay = [];
        %PRIVCOEFFS Property is of type 'mxArray'
        privcoeffs = [];
        %REFCOEFFS Property is of type 'mxArray'
        refcoeffs = [];
    end
    
    properties (SetObservable)
        %FRACDELAY Property is of type 'mxArray'
        FracDelay = 0;
    end
    
    properties (Transient, SetObservable)
        %ARITHMETIC Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
        Arithmetic = 'double';
    end
    
    
    methods
        function value = get.Arithmetic(obj)
            value = get_arith(obj,obj.Arithmetic);
        end
        function set.Arithmetic(obj,value)
            % Enumerated DataType = 'filterdesign_arith enumeration: {'double','single','fixed'}'
            value = validatestring(value,{'double','single','fixed'},'','Arithmetic');
            obj.Arithmetic = set_arith(obj,value);
        end
        
        function value = get.FracDelay(obj)
            value = get_delay(obj,obj.FracDelay);
        end
        function set.FracDelay(obj,value)
            obj.FracDelay = set_delay(obj,value);
        end
        
        function set.privfracdelay(obj,value)
            % User-defined DataType = 'DFILTNonemptyVector user-defined'
            obj.privfracdelay = value;
        end
        
        function set.reffracdelay(obj,value)
            % User-defined DataType = 'DFILTNonemptyVector user-defined'
            obj.reffracdelay = setreffracdelay(obj,value);
        end
        
        function set.refcoeffs(obj,value)
            obj.refcoeffs = setrefcoeffs(obj,value);
        end
        
    end   % set and get functions
    
    methods  % public methods
        y = filter(this,x,dim)
        [result,errstr,errorObj] = ishdlable(Hb)
    end  % public methods
    
    
    methods (Hidden)
        n = coefficientnames(this)
        s = dispstr(Hd,varargin)
        delay = get_delay(this,delay)
        str = getinfoheader(Hm)
        fixflag = isfixedptable(Hd)
        logi = isparallelfilterable(this)
        loadpublicinterface(this,s)
        quantizecoeffs(h,eventData)
        quantizefd(this,eventdata)
        n = refcoefficientnames(this)
        rcvals = refvals(this)
        s = savepublicinterface(this)
        delay = set_delay(this,delay)
        newfq = set_filterquantizer(this,newfq)
        privfq = set_privfq(this,privfq)
        setfarrowhdlcommonprops(this,hF)
        setprivmeasurements(this,privmeasurements)
        refcoeffs = setrefcoeffs(this,refcoeffs)
        reffracdelay = setreffracdelay(this,reffracdelay)
        super_quantizecoeffs(this,eventData)
        delay = super_set_delay(this,delay)
        c = thiscoefficients(this)
        thisdisp(this)
        constr = thisfiltquant_plugins(h,arith)
        b = thisisreal(this)
        f = thisisrealizable(Hd)
        b = thisisstable(this)
        S = thissetstates(Hd,S)
    end  % possibly private or hidden
    
end  % classdef

