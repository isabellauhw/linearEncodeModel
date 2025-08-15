classdef (Abstract) multistage < dfilt.basefilter
    %MULTISTAGE   Multistage filter virtual class.
    %   MULTISTAGE is a virtual class---it is never intended to be instantiated.

    
    %dfilt.multistage class
    %   dfilt.multistage extends dfilt.basefilter.
    %
    %    dfilt.multistage properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       Stage - Property is of type 'dfilt.basefilter vector'
    %
    %    dfilt.multistage methods:
    %       addsection - Add a section to the filter.
    %       addstage -   Add a stage to the filter.
    %       appendcoeffstageindex - Append stage index to coefficient names
    %       blockparams - Returns the parameters for BLOCK
    %       cfi -   Return the information for the CFI.
    %       chkIfRedrawNecessary - checks to see whether the FILTER blk needs to be redrawn
    %       coefficientnames -  Coefficient names.
    %       computephasez - Compute the phasez
    %       computestepz - Compute the stepz for the filter
    %       convertchoices -   Return the structure choices.
    %       denormalize - Undo normalization applied by NORMALIZE.
    %       dfiltname - DFILT object name.
    %       dfiltvariable - DFILT Variable string.
    %       dispatch - Returns the contained DFILT objects.
    %       dispstr - Coefficient display string for discrete-time filter.
    %       doFrameProcessing - Returns true if frame processing if supported by realizemdl()
    %       double -   Cast filter to a double-precision arithmetic version.
    %       exportinfo - Export information for the DFILT class.
    %       exportstates - Export the final conditions.
    %       filt2struct -   Return a structure representation of the object.
    %       firlp2hp - FIR Lowpass to highpass transformation
    %       firlp2lp - FIR Lowpass to lowpass transformation
    %       firxform - XFORM Frequency Transformations.
    %       genmcode - Generate MATLAB code
    %       get_filterquantizer - get the filterquantizer for the first stage of multistage filters.
    %       iirbpc2bpc - IIR complex bandpass to complex bandpass transformation
    %       iirlp2bp - IIR Lowpass to bandpass transformation
    %       iirlp2bpc - IIR Lowpass to complex bandpass transformation
    %       iirlp2bs - IIR Lowpass to bandstop transformation
    %       iirlp2bsc - IIR Lowpass to complex bandstop transformation
    %       iirlp2hp - IIR Lowpass to highpass transformation
    %       iirlp2lp - IIR Lowpass to lowpass transformation
    %       iirlp2mb - IIR Lowpass to multiband transformation
    %       iirlp2mbc - IIR Lowpass to complex multiband transformation
    %       iirlp2xc - IIR Lowpass to complex N-Point transformation
    %       iirlp2xn - IIR Lowpass to N-Point transformation
    %       iirxform - XFORM Frequency Transformations.
    %       importstates - Import the initial conditions ZI into the States property.
    %       isblockable - True if the object supports the block method
    %       isrealizable - True if the structure can be realized by simulink
    %       loadobj -   Load this object.
    %       ms_freqresp - Compute the MultiSection Frequency Response
    %       nadd - Returns the number of adders
    %       nmult - Returns the number of multipliers
    %       normalize - Normalize coefficients of each section between -1 and 1.
    %       nstages -   Returns the number of stages.
    %       nstates -  Number of states in discrete-time filter.
    %       parallel - Connect filters in parallel.
    %       parse_coeffstoexport - Store coefficient names and values into hTar for
    %       privnports - Number of input ports of the realizemdl model
    %       realizemdl - Filter realization (Simulink diagram).
    %       removesection - Remove a section to the filter.
    %       removestage -   Remove a stage.
    %       reset - Reset the filter.
    %       saveobj -   Save this object.
    %       set_persistentmemory -   PreSet function for the 'persistentmemory' property.
    %       setsection - Set a section of the filter.
    %       setstage -   Set the stage.
    %       this_setstage - PreSet function for the stage property.
    %       thiscoeffs - Get the coefficients.
    %       thiscoefficients - Filter coefficients.
    %       thisdisp - Display method of discrete-time filter.
    %       thisfirtype - FIRTYPE  Determine the type (1-4) of a linear phase FIR filter.
    %       thisimpzlength - IMPZLENGTH Length of the impulse response for a digital filter.
    %       thisisallpass - ISALLPASS  True for allpass filter.
    %       thisiscascade - ISCASCADE  True for cascaded filter.
    %       thisisfir -  True for FIR filter.
    %       thisislinphase -  True for linear phase filter.
    %       thisismaxphase - True if maximum phase.
    %       thisisminphase - True if minimum phase.
    %       thisisparallel -  True for filter with parallel sections.
    %       thisisquantizable - Returns true if the dfilt object can be quantized
    %       thisisquantized -   Returns true if any section of the filter is quantized.
    %       thisisreal - ISREAL  True for filter with real coefficients.
    %       thisisrealizable - True if the structure can be realized by simulink
    %       thisisscalar -   Returns true if all the sections are scalar.
    %       thisissos - ISSOS  True if second-order-section.
    %       thisisstable - ISSTABLE  True if filter is stable.
    %       thisnsections - Number of sections in a discrete filter.
    %       thisnstates - NSTATES Number of states.
    %       thisorder - Filter order.
    %       thisreffilter - DOUBLE   Returns the double representation of the filter object.
    %       thissfcnparams - Returns the parameters for SDSPFILTER
    
    
    properties (SetAccess=protected)
        %FILTERSTRUCTURE Property is of type 'ustring'  (read only)
        FilterStructure = '';
    end
    
    properties
        %STAGE Property is of type 'dfilt.basefilter vector'
        Stage = [];
    end
    
    properties (Transient, Hidden)
        %SECTION Property is of type 'mxArray'  (hidden)
        Section = [];
    end
    
    
    methods
        function set.FilterStructure(obj,value)
            % DataType = 'ustring'
            % no cell string checks yet'
            obj.FilterStructure = value;
        end
        
        function set.Stage(obj,value)
            % DataType = 'dfilt.basefilter vector'
            validateattributes(value,{'dfilt.basefilter'}, {'vector'},'','Stage');
            if isrow(value) %if value is a row vector, convert to a column
                value = value';
            end
            obj.Stage = dfilt.multistage.this_setstage(obj,value);
        end
        
        function value = get.Section(obj)
            value = getobsoleteprop(obj,obj.Section,'Section','Stage',false,true);
        end
        function set.Section(obj,value)
            obj.Section = setobsoleteprop(obj,value,'Section','Stage',false,true);
        end
        
    end   % set and get functions
    
    methods
        addstage(this,Hd,pos)
        n = nstages(this)
        realizemdl(H,varargin)
        removestage(this,indx)
        setstage(this,Hd,pos)
    end  % public methods
    
    
    methods (Hidden)
        addsection(Hd,section,pos)
        coeff = appendcoeffstageindex(this,coeff,index)
        varargout = autoscale(this,x)
        [lib,srcblk,hasInputProcessing,hasRateOptions] = blocklib(~,~)
        s = blockparams(Hd,mapstates,varargin)
        fi = cfi(this)
        [redraw,nstages_equal,h] = chkIfRedrawNecessary(Hd,h,sys,filter_structure)
        [p,v] = coefficient_info(this)
        c = coefficientnames(Hd)
        c = coefficientvariables(Hd)
        [y,T] = computeimpz(this,varargin)
        [phi,w] = computephasez(Hd,varargin)
        [y,t] = computestepz(Hd,varargin)
        [hz,wz,phiz,opts] = computezerophase(Hd,varargin)
        [targs,strs] = convertchoices(this)
        denormalize(Hd)
        c = dfiltname(Hd)
        c = dfiltvariable(Hd)
        Hd = dispatch(Hd)
        s = dispstr(this,varargin)
        flag = doFrameProcessing(Hd)
        h = double(this)
        s = exportinfo(Hd)
        zf = exportstates(Hd)
        s = filt2struct(this)
        Ht = firlp2hp(Hd,varargin)
        Ht = firlp2lp(Hd,varargin)
        Ht = firxform(Ho,fun,varargin)
        str = genmcode(Hm,objname,place)
        fq = get_filterquantizer(this,fq)
        [Ht,anum,aden] = iirbpc2bpc(Hd,varargin)
        [Ht,anum,aden] = iirlp2bp(Hd,varargin)
        [Ht,anum,aden] = iirlp2bpc(Hd,varargin)
        [Ht,anum,aden] = iirlp2bs(Hd,varargin)
        [Ht,anum,aden] = iirlp2bsc(Hd,varargin)
        [Ht,anum,aden] = iirlp2hp(Hd,varargin)
        [Ht,anum,aden] = iirlp2lp(Hd,varargin)
        [Ht,anum,aden] = iirlp2mb(Hd,varargin)
        [Ht,anum,aden] = iirlp2mbc(Hd,varargin)
        [Ht,anum,aden] = iirlp2xc(Hd,varargin)
        [Ht,anum,aden] = iirlp2xn(Hd,varargin)
        [Ht,anum,aden] = iirxform(Ho,fun,varargin)
        importstates(Hd,zi)
        b = isblockable(this)
        logi = isparallelfilterable(this)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        [h,w] = ms_freqresp(Hd,fcn,cfcn,varargin)
        n = nadd(this)
        n = nmult(this,optimones,optimnegones)
        varargout = normalize(Hd)
        [hTar,domapcoeffstoports] = parse_coeffstoexport(Hd,hTar)
        n = privnports(this)
        removesection(Hd,pos)
        reset(Hd)
        s = saveobj(this)
        persistentmemory = set_persistentmemory(Hd,persistentmemory)
        setsection(Hd,section,pos)
        c = thiscoeffs(this)
        c = thiscoefficients(Hd)
        thisdisp(this)
        filtertype = thisfirtype(Hd)
        len = thisimpzlength(Hd,varargin)
        f = thisisallpass(Hd,tol)
        f = thisiscascade(Hd)
        f = thisisfir(Hd)
        f = thisislinphase(Hd,tol)
        f = thisismaxphase(Hd,tol)
        f = thisisminphase(Hd,tol)
        f = thisisparallel(Hd)
        bool = thisisquantizable(Hd)
        b = thisisquantized(this)
        f = thisisreal(Hd)
        f = thisisrealizable(Hd)
        b = thisisscalar(this)
        f = thisissos(Hd)
        f = thisisstable(Hd)
        nsecs = thisnsections(Hd)
        n = thisnstates(Hd)
        n = thisorder(Hd)
        h = thisreffilter(this)
        varargout = thissfcnparams(Hd)
        verifyautoscalability(this)
    end  % possibly private or hidden
    
    methods (Static) % static methods
        this = loadobj(s)
        s = this_setstage(Hd,s)
    end  % static methods
    
    methods(Sealed)
        Hd = parallel(varargin)
        n = nstates(Hd)
    end
    
end  % classdef

