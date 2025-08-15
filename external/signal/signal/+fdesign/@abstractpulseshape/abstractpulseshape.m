classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, Abstract) abstractpulseshape < fdesign.abstracttypewspecs & dynamicprops
%ABSTRACTPULSESHAPE Abstract constructor produces an error.

%   Copyright 2004-2015 The MathWorks, Inc.
  
%fdesign.abstractpulseshape class
%   fdesign.abstractpulseshape extends fdesign.abstracttypewspecs.
%
%    fdesign.abstractpulseshape properties:
%       Response - Property is of type 'ustring' (read only) 
%       Description - Property is of type 'string vector' (read only) 
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%
%    fdesign.abstractpulseshape methods:
%       design - Design the pulse shaping filter object.
%       disp -   Display the design object.
%       get_samplespersymbol - PreGet function for the 'SamplesPerSymbol' property
%       getmask -   Get the mask.
%       getmeasureconstructor - Get the measureconstructor.
%       propstoadd -   Return the properties to add to the parent object.
%       propstocopy -   Returns the properties to copy.
%       set_samplespersymbol - PreSet function for the 'SamplesPerSymbol' property
%       setspecs - Set the specs
%       thisloadobj -   Load this object.
%       thissaveobj -   Save this object.


properties (AbortSet, SetObservable, GetObservable)
  %SAMPLESPERSYMBOL Property is of type 'posint user-defined' 
  SamplesPerSymbol = [];
end

properties (Access=protected, AbortSet, SetObservable, GetObservable)
  %PRIVSAMPLESPERSYMBOL Property is of type 'posint user-defined'
  privSamplesPerSymbol = 8; 
end


methods 
  function set.privSamplesPerSymbol(obj,value)
  % User-defined DataType = 'posint user-defined'
  obj.privSamplesPerSymbol = value;
  end
  %------------------------------------------------------------------------
  function value = get.SamplesPerSymbol(obj)
  value = get_samplespersymbol(obj,obj.SamplesPerSymbol);
  end
  %------------------------------------------------------------------------
  function set.SamplesPerSymbol(obj,value)
  % User-defined DataType = 'posint user-defined'
  validateattributes(value,{'numeric'},{'integer','positive','scalar'}...
  ,'','SamplesPerSymbol')
  obj.SamplesPerSymbol = set_samplespersymbol(obj,value);
  end

end   % set and get functions 

methods (Access = protected)
  %This function defines the display behavior for the class
  %using matlab.mixin.util.CustomDisplay
  function propgrp = getPropertyGroups(obj)
    propList = get(obj);
    cpropList = propstoadd(obj.CurrentSpecs);
    propList = reorderstructure(propList,'Response', 'SamplesPerSymbol', ...
    'Specification', 'Description',cpropList{:});
    if propList.NormalizedFrequency 
      propList = rmfield(propList, 'Fs');
    end
    propgrp = matlab.mixin.util.PropertyGroup(propList);
  end
end

methods  % public methods
  varargout = design(this,varargin)
  samplesPerSymbol = get_samplespersymbol(this,samplesPerSymbol)
  [F,A] = getmask(this,fcns,rcf,specs)
  measureconstructor = getmeasureconstructor(this)
  p = propstoadd(this)
  p = propstocopy(this)
  samplesPerSymbol = set_samplespersymbol(this,samplesPerSymbol)
  setspecs(this,sps,varargin)
  thisloadobj(this,s)
  s = thissaveobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  checkoutfdtbxlicense(this)
  multiratedefaults(this,maxfactor)
end  % possibly private or hidden 

end  % classdef

