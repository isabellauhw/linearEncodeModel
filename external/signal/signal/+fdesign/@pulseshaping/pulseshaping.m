classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) pulseshaping < fdesign.abstracttype & dynamicprops & matlab.mixin.CustomDisplay
%PULSESHAPING   Construct a pulse shaping filter designer.
%
%   WARNING: fdesign.pulseshaping is not recommended. Use rcosdesign or
%            gaussdesign instead. 
%
%   D = FDESIGN.PULSESHAPING(SPS,SHAPE,SPECSTRING,VALUE1,VALUE2,...)
%   constructs a pulse shaping filter designer D. Note that D is not the design
%   itself, it only contains the design specifications. In order to design the
%   filter, one needs to invoke the DESIGN method on D.
%   For example (more examples below):
%   D = fdesign.pulseshaping(8,'Raised Cosine','Nsym,Beta',6,0.25);
%   H = design(D); % H is a DFILT
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
%   corresponding specification. In the example above, this means that Nsym =
%   6, Beta (Rolloff factor) = 0.25. Use get(D, 'description') for a
%   description of VALUE1, VALUE2, etc.
%
%   By default, all frequency specifications are assumed to be in
%   normalized frequency units. Moreover, all magnitude specifications are
%   assumed to be in dB.
%
%   D = FDESIGN.PULSESHAPING(...,Fs) provides the sampling frequency of the
%   signal to be filtered. Fs must be specified as a scalar trailing the
%   other numerical values provided. For this case, Fs is assumed to be in
%   Hz and used for analysis and visualization purposes.
%
%   D = FDESIGN.PULSESHAPING(...,MAGUNITS) specifies the units for any magnitude
%   specification given. MAGUNITS can be one of the following: 'linear', 'dB',
%   or 'squared'. If this argument is omitted, 'dB' is assumed. Note that the
%   magnitude specifications are always converted and stored in dB regardless of
%   how they were specified. If Fs is provided, MAGUNITS must be provided after
%   Fs in the input argument list.
%
%   The full list of possible values for SPECSTRING (not case sensitive)
%   is:
%       For PULSESHAPE 'Raised Cosine' and 'Square Root Raised Cosine':
%           'Ast,Beta' (minimum order; default)
%           'Nsym,Beta'
%           'N,Beta'
%       For PULSESHAPE 'Gaussian':
%           'Nsym,BT' (default)
%
%  where
%       Ast   - Stopband Attenuation (dB)
%       Beta  - Rolloff factor
%       Nsym  - Filter Order in symbols (must be even for raised cosine filters)
%       N     - Filter Order (must be even)
%       BT    - Bandwidth - Symbol Time product
%
%   D = FDESIGN.PULSESHAPING(sps, shape, Astop, Beta) uses the  default
%   SPECSTRING.
%
%   % Example #1 - Design a raised cosine windowed FIR filter with stop band
%   % attenuation of 60dB, rolloff factor of 0.50, and 8 samples
%   % per symbol.
%   h  = fdesign.pulseshaping(8,'Raised Cosine','Ast,Beta',60,0.50);
%   Hd = design(h);
%   fvtool(Hd)
%
%   % Example #2 - Design a raised cosine windowed FIR filter of order 8 symbols,
%   %  rolloff factor of 0.50, and 10 samples per symbol.
%   h  = fdesign.pulseshaping(10,'Raised Cosine','Nsym,Beta',8,0.50);
%   Hd = design(h);
%   fvtool(Hd)
%
%   % Example #3 - Design a square root raised cosine windowed FIR filter of order
%   % 42, rolloff factor of 0.25, and 10 samples per symbol.
%   h  = fdesign.pulseshaping(10,'Square Root Raised Cosine','N,Beta',42);
%   Hd = design(h);
%   fvtool(Hd)
%
%   % Example #4 - Design a Gaussian windowed FIR filter of order 3 symbols, 
%   % bandwidth-symbol time product of 0.4, and 10 samples per symbol.
%   h  = fdesign.pulseshaping(10,'Gaussian','Nsym,BT',3,0.4);
%   Hd = design(h);
%   fvtool(Hd)
%
%
%   See also FDESIGN, FDESIGN/SETSPECS, FDESIGN/DESIGN, FDESIGN/DESIGNOPTS.

%   Copyright 2004-2015 The MathWorks, Inc.
    
%fdesign.pulseshaping class
%   fdesign.pulseshaping extends fdesign.abstracttype.
%
%    fdesign.pulseshaping properties:
%       PulseShape - Property is of type 'PulseShapeType enumeration: {'Raised Cosine','Square Root Raised Cosine','Gaussian'}'  
%       Response - Property is of type 'ustring' (read only) 
%       SamplesPerSymbol - Property is of type 'posint user-defined'  
%       Description - Property is of type 'string vector'  
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%
%    fdesign.pulseshaping methods:
%       copy -   Copy the designer.
%       design - Design the pulseshaping object.
%       designmethods -   Returns a cell of design methods.
%       designoptions - Return the design options.
%       designopts -   Return information about the design options.
%       disp -   Display the design object.
%       getPSObj - Get the underlying pulse shaping object
%       getfmethod - Get the fmethod.
%       getmask -  Get the mask.
%       getmeasureconstructor - Get the measureconstructor.
%       getspecs - Get the specs.
%       help -   Provide help for the specified design method.
%       isequivalent -   True if the object is equivalent.
%       loadobj -   Load this object.
%       measureinfo -   Return a structure of information for the measurements.
%       normalizefreq -  Normalize frequency specifications. 
%       saveobj -   Save this object.
%       setspecs -   Set the specs.
%       thispassbandzoom - PASSBANDZOOM   Returns the limits of the passband zoom.
%       validstructures -   Return the valid structures


properties (AbortSet, SetObservable, GetObservable)
  %SAMPLESPERSYMBOL Property is of type 'posint user-defined' 
  SamplesPerSymbol = [];
  %DESCRIPTION Property is of type 'string vector' 
  Description
  %NORMALIZEDFREQUENCY Property is of type 'bool' 
  NormalizedFrequency
  %FS Property is of type 'mxArray' 
  Fs = [];
end

properties (AbortSet, SetObservable, GetObservable, Hidden)
  %PRIVPULSESHAPEOBJ Property is of type 'fdesign.abstracttype' (hidden)
  PrivPulseShapeObj = [];
  %PULSESHAPEOBJ Property is of type 'fdesign.abstracttype' (hidden)
  PulseShapeObj = [];
  %DYNAMICPROPS Property is of type 'mxArray' (hidden)
  DynamicProps = [];
end

properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %RESPONSE Property is of type 'ustring' (read only)
  Response = 'Pulse Shaping';
end

properties (SetObservable, GetObservable)
  %PULSESHAPE Property is of type 'PulseShapeType enumeration: {'Raised Cosine','Square Root Raised Cosine','Gaussian'}' 
  PulseShape 
end

properties (Transient, AbortSet, SetObservable, GetObservable, Hidden)
  %LISTENERS Property is of type 'handle.listener vector' (hidden)
  Listeners = [];
end


methods  % constructor block
  function this = pulseshaping(varargin)

    % this = fdesign.pulseshaping;

    if nargin > 0 && ~isnumeric(varargin{1})
      error(message('signal:fdesign:abstractpulseshape:setspecs:invalidInputSingleRate'));
    end

    if nargin < 2
        this.PulseShape = 'Raised Cosine';
    else
        this.PulseShape = varargin{2};
        varargin(2) = [];
    end

    setspecs(this.PulseShapeObj, varargin{:})


  end  % pulseshaping

end  % constructor block

methods 
  function value = get.PulseShape(obj)
  value = getPulseShape(obj,obj.PulseShape);
  end
  %------------------------------------------------------------------------
  function set.PulseShape(obj,value)
  value = validatestring(value,getAllowedStringValues(obj,'PulseShape'),'','PulseShape');
  obj.PulseShape = setPulseShape(obj,value);
  end
  %------------------------------------------------------------------------
  function set.Response(obj,value)
  validateattributes(value,{'char'}, {'vector'},'','Response')
  obj.Response = value;
  end
  %------------------------------------------------------------------------
  function value = get.SamplesPerSymbol(obj)
  value = getSamplesPerSymbol(obj,obj.SamplesPerSymbol);
  end
  %------------------------------------------------------------------------
  function set.SamplesPerSymbol(obj,value)
  % User-defined DataType = 'posint user-defined'
  validateattributes(value,{'numeric'},{'integer','positive','scalar'}...
  ,'','SamplesPerSymbol')
  obj.SamplesPerSymbol = setSamplesPerSymbol(obj,value);
  end
  %------------------------------------------------------------------------
  function value = get.Description(obj)
  value = getDescription(obj,obj.Description);
  end
  %------------------------------------------------------------------------
  function set.Description(obj,value)
  obj.Description = setDescription(obj,value);
  end
  %------------------------------------------------------------------------
  function value = get.NormalizedFrequency(obj)
  value = getNormalizedFrequency(obj,obj.NormalizedFrequency);
  end
  %------------------------------------------------------------------------
  function set.NormalizedFrequency(obj,value)
  validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},...
  '','NormalizedFrequency')
  value = logical(value);
  obj.NormalizedFrequency = setNormalizedFrequency(obj,value);
  end
  %------------------------------------------------------------------------
  function value = get.Fs(obj)
  value = getFs(obj,obj.Fs);
  end
  %------------------------------------------------------------------------
  function set.Fs(obj,value)
  obj.Fs = setFs(obj,value);
  end
  %------------------------------------------------------------------------
  function set.PrivPulseShapeObj(obj,value)
  if ~(isa(value,'fdesign.abstracttype') && isscalar(value))  
    validateattributes(value,{'fdesign.abstracttype'}, ...
      {'scalar'},'','PrivPulseShapeObj')
  end
  obj.PrivPulseShapeObj = value;
  end
  %------------------------------------------------------------------------
  function value = get.PulseShapeObj(obj)
  value = getPulseShapeObj(obj,obj.PulseShapeObj);
  end
  %------------------------------------------------------------------------
  function set.PulseShapeObj(obj,value)
  if ~(isa(value,'fdesign.abstracttype') && isscalar(value))
    validateattributes(value,{'fdesign.abstracttype'}, {'scalar'},'','PulseShapeObj')
  end
  obj.PulseShapeObj = setPulseShapeObj(obj,value);
  end
  %------------------------------------------------------------------------
  function set.DynamicProps(obj,value)
  obj.DynamicProps = value;
  end
  %------------------------------------------------------------------------
  function set.Listeners(obj,value)
      % DataType = 'handle.listener vector'
  if ~(isa(value,'event.proplistener') && isvector(value))
    validateattributes(value,{'event.proplistener'}, {'vector'},'','Listeners')
  end
  obj.Listeners = value;
  end

end   % set and get functions 

methods %set/get
  function varargout = set(obj,varargin)
    [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});
  end
  %------------------------------------------------------------------------
  function varargout = get(obj,varargin)
    [varargout{1:nargout}] = signal.internal.signalget(obj,varargin{:});
  end
end %set/get

methods
  function vals = getAllowedStringValues(obj,prop)
    if strcmp(prop,'PulseShape')
      vals = {'Raised Cosine',...
        'Square Root Raised Cosine',...
        'Gaussian'}';
    elseif strcmp(prop,'Specification')
      if strcmp(obj.PulseShape,'Raised Cosine') || strcmp(obj.PulseShape,'Square Root Raised Cosine')
        vals = {'Ast,Beta',...
          'Nsym,Beta',...
          'N,Beta'}';
      else
        vals = {'Nsym,BT'}';
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
    cpropList = propstoadd(obj.PulseShapeObj);
    propList = reorderstructure(propList,'Response', 'PulseShape', ...
      'SamplesPerSymbol', 'Specification', 'Description',cpropList{:});
    if propList.NormalizedFrequency 
      propList = rmfield(propList, 'Fs');
    end
    propgrp = matlab.mixin.util.PropertyGroup(propList);
  end
end

methods  % public methods
  h = copy(this)
  varargout = design(this,varargin)
  varargout = designmethods(this,varargin)
  dopts = designoptions(this,method,varargin)
  s = designopts(this,designmethod)
  pSObj = getPSObj(this)
  fmethod = getfmethod(this,methodname)
  [F,A] = getmask(this,varargin)
  measureconstructor = getmeasureconstructor(this)
  specs = getspecs(this)
  help(this,designmethod)
  b = isequivalent(this,htest)
  minfo = measureinfo(this)
  normalizefreq(this,varargin)
  s = saveobj(this)
  setspecs(this,varargin)
  [xlim,ylim] = thispassbandzoom(this,fcns,Hd,~)
  v = validstructures(this,varargin)
end  % public methods 


methods (Static) % static methods
  this = loadobj(s)
end  % static methods 

end  % classdef

function shape = setPulseShape(this, shape)

exp = sprintf('^%s',lower(shape));
if regexp('raised cosine', exp)
    this.PulseShapeObj = fdesign.rcosine;
elseif regexp('square root raised cosine', exp)
    this.PulseShapeObj = fdesign.sqrtrcosine;
elseif regexp('gaussian', exp)
    this.PulseShapeObj = fdesign.gaussian;
else
    this.PulseShapeObj = fdesign.rcosine;
    error(message('signal:fdesign:pulseshaping:schema:invalidShape'));
end

% Add the Specification property.  If one already exists, remove that and add a
% new one with the appropriate enum type
p = findprop(this, 'Specification');
if ~isempty(p)
    delete(p);
end
% Set the data type of the new property same as the data type of the underlying
% class' property.
adddynprop(this,'Specification',[], ... 
  @(~,val) setSpecification(this,val), @(~) getSpecification(this,[]));

end

%---------------------------------------------------------------------------
function value = getPulseShape(this, value)
if ~isempty(this.PulseShapeObj)
    value = this.PulseShapeObj.Response;
end
end
%---------------------------------------------------------------------------
function value = setSamplesPerSymbol(this, value)
this.PulseShapeObj.SamplesPerSymbol = value;
end
%---------------------------------------------------------------------------
function value = getSamplesPerSymbol(this, value)
value = this.PulseShapeObj.SamplesPerSymbol;
end
%---------------------------------------------------------------------------
function value = setSpecification(this, value)
value = validatestring(value,getAllowedStringValues(this,'Specification'),...
  '','Specification');
this.PulseShapeObj.Specification = value;
updateDynamicProperties(this)
end
%---------------------------------------------------------------------------
function value = getSpecification(this, value)
value = this.PulseShapeObj.Specification;
end
%---------------------------------------------------------------------------
function value = setDescription(this, value)
this.PulseShapeObj.Description = value;
end
%---------------------------------------------------------------------------
function value = getDescription(this, value)
value = this.PulseShapeObj.Description;
end
%---------------------------------------------------------------------------
function value = setNormalizedFrequency(this, value)
this.PulseShapeObj.NormalizedFrequency = value;
end
%---------------------------------------------------------------------------
function value = getNormalizedFrequency(this, value)
value = this.PulseShapeObj.NormalizedFrequency;
end
%---------------------------------------------------------------------------
function value = setFs(this, value)
this.PulseShapeObj.Fs = value;
end
%---------------------------------------------------------------------------
function value = getFs(this, value)
value = this.PulseShapeObj.Fs;
end
%---------------------------------------------------------------------------
function value = setPulseShapeObj(this, value)

this.PrivPulseShapeObj = value;

updateDynamicProperties(this)

% Add a listener to the Specifications property
this.Listeners = event.proplistener(this.PulseShapeObj, ...
  findprop(this.PulseShapeObj, 'Specification'),'PostSet', ...
  @(~,~) updateDynamicProperties(this));

end
%---------------------------------------------------------------------------
function value = getPulseShapeObj(this, value)
value = this.PrivPulseShapeObj;
end
%===============================================================================
% Helper functions
function updateDynamicProperties(this)
s = propstoadd(this.PulseShapeObj);
s = setdiff(s, {'Description', 'NormalizedFrequency', 'Fs', 'SamplesPerSymbol'});

% Remove all dynamic properties
dynamicProps = this.DynamicProps;
delete(dynamicProps)
clear dynamicProps;

for p=1:length(s)
    dynamicProps(p) = adddynprop(this, s{p}, [], ...
        @(~,val)setPulseShapeObjProp(this,s{p},val), ...
        @(~)getPulseShapeObjProp(this,s{p}));
end
this.DynamicProps = dynamicProps;
end
%-------------------------------------------------------------------------------
function value = setPulseShapeObjProp(this, propName, value)
this.PulseShapeObj.(propName) = value;
end
%-------------------------------------------------------------------------------
function value = getPulseShapeObjProp(this, propName)
value = this.PulseShapeObj.(propName);
end
% [EOF]
