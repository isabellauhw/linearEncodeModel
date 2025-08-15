classdef (Abstract) abstracttypewspecs < fdesign.abstracttype & matlab.mixin.CustomDisplay & matlab.mixin.Heterogeneous 
%ABSTRACTTYPEWSPECS Abstract constructor produces an error.

%   Copyright 2004-2015 The MathWorks, Inc.  
  
%fdesign.abstracttypewspecs class
%   fdesign.abstracttypewspecs extends fdesign.abstracttype.
%
%    fdesign.abstracttypewspecs properties:
%       Response - Property is of type 'ustring' (read only) 
%       Description - Property is of type 'string vector' (read only) 
%
%    fdesign.abstracttypewspecs methods:
%       abstract_setspecs -   Set all the specs.
%       capture -   Capture the state of the object.
%       copy -   Copy the designer.
%       designoptions - Return the design options.
%       designopts -   Return information about the design options.
%       disp -   Display the design object.
%       get_specification -   PreGet function for the 'Specification' property.
%       getcurrentspecs - Get the currentspecs.
%       getdescription -   PreGet function for the description.
%       getdesignpanelstate -   Get the designpanelstate.
%       getfmethod -   Get the fmethod.
%       getmeasurements -   Get the measurements.
%       getmultiratespectypes -   Get the multiratespectypes.
%       getspecs -   Get the specs.
%       help -   Provide help for the specified design method.
%       hiddenmethods -   Return the hidden methods.
%       isdesignmethod -   Returns true if the method is a valid designmethod.
%       isequivalent -   True if the object is equivalent.
%       loadobj -   Load this object
%       measureinfo -   Return a structure of information for the measurements.
%       normalizefreq -  Normalize frequency specifications. 
%       propstoadd -   Return the properties to add to the parent object.
%       reset -   Reset the object.
%       saveobj -   Save this object.
%       set_specification -   Pre-Set Function for the 'Specification' property.
%       setcurrentspecs -   Pre-Set function for the current specs.
%       setspecs -   Set the specs.
%       syncspecs - Sync specs from the current specs to a new specs object.
%       thiscopy -   Copy this object.
%       thisdesign -   Design the filter.
%       thisdesignmethods -   Return the valid design methods.
%       thisloadobj -   Load this object.
%       thissaveobj -   Save this object
%       updatecurrentspecs -   Update the currentSpecs object.
%       validstructures -   Return the valid structures


properties (AbortSet, SetObservable, GetObservable, Hidden)
  %SPECIFICATIONTYPE Property is of type 'ustring' (hidden)
  SpecificationType
end

properties (Access=protected, SetObservable, GetObservable, AbortSet) 
  %CURRENTSPECS Property is of type 'fspecs.abstractspec'
  CurrentSpecs = [];
  %CAPTUREDSTATE Property is of type 'mxArray'
  CapturedState = [];
  %ALLSPECS Property is of type 'fspecs.abstractspec vector'
  AllSpecs = [];
  %PRIVSPECIFICATION Property is of type 'ustring'
  privSpecification
end

properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %RESPONSE Property is of type 'ustring' (read only)
  Response
  %DESCRIPTION Property is of type 'string vector' (read only)
  Description
end

properties (SetAccess=protected, AbortSet, SetObservable, GetObservable, Hidden)
  %RESPONSETYPE Property is of type 'ustring' (hidden)
  ResponseType
end


events 
  FaceChanged
  FaceChanging
end  % events

methods 
  function set.Response(obj,value)
      % DataType = 'ustring'
  validateattributes(value,{'char'}, {'vector'},'','Response')
  obj.Response = set_response(obj,value);
  end
  %------------------------------------------------------------------------
  function value = get.ResponseType(obj)
  value = get_responsetype(obj,obj.ResponseType);
  end
  %------------------------------------------------------------------------
  function set.ResponseType(obj,value)
      % DataType = 'ustring'
  validateattributes(value,{'char'}, {'vector'},'','ResponseType')
  obj.ResponseType = value;
  end
  %------------------------------------------------------------------------
  function set.CurrentSpecs(obj,value)
      % DataType = 'fspecs.abstractspec'
  if ~isempty(value) && ~(isa(value,'fspecs.abstractspec') && isscalar(value))
    validateattributes(value,{'fspecs.abstractspec'},...
      {'scalar'},'','CurrentSpecs');
  end
  obj.CurrentSpecs = setcurrentspecs(obj,value);
  end
  %------------------------------------------------------------------------
  function set.CapturedState(obj,value)
  obj.CapturedState = value;
  end
  %------------------------------------------------------------------------
  function set.AllSpecs(obj,value)
      % DataType = 'fspecs.abstractspec vector'
  if ~(isa(value,'fspecs.abstractspec') && isvector(value))
    validateattributes(value,{'fspecs.abstractspec'}, ...
      {'vector'},'','AllSpecs')
  end
  obj.AllSpecs = value;
  end
  %------------------------------------------------------------------------
  function value = get.Description(obj)
  value = getdescription(obj,obj.Description);
  end
  %------------------------------------------------------------------------
  function set.Description(obj,value)
      % DataType = 'string vector'
  % no cell string checks yet'
  obj.Description = value;
  end
  %------------------------------------------------------------------------
  function value = get.SpecificationType(obj)
  value = get_specificationtype(obj,obj.SpecificationType);
  end
  %------------------------------------------------------------------------
  function set.SpecificationType(obj,value)
      % DataType = 'ustring'
  validateattributes(value,{'char'}, {'vector'},'','SpecificationType')
  obj.SpecificationType = set_specificationtype(obj,value);
  end
  %------------------------------------------------------------------------
  function set.privSpecification(obj,value)
      %DataType = 'ustring'
  validateattributes(value,{'char'}, {'vector'},'','privSpecification')
  obj.privSpecification = value;
  end

end   % set and get functions 
    
methods 
  function h = copy(this)
    %COPY   Copy the designer.

    h = feval(class(this));

    p = propstocopy(this);
    for indx = 1:length(p)
        h.(p{indx}) = this.(p{indx});
    end

    thiscopy(h, this);

    % Make sure that we use the old specs
    h.AllSpecs = copy(this.AllSpecs);

    % Empty out the current specifications so that SYNCSPECS does not change
    % our copied specs.
    h.CurrentSpecs = []; 

    if strcmpi(this.SpecificationType, h.Specification)
        updatecurrentspecs(h);    
    else
        h.Specification = this.SpecificationType;
    end    
    
    % Copy the MaskScalingFactor property if exists
    if isprop(this,'MaskScalingFactor')
      h.MaskScalingFactor = this.MaskScalingFactor;
    end
       
  end
end
    
methods  % public methods
  abstract_setspecs(this,varargin)
  capture(this)
  dopts = designoptions(this,method,varargin)
  s = designopts(this,designmethod,sigonlyflag)  
  specification = get_specification(this,specification)
  currentspecs = getcurrentspecs(this)
  description = getdescription(this,description)
  s = getdesignpanelstate(this,hfm)
  hfmethod = getfmethod(this,methodname)
  m = getmeasurements(this,varargin)
  multiratespectypes = getmultiratespectypes(this)
  specs = getspecs(this)
  help(this,designmethod)
  m = hiddenmethods(this)
  b = isdesignmethod(this,method)
  b = isequivalent(this,htest)
  minfo = measureinfo(this)
  normalizefreq(this,varargin)
  p = propstoadd(this)
  reset(this)
  s = saveobj(this)
  specification = set_specification(this,specification)
  newspecs = setcurrentspecs(this,newspecs)
  setspecs(this,varargin)
  syncspecs(this,newspecs)
  thiscopy(this,hOldObject)
  varargout = thisdesign(this,method,varargin)
  [d,isfull,type] = thisdesignmethods(this,varargin)
  thisloadobj(this,s)
  s = thissaveobj(this)
  updatecurrentspecs(this)
  v = validstructures(this,varargin)
end  % public methods 


methods (Hidden) % possibly private or hidden
    varargout = currentfdesigndesignmethods(this,varargin)
    multiratedefaults(this,maxfactor)
    staticresponse(this,hax,magunits)
end  % possibly private or hidden 


methods (Static) % static methods
    this = loadobj(this,s)
end  % static methods 

methods %set/get
  function varargout = set(obj,varargin)
    [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});
  end
  %------------------------------------------------------------------------
  function varargout = get(obj,varargin)
    [varargout{1:nargout}] = signal.internal.signalget(obj,varargin{:});
  end
end %set/get

end  % classdef

function rtype = get_responsetype(this, ~)

rtype = this.Response;
end  % get_responsetype


% -------------------------------------------------------------------------
function stype = get_specificationtype(this, ~)

stype = this.Specification;
end  % get_specificationtype


% -------------------------------------------------------------------------
function stype = set_specificationtype(this, stype)

this.Specification = stype;
end  % set_specificationtype


% -------------------------------------------------------------------------
function str = set_response(~, str)

if ~isdeployed
    if ~license('checkout','Signal_Toolbox')
        error(message('signal:fdesign:abstracttypewspecs:schema:LicenseRequired'));
    end
end
end  % set_response


% [EOF]
