classdef (Abstract) abstracttype < matlab.mixin.SetGet 
%ABSTRACTTYPE Abstract constructor produces an error.

%   Copyright 2004-2018 The MathWorks, Inc.
  
%fdesign.abstracttype class
%
%    fdesign.abstracttype methods:
%       base_isspecmet -   Returns true if the specification is met.
%       bpbsreorder -  Rule-of-thumb bandpass/bandstop reordering of SOS.
%       butter -   Butterworth IIR digital filter design.
%       cheby1 -   Chebyshev Type I digital filter design.
%       cheby2 -   Chebyshev Type II digital filter design.
%       design -   Design the filter.
%       designmethods - Returns a cell of design methods.
%       disp -   Display the design object.
%       drawmask -   Draw the mask.
%       ellip -   Elliptic or Cauer digital filter design.
%       equiripple -   Design an equiripple filter.
%       finddesignfiltflag -   Find FromDesignfilt flag
%       fircls -   FIR filter design using the constrained least squares method
%       firls -   Design a least-squares filter.   
%       getcurrentspecs - Get the currentspecs.
%       getdefaultmethod -   Get the defaultmethod.
%       getfvtoolinputs - Get the inputs to FVTool.
%       getmeasurements -   Get the measurements.
%       getnoiseshapefilter - Get the noiseshapefilter.
%       ifir -   Design a two-stage FIR filter using the IFIR method.
%       isdesignmethod -   Returns true if the method is a valid designmethod.
%       kaiserwin -   Design a filter using a kaiser window.
%       lphpreorder -   Rule-of-thumb lowpass/highpass reordering of SOS.
%       lphpreorderindx -  Determine indices for lowpass/highpass reorder. 
%       maskutils -  Utilities for drawing the masks.
%       maxflat -   FIR filter design using the maxflat method
%       measure -   Measure this object.
%       minwordlengthApass - Determine the passband ripples of the minimum wordlength filter
%       minwordlengthspecs - Determine the specs of the minimum wordlength filter
%       multistage -   Design a multistage FIR filter using the equiripple method.
%       noiseshapeparetobands - Returns the band where to measure the frequency
%       nominalgain -   Return the nominal gain.
%       parsesysobj - Parse SystemObject input design option
%       passbandzoom -   Returns the limits of the passband zoom.
%       privdesigngateway -   Gateway for all of the design methods.
%       propstocopy -   Returns the properties to copy that are not part of the specs.
%       superdesign -   Design the filter.
%       supernoiseshape - <short description>
%       thispassbandzoom -   Returns the limits of the passband zoom.
%       window -   FIR filter design using the window method.



methods  % public methods
  b = base_isspecmet(this,Hd,varargin)
  bpbsreorder(this,Hd)
  varargout = butter(this,varargin)
  varargout = cheby1(this,varargin)
  varargout = cheby2(this,varargin)
  varargout = design(this,varargin)
  varargout = designmethods(this,varargin)
  disp(this)
  varargout = drawmask(this,hfm,hax,varargin)
  varargout = ellip(this,varargin)
  varargout = equiripple(this,varargin)
  [outputs,flag] = finddesignfiltflag(~,inputs)
  varargout = fircls(this,varargin)
  varargout = firls(this,varargin)
  currentspecs = getcurrentspecs(~)
  defaultmethod = getdefaultmethod(this)
  fvtoolInputs = getfvtoolinputs(this)
  m = getmeasurements(this,varargin)
  nsf = getnoiseshapefilter(this)
  varargout = ifir(this,varargin)
  b = isdesignmethod(this,method)
  varargout = kaiserwin(this,varargin)
  lphpreorder(this,Hd)
  reorderindx = lphpreorderindx(this,Hd,nsections)
  fcns = maskutils(~,isconstrained,axes,units,fs,freqscale,xlim)
  varargout = maxflat(this,varargin)
  hm = measure(this,Hd,varargin)
  Apass = minwordlengthApass(f,md,Astop)
  [Fpass,Fstop,Apass,Astop] = minwordlengthspecs(this,h)
  varargout = multistage(this,varargin)
  bands = noiseshapeparetobands(this)
  g = nominalgain(this)
  [outputCell,sysObjFlag] = parsesysobj(~,callingMethod,varargin)
  [xlim,ylim] = passbandzoom(this,hfm,varargin)
  varargout = privdesigngateway(this,method,varargin)
  p = propstocopy(this)
  varargout = superdesign(this,method,varargin)
  nsres = supernoiseshape(this,b,linearphase,wl,cb,f,a,args)
  [xlim,ylim] = thispassbandzoom(this,fcns,Hd,hfm)
  varargout = window(this,varargin)
end  % public methods 


methods (Hidden) % possibly private or hidden
  varargout = ansis142(this,varargin)
  varargout = bell41009(this,varargin)
  checkoutfdtbxlicense(this)
  d = debug(this)
  d = defaultmethod(this)
  varargout = freqsamp(this,varargin)
  b = haspassbandzoom(this)
  varargout = iirlinphase(this,varargin)
  varargout = iirlpnorm(this,varargin)
  varargout = iirls(this,varargin)
  varargout = lagrange(this,varargin)
  varargout = multisection(this,varargin)
  supercheckoutfdtbxlicense(this)
  str = tostring(this)
  sysObjFlag = validatedesignoptionssysobjinput(~,varargin)

  function flag = isequal(a,b)
      % This function is for internal use only. It may change in a future release.
      flag = isequal(class(a),class(b)) && isequal(get(a), get(b));
  end

  function flag = isequaln(a,b)
      % This function is for internal use only. It may change in a future release.
      flag = isequal(class(a),class(b)) && isequaln(get(a), get(b));
  end

end  % possibly private or hidden 



end  % classdef

