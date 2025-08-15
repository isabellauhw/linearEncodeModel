classdef (Abstract) abstractdesign < matlab.mixin.SetGet & matlab.mixin.Copyable & dynamicprops
%ABSTRACTDESIGN   Construct an ABSTRACTDESIGN object.

%   Copyright 1999-2018 The MathWorks, Inc.
  
%fmethod.abstractdesign class
%    fmethod.abstractdesign properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.abstractdesign methods:
%       addsysobjdesignopt - Add SystemObject design option if it applies
%       design -   Design the filter and return an object.
%       designcoeffs -   Design the filter and return the coeffs.
%       designopts - Abstract method.
%       determineiirhalfbandfiltstruct - Determine appropriate structure for
%       getdesignoptstostring - Get field names and values that we want displayed by
%       getexamples -   Get the examples.
%       getsysobjsupportedstructs - List of structures supported by System objects
%       getvalidsysobjstructures - Get valid System object structures for the
%       help -   Provide help from an FDESIGN perspective.
%       help_header -   Generic help.
%       iscoeffwloptimizable - True if the object is coeffwloptimizable
%       isconstrained -   True if the object is constrained.
%       isfir -   True if the object is fir.
%       isfromdesignfilt - True if dfilt object was designed usign designfilt function
%       ismultistage - Return true if design object is multistage
%       postprocessmask - - This will be overloaded.
%       preprocessspecs -   Preprocess the specification object.
%       reorderdesignoptsstruct - Abstract method.
%       searchmincoeffwl - SEACHMINCOEFFWL <short description>
%       set_structure -   PreSet function for the 'structure' property.
%       validate -   Perform algorithm specific spec. validation.


properties (AbortSet, SetObservable, GetObservable)
  %FILTERSTRUCTURE Property is of type 'ustring' 
  FilterStructure
end

properties (AbortSet, SetObservable, GetObservable, Hidden)
  %FROMFILTERDESIGNER Property is of type 'bool' (hidden)
  FromFilterDesigner = false;
  %FROMDESIGNFILT Property is of type 'bool' (hidden)
  FromDesignfilt = false;
end

properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %DESIGNALGORITHM Property is of type 'ustring' (read only)
  DesignAlgorithm
end


methods 
  function set.DesignAlgorithm(obj,value)
  validateattributes(value,{'char'}, {'vector'},'','DesignAlgorithm')
  obj.DesignAlgorithm = value;
  end
  %------------------------------------------------------------------------
  function value = get.FilterStructure(obj)
  value = get_structure(obj,obj.FilterStructure);
  end
  %------------------------------------------------------------------------
  function set.FilterStructure(obj,value)
  validateattributes(value,{'char'}, {'vector'},'','FilterStructure')
  obj.FilterStructure = set_structure(obj,value);
  end
  %------------------------------------------------------------------------
  function set.FromFilterDesigner(obj,value)
  validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','FromFilterDesigner')
  value = logical(value);
  obj.FromFilterDesigner = value;
  end
  %------------------------------------------------------------------------
  function set.FromDesignfilt(obj,value)
  validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','FromDesignfilt')
  value = logical(value);
  obj.FromDesignfilt = value;
  end

end   % set and get functions 

methods % overloaded public methods
  %This overloaded findprop is now case-insensitive for public properties
  % The property name 'SystemObject' was added here to prevent try/catch
  % errors when checking for this property, which occurs frequently.
  function mp = findprop(obj,property) 
    try
      nprop = validatestring(property,[fieldnames(obj); {'SystemObject'}]);
    catch
      nprop = property;
    end
    
    % Call the superclass (handle) findprop
    mp = findprop@handle(obj,nprop);
  end
  %------------------------------------------------------------------------
  function varargout = set(obj,varargin)
    [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});
  end
  %------------------------------------------------------------------------
%   function varargout = get(obj,varargin) jk
%     [varargout{1:nargout}] = signal.internal.signalget(obj,varargin{:});
%   end
  
end

methods
  %This is the default getAllowedStringValues, which returns an empty cell
  %array for all properties. It is overloaded in inherited classes which
  %have enumerated data types - the overloaded version returns
  %property lists for enumerated data types.
  function vals = getAllowedStringValues(obj,prop)
      vals = {};
  end
end

methods  % public methods
  thisSupportedStructs = addsysobjdesignopt(this)
  varargout = design(this,varargin)
  varargout = designcoeffs(this,specs,varargin)
  s = designopts(this,varargin)
  [filtstruct,mfiltstruct] = determineiirhalfbandfiltstruct(this,desmode,filtstruct)
  [s,fn] = getdesignoptstostring(this)
  examples = getexamples(this)
  s = getsysobjsupportedstructs(~)
  s = getvalidsysobjstructures(this)
  help(this)
  help_header(this,method,description,type)
  b = iscoeffwloptimizable(this)
  b = isconstrained(this)
  b = isfir(this)
  flag = isfromdesignfilt(this)
  flag = ismultistage(~)
  newmask = postprocessmask(this,oldmask,units)
  specs = preprocessspecs(this,specs)
  s = reorderdesignoptsstruct(~,s,varargin)
  Hbest = searchmincoeffwl(this,args,varargin)
  struct = set_structure(this,struct)
  validate(h,specs)
end  % public methods 


methods (Hidden) % possibly private or hidden
  Hd = createobj(this,coeffs)
  disp(this)
  help_densityfactor(this,dfactor)
  help_examples(this)
  help_weight(this,varargin)
  s = thisdesignopts(this,s)
  [sOut,fnOut] = thisgetdesignoptstostring(this,s,fn)
  str = tostring(this,varargin)
  function t = isequaln(a,b)
    %   This function is for internal use only. It may change in a future
    %   release.
    t = isequal(class(a), class(b)) && isequaln(get(a), get(b));
  end
end  % possibly private or hidden 

end  % classdef

