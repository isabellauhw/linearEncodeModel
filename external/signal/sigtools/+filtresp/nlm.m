classdef (Abstract) nlm < sigresp.freqaxiswnfft & sigio.dyproputil & hgsetget
  %filtresp.nlm class
  %   filtresp.nlm extends sigresp.freqaxiswnfft.
  %
  %    filtresp.nlm properties:
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
  %       NumberOfTrials - Property is of type 'double'
  %
  %    filtresp.nlm methods:
  %       checkfilters -   Returns the valid filter indices.
  %       createnfftprm - Create an nfft parameter object.
  %       enablemask - Returns true if the object supports masks.
  %       freqmode_listener - Listener for the freqmode parameter
  %       getlegendstrings - Returns the legend strings
  %       getlineorder -   Return the line order.
  %       getlinestyle -   Get the linestyle.
  %       getnffttag - Return string/tag for the nfft object.
  %       objspecificdraw - Draw the NOISEPOWERSPECTRUM
  %       setmontecarlo -   Set Function for the number of trials.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %NUMBEROFTRIALS Property is of type 'double'
    NumberOfTrials
    IsOverlayedOn = false;
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %FILTERUTILS Property is of type 'filtresp.filterutils'
    FilterUtils = [];
    %FILTERINDICES Property is of type 'mxArray'
    FilterIndices = [  ];        
  end
  
  
  methods
    function value = get.NumberOfTrials(obj)
      value = getmontecarlo(obj,obj.NumberOfTrials);
    end
    function set.NumberOfTrials(obj,value)
      % DataType = 'double'
      validateattributes(value,{'double'}, {'scalar'},'','NumberOfTrials')
      obj.NumberOfTrials = setmontecarlo(obj,value);
    end
    
    function set.FilterUtils(obj,value)
      % DataType = 'filtresp.filterutils'
      validateattributes(value,{'filtresp.filterutils'}, {'scalar'},'','FilterUtils')
      obj.FilterUtils = value;
    end
    
    function set.FilterIndices(obj,value)
      obj.FilterIndices = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function [indices, mssgObj] = checkfilters(this)
      %CHECKFILTERS   Returns the valid filter indices.
      
      Hd = this.Filters;
      
      indices = [];
      unsupportedSysObjCounter = 0;
      multirateObjCounter = 0;
      
      % If we find 1 dfilt or 1 qfilt,or 1 supported System object, then the analysis can work
      for indx = 1:length(Hd)
        if isa(Hd(indx).Filter,'mfilt.abstractmultirate') || isa(Hd(indx).Filter,'mfilt.cascade')
          multirateObjCounter = multirateObjCounter+1;
        elseif isprop(Hd(indx).Filter,'FromSysObjFlag') && Hd(indx).Filter.FromSysObjFlag
          if ~Hd(indx).Filter.SupportsNLMethods && ~isa(Hd(indx).Filter,'mfilt.abstractmultirate')
            unsupportedSysObjCounter = unsupportedSysObjCounter+1;
          else
            indices = [indices indx];
          end
        elseif (isa(Hd(indx).Filter, 'dfilt.singleton') ...
            || (isa(Hd(indx).Filter, 'dfilt.multistage') && ~isa(Hd(indx).Filter, 'mfilt.multistage'))...
            || isa(Hd(indx).Filter, 'qfilt') ...
            || isa(Hd(indx).Filter, 'dfilt.abstractfarrowfd'))
          indices = [indices indx]; %#ok<*AGROW>
        end
      end
      
      if isprop(Hd(indx).Filter,'FromFilterBuilderFlag') && Hd(indx).Filter.FromFilterBuilderFlag
        mssgObj = [];
      else
        if unsupportedSysObjCounter == length(Hd)
          mssgObj = message('signal:filtresp:nlm:checkfilters:NotSupportedForSysObj',this.Name);
        else
          if isempty(indices) && multirateObjCounter == length(Hd)
            mssgObj = message('signal:filtresp:nlm:checkfilters:OnlySingleRate',this.Name);
          else
            mssgObj = message('signal:filtresp:nlm:checkfilters:NotForSysobjOnlySingleRate',this.Name);
          end
        end
      end
      this.FilterIndices = indices;
      
    end
    
    
    function createnfftprm(hObj, allPrm)
      % CREATENFFTPRM Create an nfft parameter object.
      
      createparameter(hObj, allPrm, 'Number of Points', getnffttag(hObj), [1 1 inf], 512);
      
    end
    
    
    function b = enablemask(hObj)
      %ENABLEMASK Returns true if the object supports masks.
      
      % abstractresp does not support masks.  Only magresp and groupdelay.
      
      b = false;
      
    end
    
    
    function freqmode_listener(this, eventData)
      %FREQMODE_LISTENER Listener for the freqmode parameter
      
      freqaxis_freqmode_listener(this, eventData);
      
      hPrm = getparameter(this, getfreqrangetag(this));
      if isempty(hPrm), return; end
      
      units = getsettings(getparameter(this, 'freqmode'), eventData);
      
      if strcmpi(units, 'on')
        opts = {'[0, pi)', '[0, 2pi)', '[-pi, pi)'};
      else
        opts = {'[0, Fs/2)', '[0, Fs)', '[-Fs/2, Fs/2)'};
      end
      
      setvalidvalues(hPrm, opts);
      
      
    end
    
    
    function strs = getlegendstrings(hObj, varargin)
      %GETLEGENDSTRINGS Returns the legend strings
      
      strs = getlegendstrings(hObj.FilterUtils, varargin{:});
      
      % Remove legends of filters that do not support the analysis
      if isa(hObj.SOSViewOpts,'dspopts.sosview') && ...
          isprop(hObj.SOSViewOpts,'View') && ...
          ~strcmp(hObj.SOSViewOpts.View,'Complete') && ...
          (length(hObj.Filters) == 1) && ...
          isa(hObj.Filters.Filter,'dfilt.abstractsos')
        % Second order sections are only shown when we have a single
        % filter. If this is the case and View is not set to Complete, and
        % the filter is SOS then just use all the legend strings
        return
      end
      
      if ~isempty(hObj.FilterIndices)
        if strcmpi(hObj.ShowReference,'off')
          strs = strs(hObj.FilterIndices);
        else
          legendCounter = 1;
          for filterIndx = 1:length(hObj.Filters)
            isQuantizedAndReferenceStrsAvailable = false;
            hFilter = hObj.Filters(filterIndx).Filter;
            if isa(hFilter,'dfilt.parallel') || isa(hFilter,'dfilt.cascade')
              for idx = 1:nstages(hFilter)
                isQuantizedAndReferenceStrsAvailable = isQuantizedAndReferenceStrsAvailable |...
                  (isprop(hFilter.Stage(idx),'Arithmetic') && ...
                  ~strcmpi(hFilter.Stage(idx).Arithmetic,'double'));
              end
            else
              isQuantizedAndReferenceStrsAvailable = isprop(hObj.Filters(filterIndx).Filter,'Arithmetic') && ...
                ~strcmpi(hObj.Filters(filterIndx).Filter.Arithmetic,'double');
            end
            if isQuantizedAndReferenceStrsAvailable
              legend{filterIndx} = strs([legendCounter legendCounter+1]);
              legendCounter = legendCounter+2;
            else
              legend{filterIndx} = strs(legendCounter);  %#ok<*AGROW>
              legendCounter = legendCounter+1;
            end
          end
          newStrs = {};
          for idx = 1:length(hObj.FilterIndices)
            xx = legend(hObj.FilterIndices(idx));
            newStrs = [newStrs xx{:}];
          end
          strs = newStrs;
        end
      end
      
    end
    
    function order = getlineorder(this, varargin)
      %GETLINEORDER   Return the line order.
      
      order = getlineorder(this.FilterUtils, varargin{:});
      
    end
    
    function s = getlinestyle(this, indx)
      %GETLINESTYLE   Get the linestyle.
      
      s = getlinestyle(this.FilterUtils, indx);
      
    end
    
    
    function tag = getnffttag(hObj)
      % GETNFFTTAG Return string/tag for the nfft object.
      
      tag = 'nfftfornlm';
      
    end
    
    
    function [m, xunits] = objspecificdraw(this)
      %OBJSPECIFICDRAW Draw the NOISEPOWERSPECTRUM
      
      h    = this.Handles;
      opts = getoptions(this);
      
      h.axes = h.axes(end);
      
      Hd = this.Filters;
      
      endx = [];
      for indx = 1:length(Hd)
        if ~isa(Hd(indx).Filter, 'qfilt')
          endx = [endx indx];
        end
      end
      Hd(endx) = [];
      
      if isempty(Hd)
        warning(message('signal:filtresp:nlm:objspecificdraw:onlyQfilt', this.Name));
        h.line = [];
        set(this, 'Handles', h);
        m = 1;
        xunits = '';
        return;
      end
      
      % Calculate the data
      [H, W, P, Nf] = nlm(Hd, opts{1}, this.NumberofTrials, opts{2});
      [W, m, xunits] = normalize_w(this, W);
      
      % Get the subclass to convert it for plotting
      [W, Y] = getplotdata(this, H, W, P, Nf);
      
      % Plot the data
      h.line = freqplotter(h.axes, W, Y);
      
      % Save the handles
      set(this, 'Handles', h);
      
      % Put up the ylabel from the subclass
      ylabel(h.axes, getylabel(this));
      
    end
    
    
    function t = setmontecarlo(this, t)
      %SETMONTECARLO   Set Function for the number of trials.
      
      hPrm = getparameter(this, 'montecarlo');
      if ~isempty(hPrm), setvalue(hPrm, t); end
      
    end
              
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function attachlisteners(this)
      %ATTACHLISTENERS
      
      filtutils = this.FilterUtils;
      
      l(1) = event.proplistener(filtutils, filtutils.findprop('Filters'), 'PostSet', @(s,e)lclfilter_listener(this,e));
      l(2) = event.proplistener(filtutils, filtutils.findprop('SOSViewOpts'), 'PostSet', @(s,e)sosview_listener(this,e));
      l(3) = event.proplistener(filtutils, filtutils.findprop('PolyphaseView') ,'PostSet', @(s,e)lclshow_listener(this,e));
      l(4) = event.proplistener(filtutils, filtutils.findprop('ShowReference') ,'PostSet', @(s,e)lclshow_listener(this,e));
      
      set(this, 'WhenRenderedListeners', l);
      
      attachfilterlisteners(this);
      
    end
    
    function formataxislimits(this)
      %FORMATAXISLIMITS
      
      h = this.Handles;
      
      ydata = get(h.line, 'YData');
      xdata = get(h.line, 'XData');
      
      if isempty(ydata)
        return;
      end
      
      % Display of magnitude is always in dB
      
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
        
        % Estimate y-limits for dB plots
        thisYlim = freqzlim_dB(thisMag);
        
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
    
    
    function fs = getmaxfs(this)
      %GETMAXFS
      fs = this.FilterUtils.getmaxfs;
      
    end
    
    function hPrm = getxaxisparams(hObj)
      %GETXAXISPARAMS
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      hPrm = hObj.Parameters;
      
      hPrm = find(hPrm, 'tag', 'unitcirclewnofreqvec','-or', ...
        'tag', 'nfftfornlm', '-or', ...
        'tag', 'freqmode', '-or', ...
        'tag', 'frequnits', '-or', ...
        'tag', 'montecarlo', '-or', ...
        'tag', 'freqscale');
      
    end
    
    
    function nlm_construct(hObj, varargin)
      %NLM_CONSTRUCT
      
      allPrm = hObj.freqaxiswnfft_construct(varargin{:});
      hObj.FilterUtils = filtresp.filterutils(varargin{:});
      findclass(findpackage('dspopts'), 'sosview'); % g 227896
      addprops(hObj, hObj.FilterUtils);
      
      createparameter(hObj, allPrm, 'Number of Trials', 'montecarlo', [1 1 inf], 12);
      
      % You cannot disable the nfft.  make sure the frequencyresp superclass
      % did not do it.
      d = hObj.DisabledParameters;
      indx = strcmpi(d, 'nfft');
      if ~isempty(indx)
        d(indx) = [];
        set(hObj, 'DisabledParameters', d);
      end
      
    end
           
    %----------------------------------------------------------------------
    function filtrespShowUpdate(this,~)
      
      deletehandle(this, 'Legend');
            
      captureanddraw(this, 'both');
      
      % Make sure that we put up the legend after so that it is on top of the
      % plotting axes.
      updatelegend(this);

    end  
    
    %----------------------------------------------------------------------
    function filtrespFiltUpdate(this, ~, varargin)
      
      attachfilterlisteners(this);
      
            
      % When the filters change the legend may be invalid.  Delete it to
      % force an update.
      h = this.Handles;           
      if isfield(h, 'legend') && ishghandle(h.legend)
        % We are going to delete the legend and hence set the legend
        % property to 'Off' so keep the actual legend value and set it
        % again after deletion.
        legendState = this.Legend;
        delete(h.legend);      
        this.Legend = legendState;
      end
            
      draw(this, varargin{:});
      
      % Make sure that we put up the legend after so that it is on top of
      % the plotting axes.
      updatelegend(this);
            
    end
    
    % ----------------------------------------------------------
    function attachfilterlisteners(this)
      
      l = this.WhenRenderedListeners;
      l = l(1:4);
      
      Hd = this.Filters;
      if ~isempty(Hd)
        l(end+1) = event.listener(Hd, 'NewFs', @(s,e)fs_listener(this,e));
        l(end+1) = event.proplistener(Hd, Hd(1).findprop('Name'), 'PostSet', @(s,e)name_listener(this,e));
      end
      
      set(this, 'WhenRenderedListeners', l);
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = getmontecarlo(hObj, out) %#ok<INUSD>

hPrm = getparameter(hObj, 'montecarlo');
if ~isempty(hPrm)
  out = get(hPrm, 'Value');
else
  out = '';
end
end  % getmontecarlo



% ----------------------------------------------------------
function sosview_listener(this, eventData)

Hd = this.Filters;
if length(Hd) == 1
  if isa(Hd.Filter, 'dfilt.abstractsos')
    lclshow_listener(this, eventData);
  end
end

end

% ----------------------------------------------------------
function lclshow_listener(this, ~)

if ~this.IsOverlayedOn
    
  filtrespShowUpdate(this);
  
end


end

% ---------------------------------------------------------------------
function lclfilter_listener(this, eventData, varargin)

if ~this.IsOverlayedOn    
  filtrespFiltUpdate(this,eventData,varargin{:});  
end

end

% ---------------------------------------------------------------------
function name_listener(this, ~)

if ishandlefield(this, 'legend')
  h = this.Handles;
  delete(h.legend);
end

updatelegend(this);

end

% ---------------------------------------------------------------------
function fs_listener(this, ~, varargin)

if ~this.IsOverlayedOn    
  filtrespFsUpdate(this);
end

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
magf(~isfinite(magf))=[];
dr = max(magf)-min(magf);  % "modified" dynamic range

% Handle the null case.
if isempty(dr)
  ylim = [0 1];
  return;
end

% Length of sliding window to compute "localized maxima" values
% We're looking for the MINIMUM of the ENVELOPE of the input curve (mag).
% The true envelope is difficult to compute due as it is positive-only
% The length of the sliding window is important:
%  - too long: envelope estimate is biased toward "global max"
%              and we lose accuracy of envelope minimum
%  - too short: we fall into "nulls" and we're no longer tracking envelope
%
% Set window to 5% of input length, minimum of 3 samples
Nspan = max(3, ceil(0.1*numel(mag)));

% Compute mag envelope, derive y-limit estimates
env  = MiniMax(mag, Nspan);
ymin = min(env) - dr*MarginBot;  % Lower by fraction of dynamic range
ymax = max(mag) + dr*MarginTop;  % Raise by fraction of dynamic range
ylim = [ymin ymax];

end

% --------------------------------------------------------------------
function spanMin = MiniMax(mag,Nspan)
%MiniMax Find the minimum of all local maxima, with each
%  maxima computed over NSPAN-length segments of input.

Nele=numel(mag);
if Nele<Nspan
  spanMin = min(mag);
else
  
  
  % General case
  spanMin = max(mag(1:Nspan)); % max computed over first span
  intMax = spanMin;            % interval max computed over all spans
  for i = 1:Nele-Nspan         % already did first span (above!)
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

