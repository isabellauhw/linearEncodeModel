classdef timeaxis < sigresp.analysisaxis
  %sigresp.timeaxis class
  %   sigresp.timeaxis extends sigresp.analysisaxis.
  %
  %    sigresp.timeaxis properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       NormalizedFrequency - Property is of type 'string'
  %       LineStyle - Property is of type 'string'
  %
  %    sigresp.timeaxis methods:
  %       deletelineswithtag - Deletes the lines based on their tag
  %       getlinestyle - Returns the line color and style order
  %       getparameter - Returns the specified parameter
  %       getxparams -   Returns the param tags that force an x unzoom.
  %       thisdraw - Draw the time response
  %       timeaxis_getparameter - TIMERESP_GETPARAMETER
  %       timemode_listener -   Listener to the TimeMode parameter.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %NORMALIZEDFREQUENCY Property is of type 'string'
    NormalizedFrequency = '';
    %LINESTYLE Property is of type 'string'
    LineStyle = '';
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %TIMEDISPLAYMODE Property is of type 'string' (hidden)
    TimeDisplayMode = '';
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %LISTENERS Property is of type 'handle.listener vector'
    Listeners = [];
  end
  
  
  methods
    function value = get.NormalizedFrequency(obj)
      fGet = @(this,out)getprm(this,'freqmode');
      value = fGet(obj,obj.NormalizedFrequency);
    end
    function set.NormalizedFrequency(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','NormalizedFrequency')
      fSet = @(this,out)setprm(this,out,'freqmode');
      obj.NormalizedFrequency = fSet(obj,value);
    end
    
    function value = get.TimeDisplayMode(obj)
      fGet = @(this,out)gettimedisplaymode(this);
      value = fGet(obj,obj.TimeDisplayMode);
    end
    function set.TimeDisplayMode(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','TimeDisplayMode')
      fSet = @(this,out)settimedisplaymode(this,out);
      obj.TimeDisplayMode = fSet(obj,value);
    end
    
    function value = get.LineStyle(obj)
      fGet = @(this,out)getprm(this,'plottype');
      value = fGet(obj,obj.LineStyle);
    end
    function set.LineStyle(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','LineStyle')
      fSet = @(this,out)setprm(this,out,'plottype');
      obj.LineStyle = fSet(obj,value);
    end
    
    function set.Listeners(obj,value)
      % DataType = 'handle.listener vector'
      if ~isempty(value)
        validateattributes(value,{'handle.listener'}, {'vector'},'','Listeners')
      end
      obj.Listeners = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function deletelineswithtag(hObj)
      %DELETELINESWITHTAG Deletes the lines based on their tag
 
      h = get(hObj, 'Handles');
      delete(findobj(h.axes, 'type', 'line', 'tag', getlinetag(hObj)));
      
    end
    
    function lso = getlinestyle(hObj, varargin)
      %GETLINESTYLE Returns the line color and style order

      if strcmp(hObj.LineStyle, 'Stem')
        lso = 'none';
      else
        lso = '-';
      end
      
    end
    
    
    function hPrm = getparameter(hObj, varargin)
      %GETPARAMETER Returns the specified parameter
 
      hPrm = timeaxis_getparameter(hObj, varargin{:});
      
    end
    
    
    function xparams = getxparams(this)
      %GETXPARAMS   Returns the param tags that force an x unzoom.
     
        xparams = {'freqmode'};
      
    end
    
    
    function thisdraw(this)
      %THISDRAW Draw the time response
      
      deletelineswithtag(this);
      
      set(getbottomaxes(this), 'YLimMode', 'Auto');
      
      setupaxes(this);
      
      units = updateplot(this);
      
      setuplabels(this, units);
      
    end
    
    function hPrm = timeaxis_getparameter(hObj, varargin)
      %TIMERESP_GETPARAMETER
   
      hPrm = abstract_getparameter(hObj, varargin{:});
      if nargin < 2 || ~strcmpi(varargin{1}, '-all') && ~isempty(hPrm) && nargin == 1
        %Only return plottype if it was asked for
        hPrm = find(hPrm, '-not', 'tag', 'plottype');
      end
      
    end
    
    
    function timemode_listener(this, eventData)
      %TIMEMODE_LISTENER   Listener to the TimeMode parameter.
 
      units = getsettings(getparameter(this, 'freqmode'), eventData);
      
      normstr = 'samples';
      
      if strcmpi(units, 'on')
        if disableparameter(this, 'timeunits')
          hdlg = getcomponent(this, '-class', 'siggui.parameterdlg');
          if isempty(hdlg)
            val = get(this, 'TimeUnits');
          else
            val = getvaluesfromgui(hdlg, 'timeunits');
          end
          set(this, 'CachedTimeUnits', val);
          if isrendered(this), set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'Off'); end
          set(this, 'TimeUnits', normstr);
          if isrendered(this), set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'On'); end
        end
      else
        if enableparameter(this, 'timeunits')
          if isrendered(this), set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'Off'); end
          set(this, 'TimeUnits', get(this, 'CachedTimeUnits'));
          if isrendered(this), set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'On'); end
        end
      end
      
    end
    
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function hPrm = getxaxisparams(hObj)
      %GETXAXISPARAMS

      hPrm = get(hObj, 'Parameters');
      
      hPrm = find(hPrm, ...
        'tag', 'freqmode', '-or', ...
        'tag', 'plottype');
    end
    
    
    function allPrm = timeaxis_construct(this, varargin)
      %TIMEAXIS_CONSTRUCT

      allPrm = this.super_construct(varargin{:});
      
      createparameter(this, allPrm, 'Normalized Frequency', 'freqmode', 'on/off', 'on');
      createparameter(this, allPrm, 'Plot Type', 'plottype', ...
        {'Line with Marker', 'Stem', 'Line'}, 'Stem');

    end
    
    
  end  %% possibly private or hidden
  
end  % classdef

function tdm = settimedisplaymode(this, tdm)

if strcmpi(tdm, 'samples')
  set(this, 'NormalizedFrequency', 'On');
else
  set(this, 'NormalizedFrequency', 'Off');
end
end  % settimedisplaymode


% ---------------------------------------------------------------------
function tdm = gettimedisplaymode(this)

if strcmpi(this.NormalizedFrequency, 'On')
  tdm = 'samples';
else
  tdm = 'seconds';
end
end  % gettimedisplaymode


% ---------------------------------------------------------------------
function out = setprm(hObj, out, prm)

hPrm = getparameter(hObj, prm);
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setprm


% ---------------------------------------------------------------------
function out = getprm(hObj, prm)

hPrm = getparameter(hObj, prm);
if isempty(hPrm)
  out = '';
else
  out = get(hPrm, 'Value');
end
end  % getprm


% -----------------------------------------------------------------
function units = updateplot(this)

[H, T] = getplotdata(this);

h = get(this, 'Handles');

if isempty(H)
  units = '';
  h.line = [];
else
  
  if strcmpi(get(this, 'NormalizedFrequency'), 'on')
    
    filtindx = 1; %#ok<*NASGU>
    fs = getmaxfs(this);
    
    if ~isempty(fs)
      for indx = 1:length(T)
        T{indx} = T{indx}*fs;
      end
    end
    units = [];
  else
    [T, ~, units] = cellengunits(T);
  end
  
  hPlot = getparameter(this, 'plottype');
  ax    = h.axes;
  ptype = get(hPlot, 'Value');
  h.line = [];
  type  = find(strcmpi(hPlot.Value, hPlot.ValidValues));
  nresps = 0;
  np    = get(ax, 'NextPlot'); set(ax, 'NextPlot','add');
  npfig = get(this.FigureHandle, 'NextPlot');
  for indx = 1:length(H)
    
    for jndx = 1:size(H{indx},2)
      
      nresps = nresps+1;
      
      color = getlinecolor(this, length(h.line)+1);
      
      if type == 2  % Stem
        ht = stem(ax, T{indx}, real(H{indx}(:, jndx)), 'filled');
      else          % Line and Line with Marker
        ht = line(T{indx},real(H{indx}(:,jndx)),'Parent',ax);
      end
      
      if ~isreal(H{indx})
        if type == 2  % Stem
          ht(2) = stem(ax, T{indx}, imag(H{indx}(:, jndx)), 'filled');
        else          % Line and Line with Marker
          ht(2) = line(T{indx}, imag(H{indx}(:, jndx)), 'Parent', ax);
        end
      end
      
      set(ht, 'Visible', this.Visible);
      
      set(ht, 'Color', color);
      if any(type == [1 2]) % Line with Marker and Stem
        [m, f] = getmarker(this, nresps);
        set(ht(1), 'Marker', m{1}, 'MarkerFaceColor', f{1});
        if length(ht) == 2
          set(ht(2), 'Marker', m{2}, 'MarkerFaceColor', f{2});
        end
      end
      h.line = [h.line ht];
    end
  end
  set(ax, 'NextPlot', np);
  
  % Setting the axes automatically updates the figures nextplot property.
  % So we need to reset that one too.
  set(this.FigureHandle, 'NextPlot', npfig);
  
  % Avoid setting the axis x limits to the same value - causes an error.
  xlimits = [T{1}(1), T{1}(end)];
  if ~isequal(xlimits(1), xlimits(2)) && ~any(isnan(xlimits))
    set(ax(1),'XLim',xlimits);
  end
  
  set(h.line, 'Tag', getlinetag(this));
  hc = get(h.line, 'Children');
  if iscell(hc), hc = [hc{:}]; end
  set(hc, 'Tag', getlinetag(this));
end

set(this, 'Handles', h);

end

%-------------------------------------------------------------------
function setupaxes(this)

h = get(this, 'Handles');

h.axes = h.axes(end);

if ~ishandlefield(this, 'timecsmenu')
  h.timecsmenu = addtimecsmenu(this, get(h.axes, 'XLabel'));
end
if ~ishandlefield(this, 'plotcsmenu')
  hc = get(h.axes, 'UIContextMenu');
  
  [hcs, hmenu] = contextmenu(getparameter(this, 'plottype'), h.axes);
  
  % If there is already a context menu only store the new menus.
  if isempty(hc)
    h.plotcsmenu = hcs;
  else
    h.plotcsmenu = hmenu;
  end
end

set(this, 'Handles', h);

end

%-------------------------------------------------------------------
function setuplabels(this, units)

h = get(this, 'Handles');

% Get the xlabel from the time mode
if strcmpi(get(this, 'NormalizedFrequency'), 'on')
  xlbl = getString(message('signal:sigtools:sigresp:Samples'));
else
  xlbl = sprintf('%s (%s%s)',getString(message('signal:sigtools:sigresp:Time')), units, 's'); %this.TimeUnits);
end

xlabel(h.axes, xlbl);
title(h.axes, get(this, 'Name'));
ylabel(h.axes, getString(message('signal:sigtools:sigresp:Amplitude')));

end

% -------------------------------------------------------------------------
function lcltimemode_listener(this, eventData)

timemode_listener(this, eventData);

end
