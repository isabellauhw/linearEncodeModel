classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) bandpass < fdesign.abstracttypewspecs & dynamicprops
%BANDPASS   Construct a BANDPASS filter designer.
%   D = FDESIGN.BANDPASS(SPECSTRING,VALUE1,VALUE2,...) constructs a
%   bandpass filter designer D. Note that D is not the design itself, it
%   only contains the design specifications. In order to design the filter,
%   one needs to invoke the DESIGN method on D.
%   For example (more examples below):
%   D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',.4,.5,.6,.7,60,1,80);
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
%   corresponding specification. Use get(D, 'description') for a
%   description of VALUE1, VALUE2, etc.
%
%   By default, all frequency specifications are assumed to be in
%   normalized frequency units. Moreover, all magnitude specifications are
%   assumed to be in dB.
%
%   D = FDESIGN.BANDPASS(...,Fs) provides the sampling frequency of the
%   signal to be filtered. Fs must be specified as a scalar trailing the
%   other numerical values provided. For this case, Fs is assumed to be in
%   Hz as are all other frequency values provided. Note that you don't
%   change the specification string in this case. In the example above, if
%   the input signal is sampled at 8 kHz, we can obtain the same filter by
%   specifying the frequencies in Hz as:
%   D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',...
%          1600,2000,2400,2800,60,1,80,8000);
%   H = design(D,'equiripple'); 
%
%   D = FDESIGN.BANDPASS(...,MAGUNITS) specifies the units for any
%   magnitude specification given. MAGUNITS can be one of the following:
%   'linear', 'dB', or 'squared'. If this argument is omitted, 'dB' is
%   assumed. Note that the magnitude specifications are always converted
%   and stored in dB regardless of how they were specified. If Fs is
%   provided, MAGUNITS must be provided after Fs in the input argument
%   list.
%   
%   The full list of possible values for SPECSTRING (not case sensitive)
%   is:
%      'Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2' (minimum order; default)
%      'N,F3dB1,F3dB2'       
%      'N,F3dB1,F3dB2,Ap' (*)              
%      'N,F3dB1,F3dB2,Ast' (*)
%      'N,F3dB1,F3dB2,BWp' (*)
%      'N,F3dB1,F3dB2,BWst' (*)
%      'N,F3dB1,F3dB2,Ast1,Ap,Ast2' (*)
%      'N,Fc1,Fc2'
%      'N,Fc1,Fc2,Ast1,Ap,Ast2' 
%      'N,Fp1,Fp2,Ap'
%      'N,Fp1,Fp2,Ast1,Ap,Ast2' 
%      'N,Fst1,Fp1,Fp2,Fst2'
%      'N,Fst1,Fp1,Fp2,Fst2,C' (*)
%      'N,Fst1,Fst2,Ast'
%      'N,Fst1,Fp1,Fp2,Fst2,Ap' (*)
%      'Nb,Na,Fst1,Fp1,Fp2,Fst2' (*)
%
%  where 
%      Ap    - Passband Ripple (dB)
%      Ast   - Stopbands Attenuation (dB)
%      Ast1  - First Stopband Attenuation (dB)
%      Ast2  - Second Stopband Attenuation (dB)
%      BWp   - Passband Frequency Width
%      BWst  - Stopband Frequency Width
%      F3dB1 - First 3dB Frequency
%      F3dB2 - Second 3dB Frequency
%      Fc1   - First Cutoff Frequency
%      Fc2   - Second Cutoff Frequency
%      Fp1   - First Passband Frequency
%      Fp2   - Second Passband Frequency
%      Fst1  - First Stopband Frequency
%      Fst2  - Second Stopband Frequency
%      N     - Filter Order
%      Nb    - Numerator Order
%      Na    - Denominator Order
%      C     - Constrained Band Flag
%
%   D = FDESIGN.BANDPASS(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass,
%   Astop2) uses the default SPEC ('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2')
%   and sets the lower stopband-edge frequency, the lower passband-edge
%   frequency, the upper passband-edge frequency, the upper stopband-edge
%   frequency, the lower stopband attenuation, the passband ripple, and the
%   upper stopband attenuation.
%
%   % Example #1 - Design a minimum order elliptic bandpass filter.
%   d = fdesign.bandpass(.3, .4, .6, .7, 80, .5, 60);
%   Hd = design(d, 'ellip');
%   info(Hd)
%
%   % Example #2 - Design an FIR least-squares bandpass filter.
%   d = fdesign.bandpass('N,Fst1,Fp1,Fp2,Fst2',100,.3, .4, .6, .7);
%   Hd = design(d, 'firls','wstop1',100,'wpass',1,'wstop2',1);
%   fvtool(Hd)
%
%   % Example #3 - Specify frequencies in Hz.
%   d = fdesign.bandpass('N,Fp1,Fp2,Ap', 10, 9600, 14400, .5, 48000);
%   designmethods(d);
%   Hd = design(d, 'cheby1');
%
%   % Example #4 - Specify the magnitude specifications in squared units
%   d = fdesign.bandpass(.4, .5, .6, .7, .02, .98, .01, 'squared');
%   Hd = design(d, 'cheby2');
%   fvtool(Hd,'MagnitudeDisplay','Magnitude Squared');
%
%   % Example #5 - Design a constrained band equiripple bandpass filter (*)
%   d = fdesign.bandpass('N,Fst1,Fp1,Fp2,Fst2,C',60,0.3,0.4,0.7,0.8);
%   % Set constraints for the attenuation in the stopbands
%   d.Stopband1Constrained = true;
%   d.Astop1 = 60;
%   d.Stopband2Constrained = true;
%   d.Astop2 = 70;
%   Hd = design(d,'equiripple');
%   fvtool(Hd);
%
%  % (*) DSP System Toolbox required
%
%   See also FDESIGN, FDESIGN/SETSPECS, FDESIGN/DESIGN, FDESIGN/DESIGNOPTS.

%   Copyright 2004-2015 The MathWorks, Inc.

%fdesign.bandpass class
%   fdesign.bandpass extends fdesign.abstracttypewspecs.
%
%    fdesign.bandpass properties:
%       Response - Property is of type 'ustring' (read only) 
%       Description - Property is of type 'string vector' (read only) 
%       Specification - Property is of type 'bandpassSpecTypeswFDTbx enumeration: {'Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2','N,F3dB1,F3dB2','N,F3dB1,F3dB2,Ap','N,F3dB1,F3dB2,Ast','N,F3dB1,F3dB2,Ast1,Ap,Ast2','N,F3dB1,F3dB2,BWp','N,F3dB1,F3dB2,BWst','N,Fc1,Fc2','N,Fc1,Fc2,Ast1,Ap,Ast2','N,Fp1,Fp2,Ap','N,Fp1,Fp2,Ast1,Ap,Ast2','N,Fst1,Fp1,Fp2,Fst2','N,Fst1,Fp1,Fp2,Fst2,C','N,Fst1,Fp1,Fp2,Fst2,Ap','N,Fst1,Fst2,Ast','Nb,Na,Fst1,Fp1,Fp2,Fst2'}'  
%
%    fdesign.bandpass methods:
%       disp - Display the design object.
%       getconstructor - Return the constructor for the specification type.
%       getfdatooltypes - Get the fdatooltypes.
%       getmask - Get the mask.
%       getmeasureconstructor - Get the measureconstructor.
%       getmeasurementfields - Get the measurementfields.
%       getmultiratespectypes - Get the multiratespectypes.
%       getspeclist - Get list of spec strings
%       isspecmet -   True if the object's specification has been met by the filter.
%       setcurrentspecs - Pre-Set function for the current specs.
%       sosreorder -   Reorder SOS filter.
%       thispassbandzoom - Returns the limits of the passband zoom.


properties (Access=protected, AbortSet, SetObservable, GetObservable)
  %CONSTRAINTLISTENER Property is of type 'handle.listener vector'
  ConstraintListener = [];
end

properties (SetObservable, GetObservable)
  %SPECIFICATION Specification String
  %  Set specification string as one of:
  %    'Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2'
  %    'N,F3dB1,F3dB2'
  %    'N,F3dB1,F3dB2,Ap'
  %    'N,F3dB1,F3dB2,Ast'
  %    'N,F3dB1,F3dB2,Ast1,Ap,Ast2'
  %    'N,F3dB1,F3dB2,BWp'
  %    'N,F3dB1,F3dB2,BWst'
  %    'N,Fc1,Fc2'
  %    'N,Fc1,Fc2,Ast1,Ap,Ast2'
  %    'N,Fp1,Fp2,Ap'
  %    'N,Fp1,Fp2,Ast1,Ap,Ast2'
  %    'N,Fst1,Fp1,Fp2,Fst2'
  %    'N,Fst1,Fp1,Fp2,Fst2,C'
  %    'N,Fst1,Fp1,Fp2,Fst2,Ap'
  %    'N,Fst1,Fst2,Ast'
  %    'Nb,Na,Fst1,Fp1,Fp2,Fst2'
  %  The default is 'Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2'
  Specification 
end


methods  % constructor block
  function this = bandpass(varargin)

  % this = fdesign.bandpass;

  [varargin,flag] = finddesignfiltflag(this,varargin);

  this.Response = 'Bandpass';

  if flag 
    specObj = this.getcurrentspecs;
    specObj.FromDesignfilt = true;
  end

  this.Specification = 'Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2';

  this.setspecs(varargin{:});

  capture(this);


  end  % bandpass

end  % constructor block

methods 
  function value = get.Specification(obj)
  value = get_specification(obj,obj.Specification);
  end
  %--------------------------------------------------------------------------  
  function set.Specification(obj,value)
  value = validatestring(value,getAllowedStringValues(obj,'Specification'),'','Specification');
  obj.Specification = set_specification(obj,value);
  end
  %--------------------------------------------------------------------------  
  function set.ConstraintListener(obj,value)
      % DataType = 'handle.listener vector'
  validateattributes(value,{'event.proplistener'}, {'vector'},'','ConstraintListener')
  obj.ConstraintListener = value;
  end
end   % set and get functions 

methods
  function vals = getAllowedStringValues(obj,prop)
    if strcmp(prop,'Specification')
      [SPTList, DSTList] = fdesign.bandpass.getspeclist;
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
    propList = reorderstructure(propList,'Response','Specification','Description',cpropList{:});
    
    if isfield(propList,'Stopband1Constrained')
      propNames = {'Response', 'Specification', 'Description',...
      'NormalizedFrequency','Fs','FilterOrder','Fstop1','Fpass1',...
      'Fpass2','Fstop2'};
  
      propNames{end+1} = 'Stopband1Constrained';
      if obj.Stopband1Constrained
        propNames{end+1} = 'Astop1';
      end
      propNames{end+1} = 'PassbandConstrained';
      if obj.PassbandConstrained
        propNames{end+1} = 'Apass';
      end  
      propNames{end+1} = 'Stopband2Constrained';
      if obj.Stopband2Constrained
        propNames{end+1} = 'Astop2';
      end
      
      propList = reorderstructure(propList, propNames{:});
    end

    if propList.NormalizedFrequency
      propList = rmfield(propList, 'Fs');
    end
    
    propgrp = matlab.mixin.util.PropertyGroup(propList);
  
  end
end
    
methods  % public methods
  cSpecCon = getconstructor(this,stype)
  t = getfdatooltypes(~)
  [F,A] = getmask(this,fcns,~,specs)
  measureconstructor = getmeasureconstructor(~)
  measurementfields = getmeasurementfields(~)
  multiratespectypes = getmultiratespectypes(~)
  b = isspecmet(this,Hd)
  newspecs = setcurrentspecs(this,newspecs)
  sosreorder(this,Hd)
  [xlim,ylim] = thispassbandzoom(this,fcns,Hd,~)
end  % public methods 


methods (Hidden) % possibly private or hidden
  checkoutfdtbxlicense(~)
end  % possibly private or hidden 


methods (Static) % static methods
  [specListSPT,specListDST] = getspeclist()
end  % static methods 

end  % classdef

% [EOF]
