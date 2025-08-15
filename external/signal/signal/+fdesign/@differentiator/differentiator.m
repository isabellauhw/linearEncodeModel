classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) differentiator < fdesign.abstracttypewspecs & dynamicprops 
%DIFFERENTIATOR   Construct a differentiator filter designer.
%   D = FDESIGN.DIFFERENTIATOR constructs a differentiator filter designer D.
%
%   D = FDESIGN.DIFFERENTIATOR(SPEC) initializes the filter designer
%   'Specification' property to SPEC.  SPEC is one of the following
%   strings and is not case sensitive:
%
%       'N'             - Full band differentiator (default) 
%       'N,Fp,Fst'      - Partial band differentiator
%       'N,Fp,Fst,Ap'   - Partial band differentiator (*)
%       'N,Fp,Fst,Ast'  - Partial band differentiator (*)
%       'Ap'            - Minimum order full band differentiator (*)
%       'Fp,Fst,Ap,Ast' - Minimum order partial band differentiator (*)
%
%  where 
%       Ap    - Passband Ripple (dB)
%       Ast   - Stopband Attenuation (dB)
%       Fp    - Passband Frequency
%       Fst   - Stopband Frequency
%       N     - Filter Order
%
%   By default, all frequency specifications are assumed to be in
%   normalized frequency units. Moreover, all magnitude specifications are
%   assumed to be in dB.
% 
%   Different specification may have different design methods available.
%   Use DESIGNMETHODS(D) to get a list of design methods available for a
%   given SPEC.
%
%   D = FDESIGN.DIFFERENTIATOR(SPEC, SPEC1, SPEC2, ...) initializes the
%   filter designer specifications with SPEC1, SPEC2, etc.
%   Use GET(D,'DESCRIPTION') for a description of SPEC1, SPEC2, etc.
%
%   D = FDESIGN.DIFFERENTIATOR(N) uses the default SPEC ('N') and sets 
%   filter order. 
%
%   D = FDESIGN.DIFFERENTIATOR(...,Fs) specifies the sampling frequency
%   (in Hz). In this case, all other frequency specifications are also in
%   Hz.
%
%   D = FDESIGN.DIFFERENTIATOR(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1 - Design a 33rd order full band differentiator.
%   d = fdesign.differentiator(33);
%   designmethods(d);
%   Hd = design(d,'firls');
%   fvtool(Hd,'MagnitudeDisplay','Zero-phase','FrequencyRange','[-pi, pi)')
%
%   % Example #2 - Design a narrow band differentiator.
%   %              Differentiate the 25% lowest frequencies of the Nyquist 
%   %              range and filter the higher frequencies. 
%   d = fdesign.differentiator('N,Fp,Fst',54,.25,.3);
%   Hd = design(d,'equiripple'); 
%   % Weight the stopband to increase the stopband attenuation
%   Hd1 = design(d,'equiripple','Wstop',4); 
%   fvtool(Hd,Hd1,'MagnitudeDisplay','Zero-phase','FrequencyRange','[-pi, pi)','Legend','on')
%
%   % Example #3 - Design a minimum order wide band differentiator. (*)
%   d = fdesign.differentiator('Fp,Fst,Ap,Ast',.8,.9,1,80);
%   designmethods(d);
%   Hd = design(d,'equiripple'); 
%   fvtool(Hd,'MagnitudeDisplay','Zero-phase','FrequencyRange','[-pi, pi)')
%
%   %(*) DSP System Toolbox required
%
%   See also FDESIGN, FDESIGN/SETSPECS, FDESIGN/DESIGN.

%   Copyright 2004-2015 The MathWorks, Inc.

%fdesign.differentiator class
%   fdesign.differentiator extends fdesign.abstracttypewspecs.
%
%    fdesign.differentiator properties:
%       Response - Property is of type 'ustring' (read only) 
%       Description - Property is of type 'string vector' (read only) 
%       Specification - Property is of type 'firDifferentiatorSpecTypeswFDTbx enumeration: {'N','N,Fp,Fst','N,Fp,Fst,Ap','N,Fp,Fst,Ast','Ap','Fp,Fst,Ap,Ast'}'  
%
%    fdesign.differentiator methods:
%       getconstructor - Return the constructor for the specification type.
%       getmask - Get the mask.
%       getmeasureconstructor - Get the measureconstructor.
%       getspeclist - Get list of spec strings


properties (SetObservable, GetObservable)
  %SPECIFICATION Property is of type 'firDifferentiatorSpecTypeswFDTbx enumeration: {'N','N,Fp,Fst','N,Fp,Fst,Ap','N,Fp,Fst,Ast','Ap','Fp,Fst,Ap,Ast'}' 
  Specification 
end

properties (SetObservable, GetObservable, Hidden)
  %SPECIFICATION Property is of type 'firDifferentiatorSpecTypeswFDTbx enumeration: {'N','N,Fp,Fst','N,Fp,Fst,Ap','N,Fp,Fst,Ast','Ap','Fp,Fst,Ap,Ast'}' 
  MaskScalingFactor = 1; 
end

methods  % constructor block
  function this = differentiator(varargin)

  % this = fdesign.differentiator;

  [varargin,flag] = finddesignfiltflag(this,varargin);

  this.Response = 'Differentiator';

  if flag 
    specObj = this.getcurrentspecs;
    specObj.FromDesignfilt = true;
  end
  
  this.Specification = 'N';
  
  this.setspecs(varargin{:});

  capture(this);

  end  % differentiator

end  % constructor block

methods 
  function value = get.Specification(obj)
    value = get_specification(obj,obj.Specification);
  end
  function set.Specification(obj,value)
    value = validatestring(value,getAllowedStringValues(obj,'Specification'),'','Specification');
    obj.Specification = set_specification(obj,value);
  end

end   % set and get functions 

methods
    function vals = getAllowedStringValues(obj,prop)
      if strcmp(prop,'Specification')
        [SPTList, DSTList] = fdesign.differentiator.getspeclist;
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
    if propList.NormalizedFrequency 
      propList = rmfield(propList, 'Fs');
    end
    propgrp = matlab.mixin.util.PropertyGroup(propList);
  end
end

methods  % public methods
  cSpecCon = getconstructor(this,stype)
  [F,A] = getmask(this,fcns,~,specs)
  measureconstructor = getmeasureconstructor(~)
end  % public methods 


methods (Hidden) % possibly private or hidden
  checkoutfdtbxlicense(~)
  b = haspassbandzoom(~)
end  % possibly private or hidden 


methods (Static) % static methods
  [specListSPT,specListDST] = getspeclist()
end  % static methods 

end  % classdef

% [EOF]
