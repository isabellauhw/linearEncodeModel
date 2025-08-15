classdef (Abstract) analysisaxis < sigresp.abstractanalysis
  %sigresp.analysisaxis class
  %   sigresp.analysisaxis extends sigresp.abstractanalysis.
  %
  %    sigresp.analysisaxis properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %
  %    sigresp.analysisaxis methods:
  %       analysisaxis_visible_listener - Make sure that the title is visible off.
  %       captureanddraw -   Capture the zoom state and redraw.
  %       copyaxes - Copy the axes to a new figure
  %       deletehandle -   Delete the handle
  %       deletelineswithtag - Deletes the lines based on their tag
  %       draw - Sets up the axis for drawing.
  %       getanalysisdata - Return the analysis data
  %       getbottomaxes - Returns the axes on the bottom
  %       getkeyhandles - Returns the handles to the objects which will cause an
  %       getlegendstrings - Returns the legend strings
  %       getline - Returns the line handles
  %       getlinecolor - Returns the line color and style order
  %       getlineorder - Returns the line order
  %       getlinestyle - Returns the line style order
  %       getlinetag - Returns the tag used for the line
  %       gettopaxes - Returns the axes on the top
  %       getxparams -   Returns the param tags that affect the x-zoom.
  %       getyparams -   Returns the parameter tags that affect the y-zoom.
  %       legend -   Turn on the legend
  %       objspecificunrender - Let the subclasses perform their unrender actions.
  %       print - Print the response
  %       printpreview - Print the filter response
  %       setlineprops - Adds the datamarker callbacks, visibility, and tag.
  %       setunits -   Set the units of the contained objects.
  %       thisrender - Render and draw the analysis
  %       thisunrender - Unrenders the analysis axis specific stuff.
  %       updategrid - Syncs axis grid with the grid property.
  %       updatelegend - Update the legend
  %       updatetitle - Update the title on the axes
  %       usesaxes_getlegendstrings - Returns the legend strings
  %       usesaxes_visible_listener - Make sure that the title is visible off.
  %       visible_listener - Make sure that the title is visible off.
  
  %   Copyright 2015-2019 The MathWorks, Inc.

  
  properties (AbortSet, SetObservable, GetObservable)
    %LEGEND Property is of type 'on/off'
    Legend = 'off';
    %GRID Property is of type 'on/off'
    Grid = 'on';
    %TITLE Property is of type 'on/off'
    Title = 'on';
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %OBDLISTENER Property is of type 'mxArray'
    OBDListener = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %LEGENDPOSITION Property is of type 'mxArray'
    LegendPosition = 'Best';
  end
  
  
  methods
    function set.Legend(obj,value)
      % DataType = 'on/off'
      if ~isa(value, 'matlab.lang.OnOffSwitchState')
        validatestring(value,{'on','off'},'','Legend');
      end
      obj.Legend = value;
    end
    
    function set.Grid(obj,value)
      % DataType = 'on/off'
      if ~isa(value, 'matlab.lang.OnOffSwitchState')
        validatestring(value,{'on','off'},'','Grid');
      end
      obj.Grid = value;
    end
    
    function set.Title(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Title');
      obj.Title = value;
    end
    
    function set.OBDListener(obj,value)
      obj.OBDListener = value;
    end
    
    function set.LegendPosition(obj,value)
      obj.LegendPosition = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function analysisaxis_visible_listener(this, eventData)
      %ANALYSISAXIS_VISIBLE_LISTENER Make sure that the title is visible off.
      
      siggui_visible_listener(this, eventData);
      
      if strcmpi(get(this, 'Visible'), 'on')
        
        ht = get(getbottomaxes(this), 'Title');
        
        set(ht, 'Visible', get(this, 'Title'));
        
        updatelegend(this);
      end
      
    end
    
    function captureanddraw(this, limits)
      %CAPTUREANDDRAW   Capture the zoom state and redraw.
      %   CAPTUREANDDRAW(THIS, LIMITS) Capture the zoomstate, redraw and set the
      %   zoom state back.  LIMITS can be 'x', 'y', 'both', or 'none'.  It is
      %   'both' by default.  When it is 'x' it will zoom back in on the x-axis,
      %   when it is 'y' it will zoom back in on the y-axis.
      
      if nargin < 2, limits = 'both'; end
      
      if isprop(this,'Handles')
        
        % Cache the current positions.
        h = get(this, 'Handles');
        
        % Redraw the plot.  This will reset the zoom state and cache the "smart
        % zoom" state as the zoom out point.
        draw(this);
        
        for indx = 1:length(h.axes)
          xlim{indx} = get(h.axes(indx), 'XLim'); %#ok
          ylim{indx} = get(h.axes(indx), 'YLim'); %#ok
        end
        
        
        % Reget the handles in case any axes were replaced (unlikely).
        h = get(this, 'Handles');
        for indx = 1:length(h.axes)
          
          switch lower(limits)
            case 'x'
              set(h.axes(indx), 'XLim', xlim{indx});
            case 'y'
              set(h.axes(indx), 'YLim', ylim{indx});
            case 'both'
              set(h.axes(indx), 'XLim', xlim{indx}, 'YLim', ylim{indx});
            case 'none'
              % NO OP
            otherwise
              error(message('signal:sigresp:analysisaxis:captureanddraw:InvalidInput', limits));
          end
        end
        
      end
      
    end
    
    function hax = copyaxes(this, varargin)
      %COPYAXES Copy the axes to a new figure
      
      % Check if there are any markers on the source figure and set up the figure
      % to copy those.
      hFigOld = ancestor(this.Parent, 'figure');
      
      hax = sigutils.copyAxes(hFigOld, @(hOld, hNew) lclCopyAxes(this, hNew), varargin{:});
      
    end
    
    function deletehandle(this, field)
      %DELETEHANDLE   Delete the handle
      
      if isprop(this,'Handles')        
        h = get(this, 'Handles');
        
        % If the field is not valid, do nothing.
        if isfield(h, field)
          
          % Make sure we don't fire any of the listeners.
          if isa(this.OBDListener, 'handle.listener')
            l = get(this, 'OBDListener');
          else
            l = [];
          end
          
          set(l, 'Enabled', 'Off');
          
          % If the field contains a valid handle delete it.
          if ishghandle(h.(field))
            if strcmpi(field, 'legend')
              delete(getappdata(h.legend, 'OBD_Listener'));
            end
            
            delete(h.(field));
          end
          
          % Remove the field from the object's handle structure.
          h = rmfield(h, field);
          
          set(this, 'Handles', h);
          set(l, 'Enabled', 'On');
        end
      end      
      
    end
    
    
    function deletelineswithtag(hObj)
      %DELETELINESWITHTAG Deletes the lines based on their tag
      
      h = get(hObj, 'Handles');
      delete(findobj(h.axes, 'tag', getlinetag(hObj)));
      
      
    end
    
    
    function varargout = draw(this, varargin)
      %DRAW Sets up the axis for drawing.
      
      fupdate = strcmpi(this.FastUpdate, 'Off');
      
      if isa(this.OBDListener, 'handle.listener') || isa(this.OBDListener, 'event.listener')
        delete(this.OBDListener);
      end
      
      w = warning('off');
      
      if fupdate
        [wstr, wid] = lastwarn('');
        deletelineswithtag(this);
        
        % Set the zoomstate to none to restore the context menus before adding new
        % ones.
        setzoomstate(this.FigureHandle, 'none');
      end
      
      % Set the Axes specific properties
      setaxesprops(this);
      
      try
        if nargout
          [varargout{1:nargout}] = thisdraw(this, varargin{:});
        else
          thisdraw(this, varargin{:});
        end
      catch ME
        
        % If we error out, make sure we don't have any lines on the plot.
        h = get(this, 'Handles');
        for indx = 1:length(h.axes)
          delete(allchild(h.axes(indx)));
        end
        h.line = [];
        set(this, 'Handles', h);
        senderror(this, ME.identifier, ME.message);
      end
      
      if fupdate
        
        formataxislimits(this);
        
        % Reset the axes zoom limits.  This will make zoom('out') return to the
        % current x and y lims.
        hAxes = this.Handles.axes;
        if length(hAxes) == 1
          zoom(hAxes, 'reset');
        end
        
        updatetitle(this);
        setlineprops(this);
        
        % Set the zoomstate back to the proper state to eliminate any contextmenus
        % if we are in a positive zoom state.
        setzoomstate(this.FigureHandle);
        
        sendwarning(this);
        lastwarn(wstr, wid);
        
        notify(this, 'NewPlot', event.EventData);
        
        refresh(this.FigureHandle);
      end
      
      if ishandlefield(this, 'legend')
        hl = this.Handles.legend;
        
        % Remove the listener so that we don't turn off the Legend property by
        % deleting the legend.
        rmappdata(hl, 'OBD_Listener');
        delete(hl);
      end
      updatelegend(this);
      updategrid(this);
      
      warning(w);
      
      % Create a listener on the 'ObjectBeingDestroyed' event of the 'key'
      % handles.  When any of these handles are destroyed the entire object will
      % unrender.
      hKey = getkeyhandles(this);
      for indx = 1:length(hKey)
        obdlistener(indx) = uiservices.addlistener(hKey(indx), ...
          'ObjectBeingDestroyed', @(h,ev) obd_listener(this));
      end
      this.OBDListener = obdlistener;
      
    end
    
    
    function [xdata, ydata] = getanalysisdata(hObj)
      %GETANALYSISDATA Return the analysis data
      
      hline = getline(hObj);
      
      xdata = cell(length(hline), 1);
      ydata = xdata;
      
      for indx = 1:length(hline)
        xdata{indx} = get(hline(indx), 'XData')/getengunitsfactor(get(hline(indx), 'Parent'));
        ydata{indx} = get(hline(indx), 'YData');
      end
      
    end
    
    
    function hax = getbottomaxes(hObj)
      %GETBOTTOMAXES Returns the axes on the bottom
      
      h = get(hObj, 'Handles');
      
      if length(h.axes) == 1
        hax = h.axes;
      else
        order = gethgstackorder(h.axes);
        hax = h.axes(find(order == min(order)));
      end
      
      
    end
    
    
    function h = getkeyhandles(this)
      %GETKEYHANDLES Returns the handles to the objects which will cause an
      %unrender.  When any of these handles are deleted, the entire object will
      %unrender.
      
      h = get(this, 'Handles');
      
      if isfield(h, 'legend')
        h = rmfield(h, 'legend');
      end
      
      h = convert2vector(h);
      
    end
    
    
    function strs = getlegendstrings(this, varargin)
      %GETLEGENDSTRINGS Returns the legend strings
      
      for k = 1:length(getline(this))
        strs{k} = getString(message('signal:sigtools:sigresp:Response0numberinteger',k));
      end
      
    end
    
    function hline = getline(hObj)
      %GETLINE Returns the line handles
      
      if ishandlefield(hObj, 'line')
        h     = get(hObj, 'Handles');
        hline = h.line;
      else
        hline = [];
      end
      
    end
    
    
    function lco = getlinecolor(hObj, lineIndx)
      %GETLINECOLOR Returns the line color and style order
      
      lineOrder = getlineorder(hObj);
      lco = getcolorfromindex(getbottomaxes(hObj), lineOrder(lineIndx));
      
    end
    
    
    function lineOrder = getlineorder(hObj)
      %GETLINEORDER Returns the line order
      
      lineOrder = 1:length(getline(hObj));
      
    end
    
    
    function lso = getlinestyle(hObj, lndx)
      %GETLINESTYLE Returns the line style order
      
      lso = '-';
      
    end
    
    
    function str = getlinetag(hObj)
      %GETLINETAG Returns the tag used for the line
      
      ClassName = regexp(class(hObj),'\.','split');
      ClassName = ClassName{end};
      str = sprintf('%s_line', ClassName);
      
    end
    
    
    function hax = gettopaxes(hObj)
      %GETTOPAXES Returns the axes on the top
      
      h = get(hObj, 'Handles');
      
      if length(h.axes) == 1
        hax = h.axes;
      else
        order = gethgstackorder(h.axes);
        hax = h.axes(find(order == max(order)));
      end
      
    end
    
    
    function xparams = getxparams(this)
      %GETXPARAMS   Returns the param tags that affect the x-zoom.
      
      xparams = {};
      
    end
    
    
    function yparams = getyparams(this)
      %GETYPARAMS   Returns the parameter tags that affect the y-zoom.
      
      yparams = {};
      
    end
    
    
    function legend(this, varargin)
      %LEGEND   Turn on the legend
      
      Hd   = get(this, 'Filters');
      
      % If the 2nd to last input is "location" we assume this is not a filter
      % name as long as the next input matches one of the valid "locations".
      if nargin > 2 & strcmpi(varargin{end-1}, 'location') & ...
          any(strncmpi(varargin{end}, {'North', 'South', 'East', 'West', ...
          'NorthEast', 'NorthWest', 'SouthEast', 'SouthWest', ...
          'NorthOutside', 'SouthOutside', 'EastOutside', 'WestOutside', ...
          'NorthEastOutside', 'NorthWestOutside', 'SouthEastOutside', ...
          'SouthWestOutside', 'Best', 'BestOutside'}, length(varargin{end}))) %#ok
        set(this, 'LegendPosition', varargin{end});
        varargin(end-1:end) = [];
      elseif nargin > 1 & isnumeric(varargin{end}) %#ok
        
        % If the last input is a # it must be the old style legend location.
        set(this, 'LegendPosition', varargin{end});
        varargin(end) = [];
      else
        
        % If we dont have any of these special cases, put the legend in the
        % "best" location given the plots.
        set(this, 'LegendPosition', 'Best');
      end
      
      strs = varargin;
      
      % Warn if more strings are given than there are filters.
      nstr = length(strs);
      if nstr > length(Hd)
        warning(message('signal:sigresp:analysisaxis:legend:TooManyStrings'));
      end
      
      % Assign the strings to the names of the filters.
      for indx = 1:min(nstr,length(Hd))
        set(Hd(indx), 'Name', strs{indx});
      end
      
      % Turn the legend on.
      if strcmpi(this.Legend, 'Off')
        set(this, 'Legend', 'On');
      else
        
        % If it is already on, delete it to force it to refresh.
        deletehandle(this, 'legend');
        updatelegend(this);
      end
      
      
    end
    
    
    function objspecificunrender(hObj)
      %OBJSPECIFICUNRENDER Let the subclasses perform their unrender actions.
      
      % NO OP
      
    end
    
    
    function print(hObj)
      %PRINT Print the response
      
      hax = copyaxes(hObj);
      
      hfig = get(hObj, 'FigureHandle');
      hfig_print = get(hax(1), 'Parent');
      
      setptr(hfig,'watch');        % Set mouse cursor to watch.
      printdlg(hfig_print);
      setptr(hfig,'arrow');        % Reset mouse pointer.
      close(hfig_print);
      
    end
    
    
    function printpreview(hObj)
      %PRINTPREVIEW Print the filter response
      
      hax = copyaxes(hObj);
      
      hfig = get(hax(1), 'Parent');
      
      printpreview(hfig);
      
      delete(hfig);
      
    end
    
    
    function setlineprops(hObj)
      %SETLINEPROPS Adds the datamarker callbacks, visibility, and tag.
      
      analysisaxis_setlineprops(hObj);
      
    end
    
    
    function setunits(this, units)
      %SETUNITS   Set the units of the contained objects.
      
      set(this.Handles.axes, 'Units', units);
      
    end
    
    
    function varargout = thisrender(this, hax, varargin)
      %THISRENDER Render and draw the analysis
      
      createdynamicprops(this);
      
      if nargin == 1
        h.axes = newplot;
      else
        
        % Remove all non handles from the vector.
        hax(~ishghandle(hax)) = [];
        
        % Find the axes
        h.axes = findobj(hax, 'type', 'axes');
        if isempty(h.axes)
          if ishghandle(hax, 'figure')
            
            % If there is no axes on the figure, create a new one.
            h.axes = axes('Parent', hax);
          else
            h.axes = newplot;
          end
        end
      end
      
      hFig = ancestor(h.axes(1), 'figure');
      set(this, 'FigureHandle', hFig);
      
      set(this, 'Handles', h);
      
      if nargout
        [varargout{1:nargout}] = draw(this, varargin{:});
      else
        draw(this, varargin{:});
      end
      
      attachlisteners(this); % Call the method that can be overloaded.
      lclattachlisteners(this, varargin{:}); % Call the local method that cannot be overloaded.
      
    end
    
    function thisunrender(this)
      %THISUNRENDER Unrenders the analysis axis specific stuff.
      
      if isa(this.OBDListener, 'handle.listener') || isa(this.OBDListener, 'event.listener')
        delete(this.OBDListener);
      end
      
      % Make sure that the listeners are deleted so that they do not fire.
      if iscell(this.UsesAxes_WhenRenderedListeners)
        for idx = 1:length(this.UsesAxes_WhenRenderedListeners)
          delete(this.UsesAxes_WhenRenderedListeners{idx});
        end
      else
        delete(get(this, 'UsesAxes_WhenRenderedListeners'));
      end
      
      hRProps = get(this, 'UsesAxes_RenderedPropHandles');
      if isempty(hRProps)
        hRProps = [this.findprop('UsesAxes_WhenRenderedListeners') ...
          this.findprop('UsesAxes_RenderedPropHandles')];
      end
      delete(hRProps);
      
      h = get(this, 'Handles');
      if isfield(h, 'axes')
        
        % Reset the axes
        h.axes(~ishghandle(h.axes)) = [];
        key = 'graphics_linkaxes';
        
        for indx = 1:length(h.axes)
          props = {'XGrid', 'YGrid', 'ColorOrder'};
          values = get(h.axes(indx), props);
          reset(h.axes(indx));
          set(h.axes(indx), props, values)
          
          % Remove the linkaxes listener.  We cannot use linkaxes(h, 'off')
          % because it calls drawnow which results in flicker.
          if isappdata(h.axes(indx), key)
            rmappdata(h.axes(indx), key);
          end
        end
        
        % Remove the axes, since we do not want to unrender this.
        set(this, 'Handles', rmfield(h, 'axes'));
      end
      
      if isfield(h, 'legend')
        if ishghandle(h.legend)
          delete(getappdata(h.legend, 'OBD_Listener'));
        end
      end
      
      % Replace with super:thisunrender.
      delete(handles2vector(this));
      % Unrender all the children
      for hindx = allchild(this)
        unrender(hindx);
      end
      
      objspecificunrender(this);
      
    end
    
    
    function updategrid(hObj)
      %UPDATEGRID Syncs axis grid with the grid property.
      
      hax = getbottomaxes(hObj);
      set(hax, 'XGrid', hObj.Grid, 'YGrid', hObj.Grid);
      
    end
    
    
    function updatelegend(this, varargin)
      %UPDATELEGEND Update the legend
      
      if isprop(this,'Handles')
        
        % We cannot reliably update the legend when the display is invisible
        % because the "best" option does not work when the lines are not visible.
        if strcmpi(this.Visible, 'Off')
          return;
        end
        
        
        h = get(this, 'Handles');
        
        if strcmpi(this.Legend, 'On')
          
          if ~isempty(getline(this))
            
            % Remove the old legend.
            if isfield(h, 'legend') && ishghandle(h.legend)
              rmappdata(h.legend, 'OBD_Listener');
              delete(h.legend);
            end
            
            w = warning('off','signal:sigtools:fvtool:fvtool:useLegendMethod');
            
            [wstr, wid] = lastwarn('');
            
            % Get the legend strings from the object.  The object should know how
            % many lines were required, so this should be a cell array of strings
            % of length equal to the output of GETLINE.
            pos = this.LegendPosition;
            if ischar(pos)
              pos = {'Location', pos};
            else
              pos = {'Location', getLegendLocationFromNumeric(pos)};
            end
            set(getline(this), 'Visible','on');
            hax = gettopaxes(this);
            axes_position = get(hax, 'Position');
            h.legend = legend(gettopaxes(this), getline(this), getlegendstrings(this), pos{:});
            set(hax, 'Position', axes_position);
            
            l = uiservices.addlistener(h.legend, 'ObjectBeingDestroyed', @(h,ev) onLegendBeingDeleted(this));
            setappdata(h.legend, 'OBD_Listener', l);
            setappdata(h.legend, 'zoomable', 'off');
            
            lastwarn(wstr, wid);
            warning(w);
            
            % Make sure that the color matches the bottom axes.
            set(h.legend, 'HandleVisibility', 'Callback', ...
              'Color', get(getbottomaxes(this), 'Color'), 'Visible', this.Visible);
          
            % Make the legend interactive
            matlabshared.internal.InteractiveLegend(h.legend);
            
            set(this, 'Handles', h);
          end
        elseif ishandlefield(this, 'legend')
          delete(h.legend);
        end
      end
      
    end
    
    function updatetitle(hObj)
      %UPDATETITLE Update the title on the axes
      
      ht = title(getbottomaxes(hObj), get(hObj, 'Name'));
      
      if strcmpi(get(hObj, 'Visible'), 'on')
        titleVis = get(hObj, 'Title');
      else
        titleVis = 'off';
      end
      set(ht, 'Visible', titleVis);
      
    end
    
    
    function strs = usesaxes_getlegendstrings(hObj, full)
      %USESAXES_GETLEGENDSTRINGS Returns the legend strings
      
      if nargin > 1
        extra = [' ' legendstring(hObj)];
      else
        extra = '';
      end
      
      if isempty(extra)
        extrad = extra;
      else
        extrad = [':' extra];
      end
      
      strs = {};
      
      for indx = 1:length(hObj.Filters)
        name = get(hObj.Filters(indx), 'Name');
        if isempty(name)
          name = getString(message('signal:sigtools:sigresp:Filter0numberinteger', indx));
        end
        if isquantized(hObj.Filters(indx).Filter)
          strs = {strs{:}, getString(message('signal:sigtools:sigresp:Quantized', name, extra))};
          strs = {strs{:}, getString(message('signal:sigtools:sigresp:Reference', name, extra))};
        else
          strs = {strs{:}, sprintf('%s%s', name, extrad)};
        end
      end
      
    end
    
    
    function usesaxes_visible_listener(hObj, eventData)
      %USESAXES_VISIBLE_LISTENER Make sure that the title is visible off.
      
      siggui_visible_listener(hObj, eventData);
      
      if strcmpi(get(hObj, 'Visible'), 'on')
        
        ht = get(getbottomaxes(hObj), 'Title');
        
        set(ht, 'Visible', get(hObj, 'Title'));
      end
      
    end
    
    
    function visible_listener(hObj, eventData)
      %VISIBLE_LISTENER Make sure that the title is visible off.
      
      analysisaxis_visible_listener(hObj, eventData);
      
    end
    
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function analysisaxis_setlineprops(this)
      %ANALYSISAXIS_SETLINEPROPS
      
      hl = getline(this);
      
      set(hl, ...
        'ButtonDownFcn', @setdatamarkers, ...
        'Visible', this.Visible, ...
        'Tag', getlinetag(this));
      
      % Suppress Data Brushing g418177
      for indx = 1:length(hl)
        set(hggetbehavior(hl(indx), 'Brush'), 'Enable', false);
      end
      
    end
    
    
    function attachlisteners(hObj)
      %ATTACHLISTENERS
      
      % NO OP.  Can be overloaded by the subclasses.
      
    end
    
    function formataxislimits(this)
      %FORMATAXISLIMITS
      
      h = get(this, 'Handles');
      
      ydata = get(h.line, 'YData');
      
      if isempty(ydata)
        return;
      end
      
      % Compute global Y-axis limits over potentially
      % multiple filter magnitude responses
      %
      yMin =  Inf;  % min global y-limit
      yMax = -Inf;  % max global y-limit
      if ~iscell(ydata)
        ydata = {ydata};
      end
      for indx = 1:length(ydata) % Loop over the filter responses.
        thisResponse = ydata{indx};
        
        yMin = min(yMin, min(thisResponse));
        yMax = max(yMax, max(thisResponse));
      end
      
      % Make sure that the yMin and yMax aren't within a small range.
      % This can happen in the GRPDELAY case for linear phase filters.
      if yMax-yMin < eps^(1/4)
        yMin = yMin-.5;
        yMax = yMax+.5;
      else
        MarginTop = 0.05;  % 5% margin of dyn range at top
        MarginBot = 0.05;  % ditto
        
        dr = yMax-yMin;
        
        yMin = yMin-dr*MarginBot;
        yMax = yMax+dr*MarginTop;
      end
      
      % If the response doesn't work well with the zoom, just use [0 1].
      if yMin == Inf
        yMin = 0;
      end
      
      if yMax == -Inf
        yMax = 1;
      end
      
      set(h.axes, 'YLim',[yMin yMax]);
      
    end
    
    function usesaxes_setlineprops(hObj)
      %USESAXES_SETLINEPROPS
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      set(getline(hObj), ...
        'ButtonDownFcn', @setdatamarkers, ...
        'Visible', hObj.Visible, ...
        'Tag', getlinetag(hObj));
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef


% -------------------------------------------------------------------------
function hax = lclCopyAxes(this, hFigNew)

top = gettopaxes(this); 
bottom = getbottomaxes(this); 

% top and bottom axes will return the same handle in the case where there
% is only one response plotted in the fdatool. In this case we set the
% bottom to empty. The rest of the operations like adding legends, printing
% the axes are always done on the top axes.
if top==bottom
    bottom = [];
end
 
h = get(this,'Handles'); 
if isfield(h, 'legend') && ishghandle(h.legend) 
    top = [h.legend top]; 
end
 
copies = copyobj([top bottom],hFigNew); 

% Make sure hax contains only types axes. 
hax = findobj(copies,'Type','axes');
 
set(hax, 'OuterPosition', [0 0 1 1]); 

if(length(copies) > 2) 
   hax(3) = copies(1); 
end 

%The workaround below causes the xlabel to be invisible (g1261493). After
%removing the code below, the original issue referenced in g211899 does not
%appear, and g1261493 is resolved:
  % Work around for g211899, label visible state not being copied correctly. 
  % if length(hax) > 1 
  %     set(get(hax(1), 'XLabel'), 'Visible','off'); 
  % end 


h = get(this, 'Handles'); 
if length(hax) > 2 
    oldAxPos = getpixelposition(gettopaxes(this)); 
    newAxPos = getpixelposition(hax(1)); 
    oldLePos = getpixelposition(h.legend); 
     
    oldPos = getpixelposition(hax(end)); 
     
    % Reposition the legend so that it is in the same relative position 
    % as it was in the old figure. 
    setpixelposition(hax(end), [ ... 
        (oldLePos(1)-oldAxPos(1))/oldAxPos(3)*newAxPos(3)+newAxPos(1) ... 
        (oldLePos(2)-oldAxPos(2))/oldAxPos(4)*newAxPos(4)+newAxPos(2) ... 
        oldPos(3:4)]) 
end

end


% ---------------------------------------------------------------------
function setaxesprops(this)
%SETAXESPROPS Set the Custom Axes properties since some of them are overridden
% when drawing the response.

h  = get(this, 'Handles');
sz = gui_sizes(this);

% Default Axes Color
props = {'fontsize', sz.fontsizegraphics,...
  'fontname', sz.fontnamegraphics,...
  'Visible', this.Visible,...
  'Box', 'On'};
set(h.axes,props{:});

% Only turn on the grid for the first axes (for the Mag & Phase response),
% so that the coincident grids will print and zoom correctly.
hax = getbottomaxes(this);

% Set the X & Y label properties
set([get(hax, 'XLabel'), get(hax, 'YLabel')], ...
  'FontSize', sz.fontsizegraphics,...
  'FontName', sz.fontnamegraphics,...
  'Color', 'black');

% Set the ytickmode later to work around an HG issue.
set(h.axes, 'YTickMode', 'auto');

end


% ------------------------------------------------------------------
function obd_listener(h, eventData)

unrender(h);

end


% ---------------------------------------------------------------------
function lclattachlisteners(this, varargin)

l1{1} = handle.listener(this.Parameters, 'NewValue', {@parameter_listener, varargin{:}});
l1{2} = event.proplistener(this, this.findprop('Legend'),     'PostSet', @(s,e)legend_listener(this,s));
l1{3} = event.proplistener(this, this.findprop('Grid'),       'PostSet', @(s,e)grid_listener(this,s));
l1{4} = event.proplistener(this, this.findprop('Title'),      'PostSet', @(s,e)title_listener(this,s));
l1{5} = event.proplistener(this, this.findprop('FastUpdate'), 'PostSet', @(s,e)title_listener(this,s));

set(l1{1}, 'CallbackTarget', this);

set(this, 'UsesAxes_WhenRenderedListeners', l1);

end

% ---------------------------------------------------------------------
function title_listener(this, eventData)

ht = get(getbottomaxes(this), 'Title');

if strcmpi(get(this, 'Visible'), 'on')
  titleVis = get(this, 'Title');
else
  titleVis = 'off';
end
set(ht, 'Visible', titleVis);

end

% ---------------------------------------------------------------------
function grid_listener(this, eventData)

updategrid(this);

end

% ---------------------------------------------------------------------
function legend_listener(this, eventData)

updatelegend(this);

end

% ---------------------------------------------------------------------
function parameter_listener(this, eventData)

sendstatus(this, getString(message('signal:sigtools:filtresp:ComputingResponse')));
changedtags = cellstr(get(eventData, 'Data'));

% If any of the changed tags are removed at least 1 was there.
xchanged = length(changedtags) ~= length(setdiff(changedtags, getxparams(this)));
ychanged = length(changedtags) ~= length(setdiff(changedtags, getyparams(this)));

% If all the tags are "zoom" tags then keep the zoom state.
if xchanged && ychanged
  draw(this);
elseif xchanged
  captureanddraw(this, 'y');
elseif ychanged
  captureanddraw(this, 'x');
else
  draw(this); % captureanddraw(this, 'both');
end

sendstatus(this, getString(message('signal:sigtools:filtresp:ComputingResponseDone')));

end

% ---------------------------------------------------------------------
function createdynamicprops(this)

p(1) = this.addprop('UsesAxes_WhenRenderedListeners');
p(2) = this.addprop('UsesAxes_RenderedPropHandles');

p(1).Hidden = true;
p(2).Hidden = true;

set(this, 'UsesAxes_RenderedPropHandles', p);

end


% -------------------------------------------------------------------------
function onLegendBeingDeleted(this)

% Because of the order in which HG deletes objects, "this" can be deleted
% before the legend, causing errors.  Avoid these by verifying the "this"
% is still a valid object.
if isa(this, 'sigresp.analysisaxis')
  set(this, 'Legend', 'Off');
end

end

% ------------------------------------------------------------
function m = getengunitsfactor(hax)

if isappdata(hax, 'EngUnitsFactor')
  m = getappdata(hax, 'EngUnitsFactor');
else
  m = 1;
end

end


function location = getLegendLocationFromNumeric(n)

location = [];
%       0 = Automatic "best" placement (least conflict with data)
%       1 = Upper right-hand corner (default)
%       2 = Upper left-hand corner
%       3 = Lower left-hand corner
%       4 = Lower right-hand corner
%      -1 = To the right of the plot
switch n
    case -1
        location = 'NorthEastOutside';
    case 0
        location = 'Best';
    case 1
        location = 'NorthEast';
    case 2
        location = 'NorthWest';
    case 3
        location = 'SouthWest';
    case 4
        location = 'SouthEast';
end
end
