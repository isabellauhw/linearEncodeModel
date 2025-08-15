classdef (Abstract) freqaxis < sigresp.analysisaxis
  %sigresp.freqaxis class
  %   sigresp.freqaxis extends sigresp.analysisaxis.
  %
  %    sigresp.freqaxis properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       FrequencyScale - Property is of type 'string'
  %       NormalizedFrequency - Property is of type 'string'
  %
  %    sigresp.freqaxis methods:
  %       freqaxis_construct - Constructor for the freqaxis class.
  %       freqaxis_getxaxisparams - Differentiates freq. axis from time axis.
  %       freqmode_listener -   Listener to the FREQMODE parameter.
  %       getxaxisparams - Get the parameters that are relevant to the axis.
  %       getxparams -   Returns the param tags that force an x unzoom.
  %       normalize_w - Normalize the frequency vector if it should be.
  %       setfrequnits -   Set the frequnits parameter.
  %       setlineprops - Set up the properties of the lines, such as datamarkers, visibility, color, style, etc.
  %       thisdraw - Add the frequency response specific content.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %FREQUENCYSCALE Property is of type 'string'
    FrequencyScale = '';
    %NORMALIZEDFREQUENCY Property is of type 'string'
    NormalizedFrequency = '';
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %LISTENERS Property is of type 'handle.listener vector'
    Listeners = [];
    %PROPLISTENERS Property is of type 'handle.listener vector'
    PropListeners = [];
  end
  
  
  methods
    function value = get.FrequencyScale(obj)
      value = getparam(obj,obj.FrequencyScale,'freqscale');
    end
    function set.FrequencyScale(obj,value)
      validateattributes(value,{'char'}, {'row'},'','FrequencyScale')
      obj.FrequencyScale = setparam(obj,value,'freqscale');
    end
    
    function value = get.NormalizedFrequency(obj)
      value = getparam(obj,obj.NormalizedFrequency,'freqmode');
    end
    function set.NormalizedFrequency(obj,value)
      validateattributes(value,{'char'}, {'row'},'','NormalizedFrequency')
      obj.NormalizedFrequency = setparam(obj,value,'freqmode');
    end
    
    function set.Listeners(obj,value)
      if ~isempty(value)
        validateattributes(value,{'handle.listener'}, {'vector'},'','Listeners')
      end
      obj.Listeners = value;
    end
    
    function set.PropListeners(obj,value)
      % DataType = 'handle.listener vector'
      if ~isempty(value)
        validateattributes(value,{'prop.listener'}, {'vector'},'','PropListeners')
      end
      obj.PropListeners = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function allPrm = freqaxis_construct(this,varargin)
      %FREQAXIS_CONSTRUCT Constructor for the freqaxis class.

      allPrm = this.super_construct(varargin{:});
      
      % Create parameters for the frequency response object.
      %createfreqrangeprm(this, allPrm)
      createparameter(this, allPrm, 'Normalized Frequency', 'freqmode', 'on/off', 'on');
      % createparameter(this, allPrm, 'Frequency Units', 'frequnits', @charcheck, 'Hz');
      createparameter(this, allPrm, 'Frequency Scale', 'freqscale', {'Linear', 'Log'});
      
      hPrm = getparameter(this, 'freqmode');
      l = [ ...
        handle.listener(hPrm, 'NewValue', @freqmode_listener); ...
        handle.listener(hPrm, 'UserModified', @freqmode_listener); ...
        ];
      
      set(l, 'CallbackTarget', this);
      set(this, 'Listeners', l);
      
      freqmode_listener(this, []);
      
    end
    
    
    function hPrm = freqaxis_getxaxisparams(hObj)
      %FREQAXIS_GETXAXISPARAMS Differentiates freq. axis from time axis.

      hPrm = get(hObj, 'Parameters');
      
      hPrm = find(hPrm, 'tag', getfreqrangetag(hObj),'-or', ...
        'tag', getnffttag(hObj), '-or', ...
        'tag', 'freqmode', '-or', ...
        'tag', 'frequnits', '-or', ...
        'tag', 'freqscale');
      
    end
    
    
    function freqmode_listener(this, eventData)
      %FREQMODE_LISTENER   Listener to the FREQMODE parameter.

      freqaxis_freqmode_listener(this, eventData);
      
    end
    
    
    function hPrm = getxaxisparams(hObj)
      %GETXAXISPARAMS Get the parameters that are relevant to the axis.
 
      % Call "super" getxaxisparams.
      hPrm = freqaxis_getxaxisparams(hObj);
      
    end
    
    
    function xparams = getxparams(this)
      %GETXPARAMS   Returns the param tags that force an x unzoom.

      xparams = {'freqmode'};
      
    end
    
    function [W, m, xunits] = normalize_w(hObj, W)
      %NORMALIZE_W Normalize the frequency vector if it should be.

      mfs = getmaxfs(hObj);
      if strcmpi(get(getparameter(hObj, 'freqmode'), 'Value'), 'on') || isempty(mfs)
        if isempty(mfs), mfs = 2*pi; end
        for indx = 1:length(W)
          W{indx} = W{indx}/(mfs/2);
        end
        m = 1;
        xunits = 'rad/sample';
      else
        
        [W, m, xunits] = cellengunits(W);
      end
      
    end
    
    function frequnits = setfrequnits(this, frequnits)
      %SETFREQUNITS   Set the frequnits parameter.

      if strcmpi(get(this, 'NormalizedFrequency'), 'Off')
        
        hPrm = getparameter(this, 'frequnits');
        if ~isempty(hPrm), setvalue(hPrm, frequnits); end
      else
        set(this, 'CachedFrequencyUnits', frequnits);
      end
      
    end
    
    
    function setlineprops(hObj)
      %SETLINEPROPS Set up the properties of the lines, such as datamarkers, visibility, color, style, etc.

      analysisaxis_setlineprops(hObj);
      
      hline = getline(hObj);
      for indx = 1:length(hline)
        set(hline(indx), ...
          'Color', getlinecolor(hObj, indx), ...
          'LineStyle', getlinestyle(hObj, indx));
      end
      
    end
    
    
    function varargout = thisdraw(this)
      %THISDRAW Add the frequency response specific content.

      fupdate = strcmpi(this.FastUpdate, 'On');
      
      if fupdate
        set(getbottomaxes(this), 'YLimMode', 'Manual');
      else
        set(getbottomaxes(this), 'YLimMode', 'Auto');
      end
      
      [m, xunits, varargout{1:nargout}] = objspecificdraw(this);
      
      setappdata(getbottomaxes(this), 'EngUnitsFactor', m);
      
      if ~fupdate
        addfreqlblnmenu(this, xunits);
        setupxscale(this);
      end
      
    end
    
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function freqaxis_freqmode_listener(this, eventData)
      %FREQAXIS_FREQMODE_LISTENER
      
      units = getsettings(getparameter(this, 'freqmode'), eventData);

      if strcmpi(units, 'on')
        
        % If the parameter isn't already disabled, make sure that we cache the
        % current value and put up "pi rad/sample".
        if disableparameter(this, 'frequnits')

        end
      else
        if enableparameter(this, 'frequnits')
          %         setvalue(getparameter(this, 'frequnits'), get(this, 'CachedFrequencyUnits'), 'noevent');
        end
      end
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = setparam(this, out, tag)

hPrm = getparameter(this, tag);
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setparam


% ---------------------------------------------------------------------
function out = getparam(this, out, tag)

hPrm = getparameter(this, tag);
out = get(hPrm, 'Value');
end  % getparam

% -------------------------------------------------------------------------
function charcheck(input)

if ~ischar(input)
  error(message('signal:sigresp:freqaxis:freqaxis_construct:FreqUnitsNotChar'));
end

end

% --------------------------------------------------------------
function setupxscale(this)

h = get(this, 'Handles');

% If we are in -pi to pi mode, we cannot use log scale
scale = get(this, 'FrequencyScale');
set(h.axes, 'XScale', scale);
if strcmpi(scale, 'log')
  xlim  = get(h.axes, 'XLim');
  xdata = get(h.line, 'XData');
  if ~iscell(xdata), xdata = {xdata}; end
  minx = zeros(length(xdata),1);
  for indx = 1:length(xdata)
    xdata{indx}(xdata{indx} == 0) = [];
    minx(indx) = min(xdata{indx});
  end
  set(h.axes, 'XLim', [min(minx) xlim(2)]);
end

end

% --------------------------------------------------------------
function addfreqlblnmenu(this, xunits)

fs = getmaxfs(this);

normlbl = getString(message('signal:sigtools:sigresp:NormalizedFrequencypiRadsample'));

if isempty(fs)
  enab = {'On', 'Off'};
  lbls = {normlbl, getString(message('signal:sigtools:sigresp:Frequency'))};
else
  enab = {'On', 'On'};
  [fs, m, fsunits] = engunits(fs/2);
  fsunits          = sprintf('%sHz', fsunits);
  %     fsunits          = sprintf('%s%s', fsunits, this.CachedFrequencyUnits);
  lbls = {normlbl, ...
    sprintf([getString(message('signal:sigtools:sigresp:Frequency')) ' (Fs = %s%s)'], num2str(fs*2), fsunits)};
end

if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on')
  lbl = getString(message('signal:sigtools:siggui:NormalizedFrequencyRadsample','\times\pi'));
else
  lbl = sprintf([getString(message('signal:sigtools:sigresp:Frequency')) ' (%sHz)'], xunits);
end
hlbl = xlabel(getbottomaxes(this), lbl);

h = get(this, 'Handles');

hprm = getparameter(this, 'freqmode');
tags = {'on', 'off'};
% Create the default aspects of the menu items
if isfield(h, 'freqcsmenu') && ishghandle(h.freqcsmenu)
  for indx = 1:length(tags)
    set(findobj(h.freqcsmenu, 'tag', tags{indx}), 'Label', lbls{indx}, ...
      'Enable', enab{indx});
  end
else
  
  h.freqcsmenu = addcsmenu(hlbl);
  
  % Generate the menus
  for i = 1:length(tags)
    uimenu(h.freqcsmenu, 'Label', lbls{i}, ...
      'Callback', {@update_displaymode, this}, ...
      'Tag', tags{i}, ...
      'Enable', enab{i});
  end
  
  % Make sure that the correct menu is checked
  mode = get(this, 'NormalizedFrequency');
  set(findall(h.freqcsmenu, 'tag', lower(mode)), 'Checked', 'On');
  set(this, 'Handles', h);
  l = handle.listener(hprm, 'NewValue', @newvalue_listener);
  set(l, 'CallbackTarget', this);
  setappdata(h.freqcsmenu, 'NewValueListener', l);
end

end

%-------------------------------------------------------------------
function newvalue_listener(this, eventData)

h = get(this, 'Handles');
set(allchild(h.freqcsmenu), 'Checked', 'Off');
set(findobj(h.freqcsmenu, 'tag', lower(get(this, 'NormalizedFrequency'))), 'Checked', 'On');

end

%-------------------------------------------------------------------
function update_displaymode(hcbo, eventStruct, this)

set(get(get(hcbo, 'Parent'), 'Children'), 'Checked', 'Off');
set(hcbo, 'Checked', 'On');

set(this, 'NormalizedFrequency', get(hcbo, 'Tag'));

end

% [EOF]



