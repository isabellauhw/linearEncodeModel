classdef zplane < sigresp.analysisaxis & sigio.dyproputil & hgsetget
  %filtresp.zplane class
  %   filtresp.zplane extends sigresp.analysisaxis.
  %
  %    filtresp.zplane properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %
  %    filtresp.zplane methods:
  %       deletelineswithtag - Deletes the lines based on their tag
  %       enablemask - Returns true if the object supports masks.
  %       thisdraw - Draw the zplane object

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable) 
    IsOverlayedOn = false;
  end

  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %FILTERUTILS Property is of type 'filtresp.filterutils'
    FilterUtils = [];        
  end
  
  
  methods  % constructor block
    function h = zplane(varargin)
      %ZPLANE Construct a zplane object

      h.super_construct(varargin{:});
      h.FilterUtils = filtresp.filterutils(varargin{:});
      addprops(h, h.FilterUtils);
      
      h.Name = getString(message('signal:sigtools:filtresp:PoleZeroPlot'));
      
      
    end  % zplane
    
  end  % constructor block
  
  methods
    function set.FilterUtils(obj,value)
      % DataType = 'filtresp.filterutils'
      validateattributes(value,{'filtresp.filterutils'}, {'scalar'},'','FilterUtils')
      obj.FilterUtils = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function deletelineswithtag(hObj)
      %DELETELINESWITHTAG Deletes the lines based on their tag

      h = hObj.Handles';
      delete(findobj(h.axes, 'type', 'line', 'tag', getlinetag(hObj)));
      delete(findobj(h.axes, 'tag', 'zplane_unitcircle'));
      
    end
    
    function b = enablemask(hObj)
      %ENABLEMASK Returns true if the object supports masks.

      % abstractresp does not support masks.  Only magresp and groupdelay.
      
      b = false;
      
    end
    
    function thisdraw(this)
      %THISDRAW Draw the zplane object

      Hd = this.Filters;
      
      h = this.Handles';
      h.axes = h.axes(end);
      
      if isempty(Hd)
        z = {[]};
        p = {[]};
      else
        opts.showref  = showref(this.FilterUtils);
        opts.showpoly = showpoly(this.FilterUtils);
        opts.sosview  = this.SOSViewOpts;
        
        [z, p] = zplane(Hd, opts);
      end
      
      % Set up the default handles.
      hunit = [];
      hline = [];
      
      % Delete any old unitcircles
      if ishandlefield(this, 'unitcircle')
        delete(h.unitcircle);
      end
      
      delete(getline(this));
      deletelineswithtag(this);
      
      for indx = 1:length(z)
        
        % Delete the unitcircle each time so that we only have 1 at the end
        if ~isempty(hunit), delete(hunit); end
        
        % If there is more than 1 zero vector it must be quantized
        if size(z{indx},2) > 1 && ~(isempty(z{indx}) || isempty(p{indx}))
          marker = {'s', '+', 'o', 'x'};
          % If we have a single row, we need to pad with NaNs to get a matrix
          % for ZPLANEPLOT.  If ZPLANEPLOT sees a row vector it assumes they
          % are all zeros/poles of a double filter, instead of working column
          % wise.
          if size(z{indx}, 1) == 1
            z{indx} = [z{indx}; NaN NaN];
          end
          if size(p{indx}, 1) == 1
            p{indx} = [p{indx}; NaN NaN];
          end
        else
          marker = {'o', 'x'};
        end
        
        % Draw the zplaneplot
        [hz, hp, hunit] = zplaneplot(z{indx}, p{indx}, h.axes, marker);
        
        % Make sure that the color matches the order correctly.
        set([hz, hp], 'Color', getcolorfromindex(h.axes, indx));
        
        hline = [hline hz' hp'];
      end
      
      h.line       = hline;
      h.unitcircle = hunit;
      set(h.unitcircle, 'Tag', 'zplane_unitcircle');
      
      this.Handles = h;
      
      notify(this, 'NewPlot', event.EventData);
      
      % [EOF]
      
    end
                 
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function attachlisteners(this)
      %ATTACHLISTENERS

      filtutils = this.FilterUtils;
      
      l(1) = event.proplistener(filtutils, filtutils.findprop('ShowReference'), 'PostSet', @(s,e)lclfilter_listener(this,e));
      l(2) = event.proplistener(filtutils, filtutils.findprop('PolyphaseView'), 'PostSet', @(s,e)lclfilter_listener(this,e));
      l(3) = event.proplistener(filtutils, filtutils.findprop('Filters'),       'PostSet', @(s,e)lclfilter_listener(this,e));
      l(4) = event.proplistener(filtutils, filtutils.findprop('SOSViewOpts'),   'PostSet', @(s,e)sosview_listener(this,e));
      
      this.WhenRenderedListeners = l;
      
    end
    
    function formataxislimits(this)
      %FORMATAXISLIMITS

      % This is a NO OP for the zplane plot.  We need to use MATLAB's ylimit code
      % here because we are using a square aspect ratio to make the unit circle
      % look like a circle instead of an ellipse.
      
      % [EOF]
      
    end
    
    function allstr = getlegendstrings(this)
      %GETLEGENDSTRINGS

      allstr = {};
      
      Hd = this.Filters;
      
      if isempty(Hd)
        return;
      elseif length(Hd) == 1 && ...
          ~isempty(this.SOSViewOpts) && ...
          isa(Hd(1).Filter, 'dfilt.abstractsos')
        
        name = get(Hd, 'Name');
        if isempty(name)
          name = 'Filter #1';
        end
        
        names = getnames(this.SOSViewOpts, Hd.Filter);
        for indx = 1:length(names)
          if isquantized(Hd.Filter) && showref(this.FilterUtils)
            allstr{end+1} = getString(message('signal:sigtools:filtresp:QuantizedZero', name, names{indx}));
            allstr{end+1} = getString(message('signal:sigtools:filtresp:ReferenceZero', name, names{indx}));
            allstr{end+1} = getString(message('signal:sigtools:filtresp:QuantizedPole', name, names{indx}));
            allstr{end+1} = getString(message('signal:sigtools:filtresp:ReferencePole', name, names{indx}));
          else
            allstr{end+1} = getString(message('signal:sigtools:filtresp:Zero', name, names{indx}));
            allstr{end+1} = getString(message('signal:sigtools:filtresp:Pole', name, names{indx}));
          end
        end
        return;
      end
      
      str = usesaxes_getlegendstrings(this);
      sndx = 0;
      
      for indx = 1:length(Hd)
        cFilt = Hd(indx).Filter;
        if ispolyphase(cFilt) && showpoly(this.FilterUtils)
          
          sndx = sndx + 1;
          for jndx = 1:npolyphase(cFilt)
            allstr{end+1} = getString(message('signal:sigtools:filtresp:Polyphase1numberintegerZero', str{sndx}, jndx));
            allstr{end+1} = getString(message('signal:sigtools:filtresp:Polyphase1numberintegerPole', str{sndx}, jndx));
          end
        elseif isquantized(cFilt) && showref(this.FilterUtils)
          sndx = sndx + 2;
          allstr{end+1} = getString(message('signal:sigtools:filtresp:Zero_1', str{sndx-1}));
          allstr{end+1} = getString(message('signal:sigtools:filtresp:Zero_1', str{sndx}));
          allstr{end+1} = getString(message('signal:sigtools:filtresp:Pole_1', str{sndx-1}));
          allstr{end+1} = getString(message('signal:sigtools:filtresp:Pole_1', str{sndx}));
        else
          sndx = sndx + 1;
          allstr{end+1} = getString(message('signal:sigtools:filtresp:Zero_2', str{sndx}));
          allstr{end+1} = getString(message('signal:sigtools:filtresp:Pole_2', str{sndx}));
        end
      end
      
      % [EOF]
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

% ----------------------------------------------------------
function sosview_listener(this, eventData)

Hd = this.Filters;
if length(Hd) == 1
  if isa(Hd.Filter, 'dfilt.abstractsos')
    lclfilter_listener(this, eventData);
  end
end

end

% ----------------------------------------------------------
function lclfilter_listener(this, ~)

captureanddraw(this, 'both');

end
