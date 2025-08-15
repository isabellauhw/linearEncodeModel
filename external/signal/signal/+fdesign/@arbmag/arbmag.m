classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) arbmag < fdesign.abstractarbresponse & dynamicprops 
%ARBMAG   Arbitrary Magnitude filter designer.
%   D = FDESIGN.ARBMAG constructs an arbitrary magnitude filter designer D.
%
%   D = FDESIGN.ARBMAG(SPEC) initializes the filter designer
%   'Specification' property to SPEC. SPEC is one of the following strings
%   and is not case sensitive:
%
%       'N,F,A'       - Single-band design (default)
%       'F,A,R'       - Single-band minimum order design (*)
%       'N,B,F,A'     - Multi-band design 
%       'N,B,F,A,C'   - Constrained multi-band design (*) 
%       'B,F,A,R'     - Multi-band minimum order design (*)
%       'Nb,Na,F,A'   - Single-band design (*)
%       'Nb,Na,B,F,A' - Multi-band design (*)
%
%  where 
%       A  - Amplitude Vector
%       B  - Number of Bands
%       C  - Constrained Band Flag
%       F  - Frequency Vector
%       N  - Filter Order
%       Nb - Numerator Order
%       Na - Denominator Order
%       R  - Ripple
%
%   By default, all frequency specifications are assumed to be in
%   normalized frequency units. 
%   
%   The amplitude and ripple values must be in linear scale.
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS(D) to get a list of design methods
%   available for a given SPEC.
%
%   D = FDESIGN.ARBMAG(SPEC, SPEC1, SPEC2, ...) initializes the filter
%   designer specifications with SPEC1, SPEC2, etc. 
%   Use GET(D, 'DESCRIPTION') for a description of SPEC1, SPEC2, etc.
%
%   D = FDESIGN.ARBMAG(N, F, A) uses the  default SPEC ('N,F,A') and
%   sets the order, the frequency vector, and the amplitude vector.
%
%   D = FDESIGN.ARBMAG(...,Fs) specifies the sampling frequency (in Hz).
%   In this case, all other frequency specifications are also in Hz.
%
%   % Example #1 - Design a single-band linear phase arbitrary-magnitude FIR
%   %              filter.
%   N = 120;
%   F = linspace(0,1,100);    
%   As = ones(1,100)-F*0.2;
%   Absorb = [ones(1,30),(1-0.6*bohmanwin(10))',...
%             ones(1,5), (1-0.5*bohmanwin(8))',ones(1,47)];
%   A = As.*Absorb; % Optical Absorption of Atomic Rubidium87 Vapor
%   d = fdesign.arbmag(N,F,A);
%   Hd = design(d);
%   fvtool(Hd)
%
%   % Example #2 - Design a single-band arbitrary-magnitude IIR filter. (*)
%   Nb = 12; Na = 10;
%   d  = fdesign.arbmag('Nb,Na,F,A',Nb,Na,F,A);
%   Hd = design(d);
%   fvtool(Hd)
%
%   % Example #3 -  Design a multiband minimum order filter with notches at
%   %               0.25*pi and 0.55*pi rad/sample. (*)
%   d = fdesign.arbmag('B,F,A,R');
%   d.NBands = 5;
%   d.B1Frequencies = [0 0.2];
%   d.B1Amplitudes = [1 1];
%   d.B1Ripple = 0.25;
%   d.B2Frequencies = 0.25; 
%   d.B2Amplitudes = 0;
%   d.B3Frequencies = [0.3 0.5];
%   d.B3Amplitudes = [1 1];
%   d.B3Ripple = 0.25;
%   d.B4Frequencies = 0.55; 
%   d.B4Amplitudes = 0;
%   d.B5Frequencies = [0.6 1];
%   d.B5Amplitudes = [1 1];
%   d.B5Ripple = 0.25;
%   Hd = design(d,'equiripple');
%   fvtool(Hd)
%
%   % Example #4 - Design a multi-band constrained arbitrary-magnitude FIR 
%   %              filter. Force frequency point at 0.15*pi rad/sample to 
%   %              0 dB. (*) 
%   d = fdesign.arbmag('N,B,F,A,C',82,2);
%   d.B1Frequencies = [0 0.06 .1];
%   d.B1Amplitudes = [0 0 0];
%   d.B2Frequencies = [.15 1];
%   d.B2Amplitudes = [1 1];
%   % Design a filter with no constraints 
%   Hd1 = design(d,'equiripple','B2ForcedFrequencyPoints',0.15);
%   % Add a constraint to the first band to increase attenuation
%   d.B1Constrained = true;
%   d.B1Ripple = .001;
%   Hd2 =  design(d,'equiripple','B2ForcedFrequencyPoints',0.15);
%   fvtool(Hd1,Hd2,'Legend','on')
%
%   For more information, see the Arbitrary Magnitude Demo(*). 
%
%   (*) DSP System Toolbox required
%
%   See also FDESIGN, FDESIGN/SETSPECS, FDESIGN/DESIGN.

%   Copyright 2004-2015 The MathWorks, Inc.
  
%fdesign.arbmag class
%   fdesign.arbmag extends fdesign.abstractarbresponse.
%
%    fdesign.arbmag properties:
%       Response - Property is of type 'ustring' (read only) 
%       Description - Property is of type 'string vector' (read only) 
%       Specification - Property is of type 'arbmagSpecTypeswFDTbx enumeration: {'N,F,A','F,A,R','Nb,Na,F,A','N,B,F,A','N,B,F,A,C','B,F,A,R','Nb,Na,B,F,A'}'  
%
%    fdesign.arbmag methods:
%       disp - Display the design object.
%       getconstructor - Get the constructor.
%       getdefaultmethod - Get the defaultmethod.
%       getmask - Get the mask.
%       getmeasureconstructor - Get the measureconstructor.
%       getmultiratespectypes - Get the multiratespectypes.
%       getspeclist - Get list of spec strings
%       sosreorder -   Reorder SOS filter.


properties (SetObservable, GetObservable)
  %SPECIFICATION Specification String
  %  Set specification string as one of:
  %    'N,F,A'
  %    'F,A,R'
  %    'Nb,Na,F,A'
  %    'N,B,F,A'
  %    'N,B,F,A,C'
  %    'B,F,A,R'
  %    'Nb,Na,B,F,A'
  %  The default is 'N,F,A'
  Specification
end


methods  % constructor block
  function this = arbmag(varargin)

  % this = fdesign.arbmag;

  [varargin,flag] = finddesignfiltflag(this,varargin);

  this.Response = 'Arbitrary Magnitude';

  if flag 
    specObj = this.getcurrentspecs;
    specObj.FromDesignfilt = true;
  end

  this.Specification = 'N,F,A'; 

  this.setspecs(varargin{:});

  capture(this);


  end  % arbmag

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
      [SPTList, DSTList] = fdesign.arbmag.getspeclist;
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
     
    if isfield(propList,'Ripple')
      ripple = obj.Ripple;
      propList = rmfield(propList,'Ripple');
      propList.Ripple = ripple;
    elseif isfield(propList,'B1Constrained')
      propNames = {'Response', 'Specification', 'Description',...
        'NormalizedFrequency','Fs','FilterOrder','NBands'};
      for idx = 1:obj.NBands
        newCell = {sprintf('%s%d%s','B',idx,'Frequencies')...
          sprintf('%s%d%s','B',idx,'Amplitudes'),...
          sprintf('%s%d%s','B',idx,'Constrained')};
        if obj.(sprintf('%s%d%s','B',idx,'Constrained'))
          newCell = [newCell {sprintf('%s%d%s','B',idx,'Ripple')}]; %#ok<*AGROW>
        end
        propNames = [propNames newCell];
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
  defaultmethod = getdefaultmethod(this)
  [F,A] = getmask(this,fcns,~,~)
  measureconstructor = getmeasureconstructor(~)
  multiratespectypes = getmultiratespectypes(~)
  sosreorder(this,Hd)
end  % public methods 


methods (Hidden) % possibly private or hidden
  checkoutfdtbxlicense(~)
end  % possibly private or hidden 


methods (Static) % static methods
  [specListSPT,specListDST] = getspeclist()
end  % static methods 

end  % classdef


% [EOF]
