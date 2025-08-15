classdef magnitude < filtresp.frequencyresp
  %filtresp.magnitude class
  %   filtresp.magnitude extends filtresp.frequencyresp.
  %
  %    filtresp.magnitude properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       FrequencyScale - Property is of type 'string'
  %       NormalizedFrequency - Property is of type 'string'
  %       FrequencyRange - Property is of type 'string'
  %       NumberOfPoints - Property is of type 'double'
  %       FrequencyVector - Property is of type 'double_vector user-defined'
  %       DisplayMask - Property is of type 'on/off'
  %       MagnitudeDisplay - Property is of type 'string'
  %       NormalizeMagnitude - Property is of type 'string'
  %       UserDefinedMask - Property is of type 'dspdata.maskline'
  %       PassbandZoom - Property is of type 'on/off'
  %
  %    filtresp.magnitude methods:
  %       attachlisteners - Attach listeners to properties for render updates.
  %       enablemask - Returns true if the mask can be drawn.
  %       getkeyhandles - GETh   Returns the "key" handles.
  %       getname - Get the name of the magnitude response
  %       getunits -   Get the units.
  %       getxparams -   Get the xparams.
  %       getyparams -   Return the param tags that set off a y unzoom.
  %       legendstring - Return the legend string
  %       magnitude_construct - Construct a magresp object
  %       objspecificdraw - OBJSPECIFICTHISDRAW Draw the magnitude response
  %       updatemasks - Draw the masks onto the bottom axes
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %MAGNITUDEDISPLAY Property is of type 'string'
    MagnitudeDisplay = '';
    %NORMALIZEMAGNITUDE Property is of type 'string'
    NormalizeMagnitude = '';
    %USERDEFINEDMASK Property is of type 'dspdata.maskline'
    UserDefinedMask = [];
    %PASSBANDZOOM Property is of type 'on/off'
    PassbandZoom = 'off'
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %OLDAUTOSCALE Property is of type 'string' (hidden)
    OldAutoScale = '';
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %MAGNITUDEFILTERLISTENERS Property is of type 'handle.listener vector'
    MagnitudeFilterListeners = [];
    %PASSBANDZOOMHANDLE Property is of type 'mxArray'
    PassbandZoomHandle = [];
    %PASSBANDZOOMLISTENER Property is of type 'handle.listener'
    PassbandZoomListener = [];
  end
  
  
  methods  % constructor block
    function h = magnitude(varargin)
      %MAGNITUDE Construct a magresp object

      h.magnitude_construct(varargin{:});
            
    end  % magnitude
    
  end  % constructor block
  
  methods
    function value = get.MagnitudeDisplay(obj)
      value = getprop(obj,obj.MagnitudeDisplay,'magnitude');
    end
    function set.MagnitudeDisplay(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','MagnitudeDisplay')
      obj.MagnitudeDisplay = setprop(obj,value,'magnitude');
    end
    
    function value = get.NormalizeMagnitude(obj)
      value = getprop(obj,obj.NormalizeMagnitude,'normalize_magnitude');
    end
    function set.NormalizeMagnitude(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','NormalizeMagnitude')
      obj.NormalizeMagnitude = setprop(obj,value,'normalize_magnitude');
    end
    
    function set.UserDefinedMask(obj,value)
      % DataType = 'dspdata.maskline'
      validateattributes(value,{'dspdata.masklineMCOS'}, {'scalar'},'','UserDefinedMask')
      obj.UserDefinedMask = value;
    end
    
    function set.MagnitudeFilterListeners(obj,value)
      % DataType = 'handle.listener vector'
      validateattributes(value,{'event.proplistener'}, {'vector'},'','MagnitudeFilterListeners')
      obj.MagnitudeFilterListeners = value;
    end
    
    function set.PassbandZoomHandle(obj,value)
      obj.PassbandZoomHandle = value;
    end
    
    function set.PassbandZoomListener(obj,value)
      % DataType = 'handle.listener'
      validateattributes(value,{'event.proplistener'}, {'scalar'},'','PassbandZoomListener')
      obj.PassbandZoomListener = value;
    end
    
    function set.PassbandZoom(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','PassbandZoom');
      obj.PassbandZoom = value;
    end
    
    function set.OldAutoScale(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','OldAutoScale')
      obj.OldAutoScale = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function attachlisteners(this)
      %ATTACHLISTENERS Attach listeners to properties for render updates.
                  
      filtutils = this.FilterUtils;
      
      l(1) = event.proplistener(this, this.findprop('DisplayMask'),             'PostSet', @(s,e)lcldisplaymask_listener(this,e));
      l(2) = event.proplistener(filtutils, filtutils.findprop('Filters'),       'PostSet', @(s,e)lclfilter_listener(this,e));
      l(3) = event.proplistener(filtutils, filtutils.findprop('ShowReference'), 'PostSet', @(s,e)lclshow_listener(this,e));
      l(4) = event.proplistener(filtutils, filtutils.findprop('PolyphaseView'), 'PostSet', @(s,e)lclshow_listener(this,e,'none'));
      l(5) = event.proplistener(filtutils, filtutils.findprop('SOSViewOpts'),   'PostSet', @(s,e)sosview_listener(this,e));
      l(6) = event.proplistener(this, this.findprop('UserDefinedMask'),         'PostSet', @(s,e)lclshow_listener(this,e));
      
      this.WhenRenderedListeners = l;
      
      attachfilterlisteners(this);
      
    end
    
    function b = enablemask(this)
      %ENABLEMASK Returns true if the mask can be drawn.
 
      % If there is more than 1 filter, if that filter does not have maskinfo or
      % if the mask info isn't for the current analysis we cannot display the
      % mask.
      if ~isprop(this, 'Filters')
        b = false;
        return;
      end
      Hd = this.Filters;
      
      if length(Hd) == 1 && strcmpi(this.PolyphaseView, 'on') && ispolyphase(Hd.Filter)
        b = false;
        return;
      end
      
      b  = false(1, length(Hd));
      
      hfdfirst = [];
      hfmfirst = [];
      
      for indx = 1:length(Hd)
        Hd = get(this.Filters(indx), 'Filter');
        
        if isa(Hd, 'dfilt.basefilter')
          
          hfd = privgetfdesign(Hd);
          hfm = getfmethod(Hd);
          
          if isempty(hfdfirst)
            hfdfirst = hfd;
          end
          if isempty(hfmfirst)
            hfmfirst = hfm;
          end
        else
          hfd = [];
          hfm = [];
        end
        
        if isempty(hfd) || isempty(hfm)
          if isa(Hd, 'dfilt.basefilter')
            % If one of these is empty then we need to check to see if we
            % have a valid FILTDES maskinfo to work with.
            if isprop(Hd, 'MaskInfo')
              MI = get(Hd, 'MaskInfo');
              switch lower(this.MagnitudeDisplay)
                case {'zero-phase', 'magnitude'}
                  b(indx) = any(strcmpi(MI.magunits, {'linear', 'weights'}));
                case 'magnitude (db)'
                  b(indx) = strcmpi(MI.magunits, 'db');
                case 'magnitude squared'
                  b(indx) = strcmpi(MI.magunits, 'squared');
              end
            end
          end
        else
          
          % If the specification are equivalent (meaning the 'Specification'
          % is the same and all of the settings are the same) and all of the
          % methods used are constrained, we can show the masks.
          [f, a] = drawmask(hfd, hfm, []);
          if isempty(f)
            b(indx) = false;
          elseif isequivalent(hfd, hfdfirst) && ...
              hfm.isconstrained == hfmfirst.isconstrained
            b(indx) = true;
          else
            b(indx) = false;
          end
        end
      end
      
      b = all(b);
      
      % [EOF]
      
    end
    
    function h = getkeyhandles(this)
      %GETh   Returns the "key" handles.

      h = this.Handles;
      if isfield(h, 'masks')
        h = rmfield(h, 'masks');
      end
      if isfield(h, 'legend')
        h = rmfield(h, 'legend');
      end
      if isfield(h, 'userdefinedmask')
        h = rmfield(h, 'userdefinedmask');
      end
      
      h = convert2vector(h);
      
    end
    
    function out = getname(hObj, out)
      %GETNAME Get the name of the magnitude response
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      mag = hObj.MagnitudeDisplay;
      
      %ADDCATALOG  signal/sigtools/@sigresp/@twoanalyses/getname.m is calling here and doing manipulations on the string
      switch lower(mag)
        case 'magnitude'
          out = getString(message('signal:sigtools:filtresp:MagnitudeResponse'));
        case 'magnitude (db)'
          out = getString(message('signal:sigtools:filtresp:MagnitudeResponsedB'));
        case 'magnitude squared'
          out = getString(message('signal:sigtools:filtresp:MagnitudeResponsesquared'));
        case 'zero-phase'
          out = getString(message('signal:sigtools:filtresp:ZerophaseResponse'));
      end
      
      
    end
    
    
    function units = getunits(this)
      %GETUNITS   Get the units.

      hprm = getparameter(this, 'unitcircle');
      
      Hd = this.Filters;
      
      switch find(strcmpi(hprm.Value, hprm.ValidValues))
        case {1, 3}
          [y,e,units] = engunits(getmaxfs(Hd)/2);
        case 2
          [y,e,units] = engunits(getmaxfs(Hd));
        case 4
          [y,e,units] = engunits(this.FrequencyVector);
      end
      
      units = [units 'Hz'];
      
    end
    
    
    function xparams = getxparams(this)
      %GETXPARAMS   Get the xparams.

      xparams = {'freqmode'};
      
    end
    
    
    function yparams = getyparams(this)
      %GETYPARAMS   Return the param tags that set off a y unzoom.

      yparams = {'magnitude'};
      
    end
    
    
    function s = legendstring(hObj)
      %LEGENDSTRING Return the legend string

      s = getString(message('signal:sigtools:filtresp:Magnitude'));
      
    end
    
    function allPrm = magnitude_construct(this, varargin)
      %MAGNITUDE_CONSTRUCT Construct a magresp object
 
      this.Name = 'Magnitude Response';
      
      allPrm = frequencyresp_construct(this,varargin{:});
      
      createparameter(this, allPrm, 'Magnitude Display', 'magnitude', ...
        {'Magnitude', 'Magnitude (dB)', 'Magnitude squared', 'Zero-phase'}, ...
        'Magnitude (db)');
      
      createparameter(this, allPrm, 'Normalize Magnitude to 1 (0 dB)', ...
        'normalize_magnitude', 'on/off', 'off');
      
      l = event.proplistener(this.FilterUtils, this.FilterUtils.findprop('Filters'), 'PostSet', @(s,e)lclfilters_listener(this,e));
      this.MagnitudeFilterListeners = l;
      
      lclfilters_listener(this);
      
    end
    
    function [m, xunits] = objspecificdraw(this)
      %OBJSPECIFICTHISDRAW Draw the magnitude response

      % MAIN CHANGES:
      %  1 - increased modularity via "procedural decomposition"
      %      recommend: decompose into multiple functions
      %                 definitions of input and output args will help
      %                 code maintenance and modularity tremendously
      %  2 - inconsistent usage of "get(obj,field)" versus "obj.field"
      %      recommend: obj.field for efficiency
      %  3 - usage of LOWER and UPPER case of a variable name (h and H)
      %      recommend: don't do that!  works, but poor practice
      %                 no changes made ... left both "h" and "H" in code
      %  4 - using new ylimit estimator only for dB plots
      %      using different estimator for linear plots
      
      % Get handles and filters
      h  = this.Handles; % fields get added to struct throughout function
      Hd = this.Filters;
      h.axes = h.axes(end);
      
      RemoveUserDefinedMask(h);
      
      [xunits,m,h] = InstallMagPlot(h,this,Hd);
      hylbl        = InstallYLabel(h,this);
      h            = InstallContextMenu(h,this,hylbl);
      h            = InstallUserDefinedMask(h,this,Hd,m);
      
      % Store handles
      this.Handles = h;
      updatemasks(this);
      
    end
    
    function show_listener(this, eventData, limits)
      
      deletehandle(this, 'Legend');
      
      if nargin < 3
        limits = 'both';
      end
      
      captureanddraw(this, limits);
      
      % Make sure that we put up the legend after so that it is on top of the
      % plotting axes.
      updatelegend(this);
      
    end
    
    function updatemasks(this)
      %UPDATEMASKS Draw the masks onto the bottom axes

      h = this.Handles;
      
      if isfield(h, 'masks')
        h.masks(~ishghandle(h.masks)) = [];
        delete(h.masks);
      end
      
      Hd = this.Filters;
      if ~isempty(Hd) && strcmpi(this.DisplayMask, 'On') && ...
          ~(isa(Hd(1).Filter, 'dfilt.abstractsos') && ...
          ~isempty(this.SOSViewOpts) && ...
          ~strcmpi(this.SOSViewOpts.View, 'Complete'))
        
        if isa(Hd(1).Filter, 'dfilt.basefilter')
          hfd = Hd(1).Filter.privgetfdesign;
          hfm = Hd(1).Filter.getfmethod;
        else
          hfd = [];
          hfm = [];
        end
        
        % If we have the FDESIGN and FMETHOD object, use them, otherwise use
        % the old code with filtdes.
        if isempty(hfd) || isempty(hfm)
          h.masks = drawfiltdesmask(this);
        else
          h.masks = drawfdesignmask(this);
        end
        for indx = 1:length(h.masks)
          if ishghandle(h.masks(indx))
            setappdata(h.masks(indx), 'AffectsFullView', 'off');
          end
        end
      else
        h.masks = [];
      end
      
      % Make sure that HitTest is turned off so that the data markers on the
      % response line work smoothly.
      set(h.masks, 'HitTest', 'Off');
      this.Handles = h;
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function formataxislimits(this)
      %FORMATAXISLIMITS
  
      h = this.Handles;
      
      ydata = get(h.line, 'YData');
      xdata = get(h.line, 'XData');
      
      if isempty(ydata)
        return;
      end
      
      is_dB = strcmpi(this.MagnitudeDisplay,'magnitude (db)');
      
      % Compute global Y-axis limits over potentially
      % multiple filter magnitude responses
      %
      yMin =  Inf;  % min global y-limit
      yMax = -Inf;  % max global y-limit
      xMin =  Inf;
      xMax = -Inf;
      if ~iscell(ydata)
        ydata = {ydata};
        xdata = {xdata};
      end
      for indx = 1:length(ydata) % Loop over the filter responses.
        thisMag = ydata{indx};
        if is_dB
          % Estimate y-limits for dB plots
          thisYlim = freqzlim_dB(thisMag);
        else
          % Estimate y-limits for linear plots
          thisYlim = freqzlim_lin(thisMag);
        end
        yMin = min(yMin, thisYlim(1));
        yMax = max(yMax, thisYlim(2));
        xMin = min(xMin, min(xdata{indx}));
        xMax = max(xMax, max(xdata{indx}));
      end
      
      % Make sure that the yMin and yMax aren't exactly equal.  This can happen
      % in the GRPDELAY case for linear phase filters or in magnitude for all
      % pass filters.
      if yMin == yMax
        yMin = yMin-.5;
        yMax = yMax+.5;
      end
      
      scale = get(h.axes, 'XScale');
      if strcmpi(scale, 'log')
        set(h.axes, 'YLim',[yMin yMax]);
      else
        set(h.axes, 'YLim',[yMin yMax], 'XLim', [xMin xMax]);
      end
    end
    
    % ----------------------------------------------------------
    function attachfilterlisteners(this)
      
      l = this.WhenRenderedListeners;
      l = l(1:6);
      
      Hd = this.Filters;
      
      if ~isempty(Hd)
        l = [l event.listener(Hd, 'NewFs', @(s,e)fs_listener(this,e))];
        l = [l event.proplistener(Hd, Hd(1).findprop('Name'), 'PostSet', @(s,e)name_listener(this,e))];
      end
      
      this.WhenRenderedListeners = l;
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = setprop(hObj, out, tag)

hPrm = getparameter(hObj, tag);
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setprop


% -------------------------------------------------------
function out = getprop(hObj, out, tag)

hPrm = getparameter(hObj, tag);
if ~isempty(hPrm)
  out = get(hPrm, 'Value');
else
  out = '';
end
end  % getprop

% ----------------------------------------------------------
function sosview_listener(this, eventData)

Hd = this.Filters;
if length(Hd) == 1
  if isa(Hd.Filter, 'dfilt.abstractsos')
    lclshow_listener(this, eventData, 'x');
  end
end

end

% ----------------------------------------------------------
function lclshow_listener(this, ~, limits)

if ~this.IsOverlayedOn    
  if nargin < 3
    limits = 'both';
  end
  filtrespShowUpdate(this,limits);  
end

end
% ----------------------------------------------------------
function lcldisplaymask_listener(this, ~)

updatemasks(this);

end

% ---------------------------------------------------------------------
function lclfilter_listener(this, ~)

% If the Handles property exists means the properties created (dynamically)
% exist, only then attach the listeners. In UDD listeners can be
% attached to properties which do not exist for an object, this is not
% allowed in MCOS.
if ~this.IsOverlayedOn    
  filtrespFiltUpdate(this);
end

end

% ---------------------------------------------------------------------
function name_listener(this, ~)

deletehandle(this, 'legend');
updatelegend(this);

end

% ---------------------------------------------------------------------
function fs_listener(this, ~, varargin)

if ~this.IsOverlayedOn    
  filtrespFsUpdate(this);
end

end

% --------------------------------------------------------------------
function ylim = freqzlim_lin(mag)
% Estimate Y-axis limits to view LINEAR magnitude response
% Algorithm:
%    - Find actual min/max of linear response
%    - Add a little "extra space" (margin) at top and bottom
%    - The extra space is defined as a fraction of dynamic range
%      of the magnitude response curve
%
% Returns:
%   ylim: vector of y-axis display limits, [ymin ymax]
%
MarginTop = 0.03;  % 3% margin of dyn range at top
MarginBot = 0.03;  % ditto

% Find actual min/max of data
mmax = max(mag);
mmin = min(mag);
dr = mmax-mmin;  % dynamic range of magnitude
ymax = mmax + dr*MarginTop;  % Raise by fraction of dynamic range
ymin = mmin - dr*MarginBot;  % Lower by fraction of dynamic range
ylim = [ymin ymax];

end


% --------------------------------------------------------------------
function ylim = freqzlim_dB(mag)
% Estimate Y-axis limits to view magnitude dB response
% Algorithm:
%  - Estimate smoothed envelope of dB response curve,
%    to avoid "falling into nulls" in ripple regions
%  - Add a little "extra space" (margin) at top and bottom
%
% Note: we do NOT use the max and min of the response itself
%     - min is an overestimate often going to -300 dB or worse
%     - max is an underestimate causing the response to hit axis
%
% Returns:
%   ylim: vector of y-axis display limits, [ymin ymax]

MarginTop = 0.03;  % 3% margin of dyn range at top
MarginBot = 0.10;  % 10% margin at bottom

% Determine default margins
%
% Remove non-finite values for dynamic range computation
magf = mag;
magf(~isfinite(magf)) = [];
top = max(magf);
bot = min(magf);
dr = top-bot; % "modified" dynamic range

% Handle the null case.
if isempty(dr)
  ylim = [0 1];
else
  
  % If the dynamic range is less than 60 dB, just show the full range.
  % Otherwise we want to see if we can cut out part of the display by
  % doing analysis on its shape.
  if dr > 60
    
    % Length of sliding window to compute "localized maxima" values
    % We're looking for the MINIMUM of the ENVELOPE of the input curve
    % (mag). The true envelope is difficult to compute due as it is
    % positive-only The length of the sliding window is important:
    %  - too long: envelope estimate is biased toward "global max"
    %              and we lose accuracy of envelope minimum
    %  - too short: we fall into "nulls" and we're no longer tracking
    %               the envelope
    %
    % Set window to 10% of input length, minimum of 3 samples
    Nspan = max(3, ceil(.1*numel(mag)));
    
    % Compute mag envelope, derive y-limit estimates
    env = MiniMax(mag, Nspan);
    bot = env;
    
    % When we have more than 60 dB of dynamic range, make the minimum
    % shown dynamic range 60.
    if top-env < 60
      bot = top-60;
    end
  end
  ymin = bot - dr*MarginBot;  % Lower by fraction of dynamic range
  ymax = top + dr*MarginTop;
  ylim = [ymin ymax];
end

end

% --------------------------------------------------------------------
function spanMin = MiniMax(mag,Nspan)
%MiniMax Find the minimum of all local maxima, with each
%  maxima computed over NSPAN-length segments of input.

Nele=numel(mag);
if Nele<Nspan
  spanMin = min(mag);
else
  
  
  % This is the original code in its more MATLABish form.  This is not
  % "JIT friendly" so was very slow.  The longer code below is actually
  % must faster with the same exact functionality.
  %     spanMin=inf;
  %     Ns1=Nspan-1;
  %     for i=1:Nele-Ns1
  %         spanMin = min(spanMin,max(mag(i:i+Ns1)));
  %     end
  
  % General case
  spanMin = max(mag(1:Nspan)); % max computed over first span
  intMax = spanMin;            % interval max computed over all spans
  
  % Only allow 8192 discrete steps.  This will improve the algorithms
  % speed greatly and only lose a small amount of accuracy.
  maxSteps = 8192;
  step = ceil((Nele-Nspan-1)/maxSteps);
  for i = 1:step:Nele-Nspan  % already did first span (above!)
    % Overall equivalent code for this section:
    %   spanMin = min(spanMin,max(mag(i:i+Ns1)));
    %
    % Update intMax, the maximum found over the current interval
    % The "update" is to consider just (a) the next point to bring
    % into the interval, and (b) the last point dropped out of the
    % interval.  This produces an efficient "slide by 1" max result.
    %
    % Equivalent code:
    %   intMax = max(mag(i:i+Ns1));
    pAdd = mag(i+Nspan);  % add point
    if pAdd > intMax
      % just take pAdd as new max
      intMax = pAdd;
    elseif mag(i) < intMax  % Note: pDrop = mag(i-1)
      % just add in effect of next point
      intMax = max(intMax, pAdd);
    else
      % pDrop == last_intMax: recompute max
      intMax = max(mag(i+1 : i+Nspan));
    end
    % Equivalent code:
    %   spanMin = min(spanMin,intMax);
    if spanMin > intMax
      spanMin = intMax;
    end
  end
end

end



% -----------------------------------------------------------
function checkrange(value)

if ~isa(value, 'double') || length(value) ~= 2
  error(message('signal:filtresp:magnitude:magnitude_construct:InvalidDimensions'));
end

end

% -----------------------------------------------------------
function lclfilters_listener(this, eventData)

hPrm = getparameter(this, 'magnitude');
if isreal(this)
  enableoption(hPrm, 'zero-phase');
else
  disableoption(hPrm, 'zero-phase');
end

end



%% --------------------------------------------------------------------
function RemoveUserDefinedMask(h)
% Remove user-defined mask, if it exists

if isfield(h,'userdefinedmask')
  % Note: cannot combine these two statements (isfield and ishandle)
  %       since ishandle will return empty when its arg is empty
  if ishghandle(h.userdefinedmask)
    delete(h.userdefinedmask);
  end
end

end


%% --------------------------------------------------------------------
function h = InstallUserDefinedMask(h,this,Hd,m)
% Install user-defined display mask

hUDM = this.UserDefinedMask;
if ~isempty(hUDM) && hUDM.EnableMask
  validateFlag = validate(hUDM);
  if validateFlag
    switch lower(this.MagnitudeDisplay)
      case 'magnitude (db)'
        mag = 'db';
      case {'magnitude', 'zero-phase'}
        mag = 'linear';
      case 'magnitude squared'
        mag = 'squared';
    end
    
    hUDM = copyTheObj(hUDM);
    fs = getmaxfs(Hd);
    if isempty(fs)
      fs = 1;
    end
    
    hUDM.normalizefreq(strcmpi(this.NormalizedFrequency, 'on'), fs*m);
    
    hUDM.MagnitudeUnits = mag;
    h.userdefinedmask = draw(hUDM, h.axes);
    
    xdata = get(h.userdefinedmask, 'XData');
    xlim  = get(h.axes, 'XLim');
    
    % Check that the mask didn't overrun the axes.  Add a fudge factor.
    if any(xdata > xlim(2)*1.01) || any(xdata < xlim(1))
      warning(message('signal:filtresp:magnitude:objspecificdraw:userMaskOutOfRange'));
    end
  else
    warning(message('signal:filtresp:magnitude:objspecificdraw:userMaskInvalidVectors'));
    h.userdefinedmask = [];
  end
else
  h.userdefinedmask = [];
end

end


%% --------------------------------------------------------------------
function h = InstallContextMenu(h,this,hylbl)
% Install the context menu for changing units of the Y-axis.

if ~ishandlefield(this, 'magcsmenu')
  h.magcsmenu = contextmenu(getparameter(this, 'magnitude'), hylbl);
end

end


%% --------------------------------------------------------------------
function [xunits,m,h] = InstallMagPlot(h,this,Hd)
% Compute and plot magnitude filter response
% Set appropriate viewing limits

if ~isempty(Hd)
  % One or more filter responses to view
  %
  [H,W] = ComputeMagResponse(h,this,Hd);
  
  % Normalize frequency axis, and draw response
  %
  [W, m, xunits] = normalize_w(this, W);
  if ishandlefield(this,'line') && length(h.line) == size(H{1}, 2)
    for indx = 1:size(H{1}, 2)
      set(h.line(indx), 'XData',W{1}, 'YData',H{1}(:,indx));
    end
  else
    h.line = freqplotter(h.axes, W, H, xunits, this.FrequencyScale);
  end
  
else
  % No filters to view - use defaults:
  %
  xunits = '';
  m      = 1;
  h.line = [];
end

% Store the engineering units factor, even if Hd is empty:
setappdata(h.axes, 'EngUnitsFactor', m);

end


%% --------------------------------------------------------------------
function hylbl = InstallYLabel(h,this)
%Compute y-axis label for display

ylbl = this.MagnitudeDisplay;

if strcmpi(ylbl,'zero-phase')
  ylbl = 'Amplitude';
end
if strcmpi(this.NormalizeMagnitude,'on')
  switch lower(this.MagnitudeDisplay)
    case {'magnitude','magnitude squared','zero-phase'}
      ylbl = sprintf('%s (normalized to 1)', ylbl);
    case 'magnitude (db)'
      ylbl = sprintf('%s (normalized to 0 dB)', ylbl);
  end
end
% Set the new y-axis label into display:
hylbl = ylabel(h.axes, getTranslatedString('signal:sigtools:filtresp',ylbl));

end

%% --------------------------------------------------------------------
function [H,W] = ComputeMagResponse(~,this,Hd)
% Compute desired magnitude response of Hd

opts = getoptions(this);
optsstruct.showref  = showref(this.FilterUtils);
optsstruct.showpoly = showpoly(this.FilterUtils);
optsstruct.sosview  = this.SOSViewOpts;

if strcmp(this.NormalizedFrequency,'on') 
    optsstruct.NormalizedFrequency = true;
else
    optsstruct.NormalizedFrequency = false;
end

% Compute main response function
%
if strcmpi(this.MagnitudeDisplay,'zero-phase')
  [H, W] = zerophase(Hd, opts{:}, optsstruct);
else
  [H, W] = freqz(Hd, opts{:}, optsstruct);
end

% Normalize magnitude response
%
if strcmpi(this.NormalizeMagnitude, 'on')
  for indx = 1:length(H)
    H{indx} = H{indx}/max(H{indx}(:));
  end
end

% Compute desired response curve
%
switch lower(this.MagnitudeDisplay)
  case 'magnitude'
    for indx = 1:length(H)
      H{indx} = abs(H{indx});
    end
  case 'magnitude squared'
    for indx = 1:length(H)
      H{indx} = convert2sq(abs(H{indx}));
    end
  case 'magnitude (db)'
    for indx = 1:length(H)
      H{indx} = convert2db(H{indx});
    end
  case 'zero-phase'
    % NO OP
end

end



% -------------------------------------------------------------------------
function h = drawfdesignmask(this)

Hd = this.Filters;
fs = Hd(1).Fs;

if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on')
  fs = 2;
end

m = getappdata(this.Handles.axes, 'EngUnitsFactor');

fs = fs*m;

switch lower(this.MagnitudeDisplay)
  case 'magnitude'
    units = 'linear';
  case 'zero-phase'
    units = 'zerophase';
  case 'magnitude (db)'
    units = 'db';
  case 'magnitude squared'
    units = 'squared';
end

if strcmpi(this.NormalizeMagnitude, 'on')
  normflag = {'normalize'};
else
  normflag = {};
end

% Get lower x-axis limit in case of log scale so that we can draw the mask
% at this starting point (zero is no a valid satarting point for log
% scale).
hdls = this.Handles;
scale = this.FrequencyScale;
if strcmpi(scale, 'log')
  xlim  = get(hdls.axes, 'XLim');
  xdata = get(hdls.line, 'XData');
  if ~iscell(xdata)
    xdata = {xdata};
  end
  minx = zeros(length(xdata),1);
  for indx = 1:length(xdata)
    xdata{indx}(xdata{indx} == 0) = [];
    minx(indx) = min(xdata{indx});
  end
  xlim = [min(minx) xlim(2)];
else
  xlim = [];
end

h = drawmask(Hd(1).Filter, getbottomaxes(this), units, fs, ...
  normflag{:},scale,xlim);

if strcmpi(units, 'zerophase')
  ydata = get(this.Handles.line, 'YData');
  if ~iscell(ydata) && abs(min(ydata)) > abs(max(ydata))
    mask_ydata = get(h, 'YData');
    if any(mask_ydata > 0)
      set(h, 'YData', -get(h, 'YData'))
    end
  end
end

end

% -------------------------------------------------------------------------
function h = drawfiltdesmask(this)

Hd = this.Filters;

fs = Hd.Fs;
mi = Hd.Filter.MaskInfo;
if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on')
  fs = 2;
  mi.frequnit = 'Hz'; % Fool it into using 2 Hz so it looks normalized
end

% Convert the frequency depending on the new frequency.
for indx = 1:length(mi.bands)
  mi.bands{indx}.frequency = mi.bands{indx}.frequency*fs/mi.fs;
end
mi.fs = fs;

h = info2mask(mi, getbottomaxes(this));

end
