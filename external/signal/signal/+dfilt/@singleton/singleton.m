classdef (Abstract) singleton < dfilt.abstractfilter
    %SINGLETON Singleton filter virtual class.
    %   SINGLETON is a virtual class---it is never intended to be instantiated.
    
    %dfilt.singleton class
    %   dfilt.singleton extends dfilt.abstractfilter.
    %
    %    dfilt.singleton properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %
    %    dfilt.singleton methods:
    %       blocklib - BLOCKPARAMS Returns the library and source block for BLOCKPARAMS
    %       convert - Convert structure of DFILT object.
    %       denormalize -   Reverse coefficient changes made by NORMALIZE.
    %       dfiltname - DFILT object name.
    %       dfiltvariable - DFILT Variable string.
    %       disp4filtstates - Utility for objects which use a FILTSTATES.DFIIR object.
    %       exportinfo - Export information for the DFILT class.
    %       exportstates - Export the final conditions.
    %       filter - Discrete-time filter.
    %       firlp2hp - FIR Lowpass to highpass frequency transformation
    %       firlp2lp - FIR Lowpass to lowpass frequency transformation
    %       firxform - FIR Transformations
    %       genmcode - Generate the MATLAB code to reproduce the filter.
    %       iirbpc2bpc - IIR complex bandpass to complex bandpass frequency transformation.
    %       iirlp2bp - IIR lowpass to bandpass frequency transformation.
    %       iirlp2bpc - IIR lowpass to complex bandpass frequency transformation.
    %       iirlp2bs - IIR lowpass to bandstop frequency transformation.
    %       iirlp2bsc - IIR lowpass to complex bandstop frequency transformation.
    %       iirlp2hp - IIR lowpass to highpass frequency transformation.
    %       iirlp2lp - IIR lowpass to lowpass frequency transformation.
    %       iirlp2mb - IIR lowpass to multiband frequency transformation.
    %       iirlp2mbc - IIR lowpass to complex multiband frequency transformation.
    %       iirlp2xc - IIR lowpass to complex N-point frequency transformation.
    %       iirlp2xn - IIR lowpass to N-point frequency transformation.
    %       iirxform - IIR Transformations
    %       importstates - Import the initial conditions ZI into the States property.
    %       isfixedptable - True is the structure has an Arithmetic field
    %       normalize - Normalize coefficients between -1 and 1.
    %       quantizecoeffs -  Quantize coefficients
    %       set_coeffs - Set the coefficients.
    %       sfcnparams - Returns the parameters for SDSPFILTER
    %       thisimpzlength - IMPZLENGTH Length of the impulse response for a digital filter.
    %       thisiscascade - ISCASCADE  True for cascaded filter.
    %       thisisparallel -  True for filter with parallel sections.
    %       thisisquantizable - Returns true if the dfilt object can be quantized
    %       thisisscalarstructure -  True if scalar filter.
    %       thisorder - Filter order.
    %       thissfcnparams - Returns the parameters for SDSPFILTER
    %       tocalattice -  Convert to coupled allpass lattice.
    %       tocalatticepc -  Convert to couple allpass lattice, power complementary output.
    %       todf1 -  Convert to direct-form 1.
    %       todf1t -  Convert to direct-form 1 transposed.
    %       todf2 -  Convert to direct-form 2.
    %       todf2t -  Convert to direct-form 2 transposed.
    %       todfasymfir -  Convert to antisymmetric FIR.
    %       todffir -  Convert to direct-form FIR.
    %       todffirt -  Convert to direct-form FIR transposed.
    %       todfsymfir -  Convert to direct-form symmetric FIR.
    %       tolatticeallpass -  Convert to lattice allpass.
    %       tolatticear -   Convert to a latticear filter.
    %       tolatticearma -  Convert to lattice ARMA.
    %       tolatticemamax -  Convert to lattice MA maximum-phase.
    %       toscalar -  Convert to scalar.
    %       tostatespace -  Convert to statespace.
    %       updateprops - Update phantom properties each time a dynamic property is added or removed.
    %       ziscalarexpand - Expand empty or scalar initial conditions to a vector.
    %       zpk -  Discrete-time filter zero-pole-gain conversion.
    
    
    properties (Access=protected, SetObservable)
        %PRIVNORMGAIN Property is of type 'mxArray'
        privnormGain = [];
    end
        
    methods  % public methods
        Hd2 = convert(Hd,newstruct)
        y = filter(Hd,x,dim)
        [z,p,k] = zpk(Hd)
    end  % public methods
    
    
    methods(Hidden) 
        [lib,srcblk,hasInputProcessing,hasRateOptions] = blocklib(~,link2obj,forceDigitalFilterBlock)
        [targs,strs] = convertchoices(this)
        denormalize(Hd)
        c = dfiltname(Hd)
        pnames = dfiltprivnames(this)
        privvals = dfiltprivvals(this)
        c = dfiltvariable(Hd)
        snewstr = disp4filtstates(Hd,s)
        Hd = dispatch(Hd)
        s = exportinfo(Hd)
        zf = exportstates(Hd)
         Ht = firlp2hp(Ho,varargin)
        Ht = firlp2lp(Ho)
        Ht = firxform(Ho,fun,varargin)
        str = genmcode(Hd,objname,place)
        privvals = getprivvals(this)
        [Ht,anum,aden] = iirbpc2bpc(Ho,varargin)
        [Ht,anum,aden] = iirlp2bp(Ho,varargin)
        [Ht,anum,aden] = iirlp2bpc(Ho,varargin)
        [Ht,anum,aden] = iirlp2bs(Ho,varargin)
        [Ht,anum,aden] = iirlp2bsc(Ho,varargin)
        [Ht,anum,aden] = iirlp2hp(Ho,varargin)
        [Ht,anum,aden] = iirlp2lp(Ho,varargin)
        [Ht,anum,aden] = iirlp2mb(Ho,varargin)
        [Ht,anum,aden] = iirlp2mbc(Ho,varargin)
        [Ht,anum,aden] = iirlp2xc(Ho,varargin)
        [Ht,anum,aden] = iirlp2xn(Ho,varargin)
        [Ht,anum,aden] = iirxform(Ho,fun,varargin)
        importstates(Hd,zi)
        fixflag = isfixedptable(Hd)
        logi = isparallelfilterable(this)
        loadprivatedata(this,s)
        varargout = normalize(Hd)
        s = objblockparams(this,varname)
        pnames = privnames(this)
        labels = propnames(this)
        coeffs = propvalues(this)
        quantizecoeffs(h,eventData)
        s = saveprivatedata(this)
        c = set_coeffs(this,c)
        setdfiltprivvals(this,privvals)
        setprivvals(this,privvals)
        params = sfcnparams(Hd,library)
        len = thisimpzlength(Hd,varargin)
        [p,v] = thisinfo(this)
        f = thisiscascade(Hd)
        f = thisisparallel(Hd)
        bool = thisisquantizable(Hd)
        f = thisisscalarstructure(Hd)
        n = thisorder(Hd)
        varargout = thissfcnparams(Hd)
        h = toallpass(this)       
        Hd2 = tocalattice(Hd)
        Hd2 = tocalatticepc(Hd)
        h = tocascadeallpass(this)
        h = tocascadewdfallpass(this)
        Hd2 = todf1(Hd)
        Hd2 = todf1t(Hd)
        Hd2 = todf2(Hd)
        Hd2 = todf2t(Hd)
        Hd2 = todfasymfir(Hd)
        Hd2 = todffir(Hd)
        Hd2 = todffirt(Hd)
        Hd2 = todfsymfir(Hd)
        Hd2 = tolatticeallpass(Hd)
        Hd = tolatticear(this)
        Hd2 = tolatticearma(Hd)
        Hd2 = tolatticemamax(Hd)
        Hd2 = tolatticemamin(Hd)
        Hd2 = toscalar(Hd)
        Hd2 = tostatespace(Hd)
        h = towdfallpass(this)
        updateprops(h,eventData)
        S = ziscalarexpand(Hd,S)
    end  % possibly private or hidden
      
    
end  % classdef

