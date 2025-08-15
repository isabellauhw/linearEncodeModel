classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) hilbert < fdesign.abstracttypewspecs & dynamicprops
%HILBERT   Construct a Hilbert filter designer.
%   D = FDESIGN.HILBERT constructs a Hilbert filter designer D.
%
%   D = FDESIGN.HILBERT(SPEC) initializes the filter designer
%   'Specification' property to SPEC.  SPEC is one of the following
%   strings and is not case sensitive:
%
%       'N,TW'  - (default)
%       'TW,Ap' - Minimum order (*)
%
%   Different specification may have different design methods available.
%   Use DESIGNMETHODS(D) to get a list of design methods available for a
%   given SPEC.
%
%   D = FDESIGN.HILBERT(SPEC, SPEC1, SPEC2, ...) initializes the filter
%   designer specifications with SPEC1, SPEC2, etc...
%   Use GET(D, 'DESCRIPTION') for a description of SPEC1, SPEC2, etc.
%
%   D = FDESIGN.HILBERT(...,Fs) specifies the sampling frequency
%   (in Hz). In this case, all other frequency specifications are also in
%   Hz.
%
%   D = FDESIGN.HILBERT(...,MAGUNITS) specifies the units for any
%   magnitude specification given in the constructor. MAGUNITS can be one
%   of the following: 'linear', 'dB', or 'squared'. If this argument is
%   omitted, 'dB' is assumed. Note that the magnitude specifications are
%   always converted and stored in dB regardless of how they were
%   specified.
%
%   % Example #1 - Design a 30th order type III Hilbert Transformer.
%   d = fdesign.hilbert(30,.2);
%   designmethods(d);
%   Hd = design(d,'firls'); 
%   fvtool(Hd,'MagnitudeDisplay','Zero-phase','FrequencyRange','[-pi, pi)')
%
%   % Example #2 - Design a 35th order type IV Hilbert Transformer.
%   d = fdesign.hilbert('N,TW',35,.1);
%   Hd = design(d,'equiripple'); 
%   fvtool(Hd,'MagnitudeDisplay','Zero-phase','FrequencyRange','[-pi, pi)')
%
%   % Example #3 - Design a minimum-order Hilbert Transformer with a
%   % sampling frequency of 100, compare two IIR designs. (*)
%   d = fdesign.hilbert('TW,Ap',1,.1,100);
%   H(1) = design(d,'iirlinphase');
%   H(2) = design(d,'ellip');
%   hfvt = fvtool(H); legend(hfvt,'Linear phase IIR','Elliptic IIR')
%
%   %(*) DSP System Toolbox required
%
%   See also FDESIGN, FDESIGN/SETSPECS, FDESIGN/DESIGN.

%   Copyright 2004-2015 The MathWorks, Inc.

%fdesign.hilbert class
%   fdesign.hilbert extends fdesign.abstracttypewspecs.
%
%    fdesign.hilbert properties:
%       Response - Property is of type 'ustring' (read only) 
%       Description - Property is of type 'string vector' (read only) 
%       Specification - Property is of type 'firHilbertTransformerSpecTypeswFDTbx enumeration: {'N,TW','TW,Ap'}'  
%
%    fdesign.hilbert methods:
%       getconstructor -   Return the constructor for the specification type.
%       getmask -   Get the mask.
%       getmeasureconstructor -   Get the measureconstructor.
%       getspeclist - Get list of spec strings


properties (SetObservable, GetObservable)
  %SPECIFICATION Property is of type 'firHilbertTransformerSpecTypeswFDTbx enumeration: {'N,TW','TW,Ap'}' 
  Specification 
end


methods  % constructor block
  function this = hilbert(varargin)

    % this = fdesign.hilbert;

    [varargin,flag] = finddesignfiltflag(this,varargin);

    this.Response = 'Hilbert Transformer';
    
    if flag 
      specObj = this.getcurrentspecs;
      specObj.FromDesignfilt = true;
    end

    this.Specification = 'N,TW';
    
    this.setspecs(varargin{:});

    capture(this);



  end  % hilbert

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
        [SPTList, DSTList] = fdesign.hilbert.getspeclist;
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
  [F,A] = getmask(this,fcns,rcf,specs)
  measureconstructor = getmeasureconstructor(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  checkoutfdtbxlicense(this)
  b = haspassbandzoom(this)
end  % possibly private or hidden 


methods (Static) % static methods
  [specListSPT,specListDST] = getspeclist()
end  % static methods 

end  % classdef


% [EOF]
