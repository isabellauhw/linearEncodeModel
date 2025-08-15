classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) fftfir < dfilt.dtffir
    %FFTFIR Overlap-add FIR.
    %   Hd = DFILT.FFTFIR(NUM,L) constructs a discrete-time FIR filter object
    %   for filtering using the overlap-add method.
    %
    %   NUM is a vector of numerator coefficients.
    %
    %   L is the length of each block of input data used in the filtering.
    %
    %   The number of FFT points is given by L+length(NUM)-1. It may be
    %   advantageous to choose L such that the number of FFT points is a power
    %   of two.
    %
    %   Note that one usually does not construct DFILT filters explicitly.
    %   Instead, one obtains these filters as a result from a design using <a
    %   href="matlab:help fdesign">FDESIGN</a>.
    %
    %   % EXAMPLE #1: Direct instantiation
    %   b = [0.05 0.9 0.05];
    %   len = 50;
    %   Hd = dfilt.fftfir(b,len)
    %
    %   % EXAMPLE #2: Design an equiripple lowpass filter with default specifications
    %   Hd = design(fdesign.lowpass, 'equiripple', 'Filterstructure', 'fftfir');
    %   fvtool(Hd)        % Analyze filter
    %   x = randn(100,1); % Input signal
    %   y = filter(Hd,x); % Apply filter to input signal
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.fftfir class
    %   dfilt.fftfir extends dfilt.dtffir.
    %
    %    dfilt.fftfir properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Numerator - Property is of type 'mxArray'
    %       BlockLength - Property is of type 'posint user-defined'
    %       NonProcessedSamples - Property is of type 'MATLAB array'  (read only)
    %
    %    dfilt.fftfir methods:
    %       blocklib - BLOCKPARAMS Returns the library and source block for BLOCKPARAMS
    %       blockparams - Returns the parameters for BLOCK
    %       blocksetup - Setup the filter object to the correct blocklength in
    %       dfobjsfcnparams - S function parameters for SDSPFILTER
    %       fftcoeffs -  Get the FFT coefficients used for the filtering.
    %       firxform - FIR Transformations
    %       getblockinputprocessingrestrictions - Get input processing restrictions for
    %       getstates - Overloaded get for the States property.
    %       iirxform - IIR Transformations
    %       isblockrequiredst - Check if block method requires a DST license
    %       isfixedptable - True is the structure has an Arithmetic field
    %       ishdlable - True if HDL can be generated for the filter object.
    %       loadpublicinterface -   Load the public interface.
    %       nsectionsfft - Returns the number of sections of the FFT.
    %       optimizecoeffwlfir - Optimize coefficient wordlength for FIR filters.
    %       savepublicinterface -   Save the public interface.
    %       secfilter - Filter this section.
    %       setblocklength - Overloaded set on the blocklength property.
    %       setnumerator - Overloaded set on the Numerator property.
    %       ss -  Discrete-time filter to state-space conversion.
    %       thisdisp - Object display.
    %       thisisrealizable -   Return true if the object is realizable
    %       thisreset - Reset the non processed samples.
    %       thissetstates - Overloaded set for the States property.
    %       tosysobj - Convert to a System object
    %       ziexpand - Expand initial conditions for multiple channels when necessary
    
    
    properties (Access=protected, SetObservable)
        %FFTCOEFFS Property is of type 'MATLAB array'
        privfftcoeffs = [];
    end
    
    properties (SetAccess=protected, SetObservable)
        %NONPROCESSEDSAMPLES Property is of type 'MATLAB array'  (read only)
        NonProcessedSamples = [];
    end
    
    properties (SetObservable)
        %BLOCKLENGTH Property is of type 'posint user-defined'
        BlockLength = [];
    end
    
    
    methods  % constructor block
        function Hd = fftfir(num,L)
            
            Hd.privfq = dfilt.filterquantizer;
            Hd.privfilterquantizer = dfilt.filterquantizer;
            Hd.FilterStructure = 'Overlap-Add FIR';
            Hd.Numerator = 1;
            Hd.States = [];
            
            if nargin>=1
                Hd.Numerator = num;
            end
            
            if nargin < 2
                % Set a default blocklength
                % Don't use factoryValue so overload set runs
                L = 100;
            end
            
            Hd.BlockLength = L;
            
        end  % fftfir
        
    end  % constructor block
    
    methods
        function set.BlockLength(obj,value)
            % User-defined DataType = 'posint user-defined'
            obj.BlockLength = setblocklength(obj,value);
        end
        
    end   % set and get functions
    
    methods
        c = fftcoeffs(Hd)
        [A,B,C,D] = ss(Hd)
        [result,errstr,errorObj] = ishdlable(Hb)
    end  % public methods
    
    methods (Hidden)
        BL = blocklength(Hm)
        [lib,srcblk,hasInputProcessing,hasRateOptions] = blocklib(~,~)
        s = blockparams(Hd,mapstates,varargin)
        blocksetup(Hd)
        Hd = constraincoeffwlfir(this,Href,WL,varargin)
        s = dfobjsfcnparams(Hd)
        c = evalcost(this)
        Ht = firxform(Ho,fun,varargin)
        xi = getnonprocessedsamples(Hm)
        r = getblockinputprocessingrestrictions(~)
        S = getstates(Hm,S)
        [Ht,anum,aden] = iirxform(Ho,fun,varargin)
        isblockrequiredst(~)
        fixflag = isfixedptable(Hd)
        loadpublicinterface(this,s)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        Hbest = minimizecoeffwlfir(this,varargin)
        n = nsectionsfft(Hd)
        s = objblockparams(this,varname)
        [Hbest,mrfflag] = optimizecoeffwlfir(this,varargin)
        Hd = optimizestopbandfir(this,Href,WL,varargin)
        s = savepublicinterface(this)
        [y,z] = secfilter(Hd,x,z)
        L = setblocklength(Hd,L)
        setnonprocessedsamples(Hm,xf)
        num = setnumerator(Hd,num)
        thisdisp(this)
        f = thisisrealizable(this)
        thisreset(Hm)
        S = thissetstates(Hm,S)
        Hs = tosysobj(this,returnSysObj)
        zi = ziexpand(Hd,x,zi)
    end  % possibly private or hidden
    
end  % classdef

