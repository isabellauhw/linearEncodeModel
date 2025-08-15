classdef noisemagnitude < filtresp.nlm 
  %filtresp.noisemagnitude class
  %   filtresp.noisemagnitude extends filtresp.nlm.
  %
  %    filtresp.noisemagnitude properties:
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
  %       DisplayMask - Property is of type 'on/off'
  %
  %    filtresp.noisemagnitude methods:
  %       enablemask - Returns true if the mask can be drawn.
  %       getkeyhandles - GETh   Returns the "key" handles.
  %       getparameter -   Get the parameter.
  %       getplotdata - Return the data to plot
  %       getylabel - Returns the YLabel string
  %       objspecificdraw - Draw the NOISEPOWERSPECTRUM
  %       setmontecarlo -   Set the NumberOfTrials.
  %       updatemasks - Draw the masks onto the bottom axes

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %DISPLAYMASK Property is of type 'on/off'
    DisplayMask = 'off';
  end
  
  
  methods  % constructor block
    function h = noisemagnitude(varargin)
      %NOISEMAGNITUDE Construct a noisemagresp object

      h.nlm_construct(varargin{:});
      
      set(h, 'Name', legendstring(h));
      
      
    end  % noisemagnitude
    
  end  % constructor block
  
  methods
    function value = get.DisplayMask(obj)
      value = getdisplaymask(obj,obj.DisplayMask);
    end
    function set.DisplayMask(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','DisplayMask');
      obj.DisplayMask = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
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
          b(indx) = false;
        else
          
          % If the specification are equivalent (meaning the 'Specification'
          % is the same and all of the settings are the same) and all of the
          % methods used are constrained, we can show the masks.
          if isequivalent(hfd, hfdfirst) && ...
              hfm.isconstrained == hfmfirst.isconstrained
            b(indx) = true;
          else
            b(indx) = false;
          end
        end
      end
      
      b = all(b);
      
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
    
    function hPrm = getparameter(this, varargin)
      %GETPARAMETER   Get the parameter.

      hPrm = abstract_getparameter(this, varargin{:});
      if nargin < 2 || ~strcmpi(varargin{1}, '-all') && ~isempty(hPrm) && nargin == 1
        %Only return plottype if it was asked for
        hPrm = find(hPrm, '-not', 'tag', 'montecarlo');
      end
      
    end
    
    function [W, H] = getplotdata(hObj, H, W, P, Nf)
      %GETPLOTDATA Return the data to plot

      for indx = 1:length(H)
        H{indx} = convert2db(H{indx});
      end
      
    end
    
    
    function ylbl = getylabel(hObj)
      %GETYLABEL Returns the YLabel string

      ylbl = getString(message('signal:sigtools:filtresp:MagnitudedB'));
      
      
    end
    
    
    function [m, xunits] = objspecificdraw(this)
      %OBJSPECIFICDRAW Draw the NOISEPOWERSPECTRUM

      h              = this.Handles;
      h.axes         = h.axes(end);
      [indices, mssgObj] = checkfilters(this);
      if isempty(indices)
        if ~isempty(this.Filters) && ~isempty(mssgObj)
          warning(mssgObj)
        end
        
        % Make sure we remove the old line from the structure.
        h.line = [];
        set(this, 'Handles', h);
        m      = 1;
        xunits = '';
        return;
      end
      
      Hd = this.Filters;
      Hd = Hd(indices);
      
      opts = uddpvparse('dspopts.pseudospectrum', 'NFFT', this.NumberOfPoints);
      
      switch lower(this.FrequencyRange)
        case {'[0, pi)', '[0, fs/2)'}
          opts.SpectrumRange = 'half';
        case {'[0, 2pi)', '[0, fs)'}
          opts.SpectrumRange = 'whole';
        case {'[-pi, pi)', '[-fs/2, fs/2)'}
          opts.SpectrumRange = 'whole';
          opts.CenterDC      = true;
      end
      
      optsstruct.sosview = this.SOSViewOpts;
      optsstruct.showref = strcmpi(this.ShowReference, 'on');
      
      [H, W] = freqrespest(Hd, this.NumberOfTrials, opts, optsstruct);
      
      [~, wid] = lastwarn;
      if any(strcmpi(wid, {'fixed:fi:underflow', 'fixed:fi:overflow'}))
        lastwarn('');
      end
      
      % Calculate the data
      [W, m, xunits] = normalize_w(this, W);
      
      % Plot the data
      if ishandlefield(this,'line') && length(h.line) == size(H{1}, 2)
        for indx = 1:size(H{1}, 2)
          set(h.line(indx), 'XData',W{1}, 'YData',H{1}(:,indx));
        end
      else
        h.line = freqplotter(h.axes, W, H);
      end
      
      % Save the handles
      set(this, 'Handles', h);
      
      % Put up the ylabel from the subclass
      ylabel(h.axes, getString(message('signal:sigtools:filtresp:MagnitudedB')));
      
      updatemasks(this);
      
      % [EOF]
      
      
    end
    
    function t = setmontecarlo(this, t)
      %SETMONTECARLO   Set the NumberOfTrials.

      warning(message('signal:filtresp:noisemagnitude:setmontecarlo:deprecatedFeature'));
      
      
    end
    
    function updatemasks(this)
      %UPDATEMASKS Draw the masks onto the bottom axes

      h = this.Handles;
      
      if isfield(h, 'masks')
        h.masks(~ishghandle(h.masks)) = [];
        delete(h.masks);
      end
      
      Hd = this.Filters;
      if  ~isempty(Hd) && strcmpi(this.DisplayMask, 'On') && ...
          ~(isa(Hd(1).Filter, 'dfilt.abstractsos') && ...
          ~isempty(this.SOSViewOpts) && ...
          ~strcmpi(this.SOSViewOpts.View, 'Complete'))
        
        fs = Hd(1).Fs;
        
        if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on')
          fs = 2;
        end
        
        m = getappdata(this.Handles.axes, 'EngUnitsFactor');
        
        % Get lower x-axis limit in case of log scale so that we can draw the
        % mask at this starting point (zero is no a valid satarting point for
        % log scale).
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
        
        h.masks = drawmask(Hd(1).Filter, getbottomaxes(this), 'db', fs*m, ...
          scale,xlim);
        
      else
        h.masks = [];
      end
      
      % Make sure that HitTest is turned off so that the data markers on the
      % response line work smoothly.
      set(h.masks, 'HitTest', 'Off');
      set(this, 'Handles', h);

    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function attachlisteners(this)
      %ATTACHLISTENERS
      filtutils = this.FilterUtils;
      l(1) = event.proplistener(this, this.findprop('DisplayMask'),            'PostSet', @(s,e)lcldisplaymask_listener(this,e));
      l(2) = event.proplistener(filtutils, filtutils.findprop('Filters'),      'PostSet', @(s,e)lclfilter_listener(this,e));
      l(3) = event.proplistener(filtutils, filtutils.findprop('SOSViewOpts') , 'PostSet', @(s,e)sosview_listener(this,e));
      l(4) = event.proplistener(filtutils, filtutils.findprop('PolyphaseView'),'PostSet', @(s,e)lclshow_listener(this,e));
      l(5) = event.proplistener(filtutils, filtutils.findprop('ShowReference'),'PostSet', @(s,e)lclshow_listener(this,e));
      
      set(this, 'WhenRenderedListeners', l);
      
      attachfilterlisteners(this);
      
    end
    
    
    function s = legendstring(hObj)
      %LEGENDSTRING

      s = getString(message('signal:sigtools:filtresp:MagnitudeResponseEst'));
      
    end
    
    function filtrespShowUpdate(this,~)
      
      deletehandle(this, 'Legend');
      
      captureanddraw(this, 'both');
      
      % Make sure that we put up the legend after so that it is on top of the
      % plotting axes.
      updatelegend(this);
      
    end
    
    % ----------------------------------------------------------
    function attachfilterlisteners(this)
      
      l = this.WhenRenderedListeners;
      l = l(1:5);
      
      Hd = this.Filters;
      if ~isempty(Hd)
        l(end+1) = event.listener(Hd, 'NewFs', @(s,e)fs_listener(this,e));
        l(end+1) = event.proplistener(Hd, Hd(1).findprop('Name'), 'PostSet', @(s,e)name_listener(this,e));
      end
      
      set(this, 'WhenRenderedListeners', l);
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = getdisplaymask(hObj, out)

if ~enablemask(hObj)
  out = 'off';
end
end  % getdisplaymask


% ----------------------------------------------------------
function lcldisplaymask_listener(this, eventData)

updatemasks(this);
end

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


% [EOF]
