classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) highpass < fdesign.abstracttypewspecs & dynamicprops
%HIGHPASS   Construct a HIGHPASS filter designer.
%   D = FDESIGN.HIGHPASS(SPECSTRING,VALUE1,VALUE2,...) constructs a
%   highpass filter designer D. Note that D is not the design itself, it
%   only contains the design specifications. In order to design the filter,
%   one needs to invoke the DESIGN method on D.
%   For example (more examples below):
%   D = fdesign.highpass('Fst,Fp,Ast,Ap',0.4,0.5,80,1);
%   H = design(D,'equiripple'); % H is a DFILT
%
%   SPECSTRING is a string that determines what design specifications will
%   be used. There are several possible specifications, a complete list is
%   given below.
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS to get a list of design methods
%   available for a given SPEC: designmethods(D).
%
%   VALUE1, VALUE2, etc. are scalars that provide the value of the
%   corresponding specification. In the example above, this means that Fst
%   = 0.4, Fp = 0.5, Ast = 80, and Ap = 1. Use get(D, 'description') for a
%   description of VALUE1, VALUE2, etc.
%
%   By default, all frequency specifications are assumed to be in
%   normalized frequency units. Moreover, all magnitude specifications are
%   assumed to be in dB.
%
%   D = FDESIGN.HIGHPASS(...,Fs) provides the sampling frequency of the
%   signal to be filtered. Fs must be specified as a scalar trailing the
%   other numerical values provided. For this case, Fs is assumed to be in
%   Hz as are all other frequency values provided. Note that you don't
%   change the specification string in this case. In the example above, if
%   the input signal is sampled at 8 kHz, we can obtain the same filter by
%   specifying the frequencies in Hz as:
%   D = fdesign.highpass('Fst,Fp,Ast,Ap',1600,2000,80,1,8000);
%   H = design(D,'equiripple');
%
%   D = FDESIGN.HIGHPASS(...,MAGUNITS) specifies the units for any magnitude
%   specification given. MAGUNITS can be one of the following: 'linear',
%   'dB', or 'squared'. If this argument is omitted, 'dB' is assumed. Note
%   that the magnitude specifications are always converted and stored in dB
%   regardless of how they were specified. If Fs is provided, MAGUNITS must
%   be provided after Fs in the input argument list.
%   
%   The full list of possible values for SPECSTRING (not case sensitive)
%   is:
%
%         'Fst,Fp,Ast,Ap' (minimum order; default)
%         'N,F3dB'
%         'Nb,Na,F3dB'
%         'N,F3dB,Ap' (*)
%         'N,F3dB,Ast' (*)
%         'N,F3dB,Fp' (*)
%         'N,F3dB,Ast,Ap' (*)
%         'N,Fc'
%         'N,Fc,Ast,Ap' 
%         'N,Fp,Ap'
%         'N,Fp,Ast,Ap'
%         'N,Fst,Ast'
%         'N,Fst,F3dB' (*)
%         'N,Fst,Fp'
%         'N,Fst,Ast,Ap' (*)
%         'N,Fst,Fp,Ap' (*)
%         'N,Fst,Fp,Ast' (*)
%         'Nb,Na,Fst,Fp' (*)
%
%  where 
%       Ap    - Passband Ripple (dB)
%       Ast   - Stopband Attenuation (dB)
%       F3dB  - 3dB Frequency
%       Fc    - Cutoff Frequency
%       Fp    - Passband Frequency
%       Fst   - Stopband Frequency
%       N     - Filter Order
%       Nb    - Numerator Order
%       Na    - Denominator Order
%
%   D = FDESIGN.HIGHPASS(Fstop, Fpass, Astop, Apass) uses the  default
%   SPECSTRING ('Fst,Fp,Ast,Ap') and sets the stopband-edge frequency,
%   passband-edge frequency, stopband attenuation, and passband ripple.
%
%   % Example #1 - Design an equiripple highpass filter. Specify ripples in
%   % linear units.
%   d  = fdesign.highpass('Fst,Fp,Ast,Ap',0.31,0.32,1e-3,1e-2,'linear');
%   Hd = design(d, 'equiripple');
%   fvtool(Hd)
%
%   % Example #2 - Design a Chebyshev Type I IIR filter with a passband
%   % ripple of 0.5 dB and a 3 dB cutoff frequency at 9600 Hz. (*)
%   Fs = 48000; % Sampling frequency of input signal
%   d  = fdesign.highpass('N,F3dB,Ap', 10, 9600, .5, Fs);
%   Hd = design(d, 'cheby1');
%   fvtool(Hd)
%
%   % Example #3 - Design an equiripple filter with a stopband edge of
%   % 0.65*pi rad/sample and a passband edge of 0.75*pi rad/sample. Shape the
%   % stopband to have a linear decay with a slope of 10 dB/rad/sample. (*)
%   d  = fdesign.highpass('N,Fst,Fp', 50, 0.65, 0.75);
%   Hd = design(d, 'equiripple','StopbandShape','linear','StopbandDecay',20);
%   fvtool(Hd)
%
%   %(*) DSP System Toolbox required
%
%   See also FDESIGN, FDESIGN/SETSPECS, FDESIGN/DESIGN, FDESIGN/DESIGNOPTS.

%fdesign.highpass class
%   fdesign.highpass extends fdesign.abstracttypewspecs.
%
%    fdesign.highpass properties:
%       Response - Property is of type 'ustring' (read only) 
%       Description - Property is of type 'string vector' (read only) 
%       Specification - Property is of type 'highpassSpecTypeswFDTbx enumeration: {'Fst,Fp,Ast,Ap','N,F3dB','Nb,Na,F3dB','N,F3dB,Ap','N,F3dB,Ast','N,F3dB,Ast,Ap','N,F3dB,Fp','N,Fc','N,Fc,Ast,Ap','N,Fp,Ap','N,Fp,Ast,Ap','N,Fst,Ast','N,Fst,Ast,Ap','N,Fst,F3dB','N,Fst,Fp','N,Fst,Fp,Ap','N,Fst,Fp,Ast','Nb,Na,Fst,Fp'}'  
%
%    fdesign.highpass methods:
%       getconstructor - Return the constructor for the specification type.
%       getdialogconstructor -   Get the dialogconstructor.
%       getfdatooltypes -   Get the fdatooltypes.
%       getmask -   Get the mask.
%       getmeasureconstructor -   Get the measureconstructor.
%       getmeasurementfields -   Get the measurementfields.
%       getmultiratespectypes -   Get the multiratespectypes.
%       getnoiseshapefilter - Get the noiseshapefilter.
%       getspeclist - Get list of spec strings
%       isspecmet -   True if the object's specification has been met by the filter.
%       multiratedefaults - Setup the defaults for multirate.
%       noiseshape - Noise-shape the FIR filter Hd
%       passbandspecmet - Check whether passband response is within spec.
%       sosreorder -   Reorder SOS filter.
%       thispassbandzoom -   Returns the limits of the passband zoom.

%   Copyright 2004-2015 The MathWorks, Inc.

properties (SetObservable, GetObservable)
  %SPECIFICATION Specification String
  %  Set specification string as one of:
  %  'Fst,Fp,Ast,Ap'
  %  'N,F3dB'
  %  'Nb,Na,F3dB'
  %  'N,F3dB,Ap'
  %  'N,F3dB,Ast'
  %  'N,F3dB,Ast,Ap'
  %  'N,F3dB,Fp'
  %  'N,Fc'
  %  'N,Fc,Ast,Ap'
  %  'N,Fp,Ap'
  %  'N,Fp,Ast,Ap'
  %  'N,Fst,Ast'
  %  'N,Fst,Ast,Ap'
  %  'N,Fst,F3dB'
  %  'N,Fst,Fp'
  %  'N,Fst,Fp,Ap'
  %  'N,Fst,Fp,Ast'
  %  'Nb,Na,Fst,Fp'
  %  The default is 'Fst,Fp,Ast,Ap'
  Specification 
end


methods  % constructor block
  function this = highpass(varargin)


  % this = fdesign.highpass;

  [varargin,flag] = finddesignfiltflag(this,varargin);

  this.Response = 'Highpass';

  if flag 
    specObj = this.getcurrentspecs;
    specObj.FromDesignfilt = true;
  end

  this.Specification = 'Fst,Fp,Ast,Ap'; 

  this.setspecs(varargin{:});

  capture(this);


  end  % highpass
end  % constructor block

methods 
  function value = get.Specification(obj)
    value = get_specification(obj,obj.Specification);
  end
  %------------------------------------------------------------------------
  function set.Specification(obj,value)
    validValue = validatestring(value, ... 
      getAllowedStringValues(obj,'Specification'),'','Specification');
    obj.Specification = set_specification(obj,validValue);
  end
end   % set and get functions 
   
methods
  function vals = getAllowedStringValues(obj,prop)
    if strcmp(prop,'Specification')
      [SPTList, DSTList] = fdesign.highpass.getspeclist;
      if isfdtbxinstalled
          vals = DSTList';
      else
          vals = SPTList';
      end
    else
      vals = {};
    end
  end
end
    
methods (Access = protected)
  %This function defines the display behavior for the class
  %using matlab.mixin.util.CustomDisplay
  function propgrp = getPropertyGroups(obj)
    propList = get(obj);
    cpropList = propstoadd(obj.CurrentSpecs);
    propList = reorderstructure(propList,'Specification','Response','Description',cpropList{:});
    if propList.NormalizedFrequency 
      propList = rmfield(propList, 'Fs');
    end
    propgrp = matlab.mixin.util.PropertyGroup(propList);
  end
end
      
methods  % public methods
  cSpecCon = getconstructor(this,stype)
  dialogconstructor = getdialogconstructor(this)
  fdatooltypes = getfdatooltypes(this)
  [F,A] = getmask(this,fcns,rcf,specs)
  measureconstructor = getmeasureconstructor(this)
  measurementfields = getmeasurementfields(this)
  multiratespectypes = getmultiratespectypes(this)
  nsf = getnoiseshapefilter(this,nnsf,cb)
  b = isspecmet(this,Hd)
  multiratedefaults(this,maxfactor)
  Hns = noiseshape(this,Hd,WL,args)
  flag = passbandspecmet(Hf,Hd,ng)
  sosreorder(this,Hd)
  [xlim,ylim] = thispassbandzoom(this,fcns,Hd,hfm)
end  % public methods 


methods (Hidden) % possibly private or hidden
  checkoutfdtbxlicense(this)
end  % possibly private or hidden 


methods (Static) % static methods
  [specListSPT,specListDST] = getspeclist()
end  % static methods 

end  % classdef

% [EOF]
