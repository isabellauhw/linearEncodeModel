classdef twoanalyses < sigresp.analysisaxis
  %sigresp.twoanalyses class
  %   sigresp.twoanalyses extends sigresp.analysisaxis.
  %
  %    sigresp.twoanalyses properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       Analyses - Property is of type 'sigresp.analysisaxis vector'
  %
  %    sigresp.twoanalyses methods:
  %       attachlisteners -  Attach WhenRenderedListeners to the object.
  %       attachprmdlglistener - Allow subclasses to attach listeners to the parameterdlg.
  %       get2axes - Returns a vector of 2 axes
  %       getkeyhandles - GETOBJBEINGDESTROYED Returns the handles to the objects which will cause
  %       getlegendstrings - Returns the legend strings
  %       getline - Return the handles to the line objects
  %       getname - Update the title on the tworesps axes
  %       setlineprops - Overloaded to do nothing
  %       thisdraw - Draw the two response
  %       twoanalyses_setresps - SETRESPS Perform the preset operations on the new analyses.
  %       visible_listener - Listener to the visible property
  
  %   Copyright 1988-2017 The MathWorks, Inc.

  
  properties (SetObservable, GetObservable)
    %ANALYSES Property is of type 'sigresp.analysisaxis vector'
    Analyses = [];
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %LISTENERS Property is of type 'handle.listener'
    Listeners = [];
    %CHILDLISTENER Property is of type 'handle.listener vector'
    ChildListener = [];
  end
  
  
  methods  % constructor block
    function h = twoanalyses
      %TWOANALYSES Construct a TWOANALYSES object

    end  % twoanalyses
    
  end  % constructor block
  
  methods
    function set.Analyses(obj,value)
      % DataType = 'sigresp.analysisaxis vector'
      validateattributes(value,{'sigresp.analysisaxis'}, {'vector'},'','Analyses');
      obj.Analyses = setresps(obj,value);
    end
    
    function set.Listeners(obj,value)
      % DataType = 'handle.listener'
      if ~isempty(value)
        validateattributes(value,{'event.proplistener'}, {'vector'},'','Listeners')
      end
      obj.Listeners = value;
    end
    
    function set.ChildListener(obj,value)
      % DataType = 'handle.listener vector'
      if ~isempty(value)
        validateattributes(value,{'event.listener'}, {'vector'},'','ChildListener')
      end
      obj.ChildListener = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function attachlisteners(this)
      %ATTACHLISTENERS  Attach WhenRenderedListeners to the object.

      twoanalyses_attachlisteners(this);
      
    end
    
    
    function attachprmdlglistener(hObj, hDlg)
      %ATTACHPRMDLGLISTENER Allow subclasses to attach listeners to the parameterdlg.

      l = event.proplistener(hObj, hObj.findprop('Analyses'), 'PostSet', @(h,evt) lclresponses_listener(hObj,evt,hDlg));
      
      % setappdata(hDlg, 'tworesps_resps_listener', l);
      
    end
    
    function get2axes(hObj)
      %GET2AXES Returns a vector of 2 axes
 
      h = get(hObj, 'Handles');
      hax = h.axes;
      
      if length(hax) == 1
        hFig = get(hax, 'Parent');
        
        % Find all axes on the figure
        allhax = findall(hFig, 'Type', 'Axes');
        
        % Remove the input axes
        allhax(allhax == hax) = [];
        
        % See if any axes have the same position as the input axes
        if ~isempty(allhax)
          pos = get(hax, 'Position');
          if ~iscell(pos), pos = {pos}; end
          
          match = zeros(length(pos), 1);
          for indx = 1:length(pos)
            match(indx) = all(pos{indx} - get(hax, 'Position') < sqrt(eps));
          end
          allhax = allhax(match);
        end
        
        % If no axes match the input, create a new one.
        if isempty(allhax)
          hax(2) = axes('Parent', hFig, ...
            'Units', get(hax, 'Units'), ...
            'Position', get(hax, 'Position'));
        else
          hax(2) = allhax(1);
        end
        set(hFig, 'CurrentAxes', hax(1));
      end
      
      h.axes = hax;
      set(hObj, 'Handles', h);
      
    end
    
    function h = getkeyhandles(this)
      %GETOBJBEINGDESTROYED Returns the handles to the objects which will cause
      %an unrender

      h = get(this, 'Handles');
      h = h.axes;
      
    end
    
    
    function strs = getlegendstrings(hObj, varargin)
      %GETLEGENDSTRINGS Returns the legend strings

      resps = get(hObj, 'Analyses');
      
      strs1 = getlegendstrings(resps(1), legendstring(resps(1)));
      strs2 = getlegendstrings(resps(2), legendstring(resps(2)));
      
      strs = {strs1{:}, strs2{:}};
      
    end
    
    
    function hline = getline(hObj)
      %GETLINE Return the handles to the line objects

      if ishandlefield(hObj, 'cline')
        h     = get(hObj, 'Handles');
        hline = convert2vector(h.cline);
      else
        hline = [];
      end
      
    end
    
    
    function name = getname(hObj, name)
      %GETNAME Update the title on the tworesps axes

      if isempty(hObj.Analyses), return; end
      
      t1 = get(hObj.Analyses(1), 'Name');
      t2 = get(hObj.Analyses(2), 'Name');
      
      name = sprintf(['%s ' getString(message('signal:sigtools:filtresp:and')) ' %s'], t1, t2);
      
    end
    
    
    function setlineprops(hObj)
      %SETLINEPROPS Overloaded to do nothing

      % NO OP
      
    end
    
    
    function thisdraw(this)
      %THISDRAW Draw the two response

      % Cache the grid state.  The 2nd response "messes up" the grid state.
      grid = get(this, 'Grid');
      
      get2axes(this);
      
      h = get(this, 'Handles');
      
      hresps = get(this, 'Analyses');
      
      % Cache lastwarn so the contained Analyses can handle their own warnings
      [wstr, wid] = lastwarn;
      
      % Render the Analyses.  We only need to take care of this if they are not
      % yet rendered.  Once they are rendered they update themselves.
      if ~isrendered(hresps(1))
        render(hresps(1), getbottomaxes(this));
      end
      if ~isrendered(hresps(2))
        render(hresps(2), gettopaxes(this));
      end
      
      % Make the top axes appear invisible
      set(gettopaxes(this), ...
        'Color', 'none', ...
        'HitTest', 'Off', ...
        'YAxisLocation', 'right', ...
        'Box','off', ...
        'HandleVisibility', 'Callback');
      
      % Reset lastwarn.  The contained Analyses should throw their own warnings.
      lastwarn(wstr, wid);
      
      for i = 1:length(hresps)
        hresps(i).Visible = this.Visible;
      end
      
      
      % Get the contained lines from the two Analyses
      h1 = getline(hresps(1));
      h2 = getline(hresps(2));
      h.cline = [h1(:); h2(:)];
      
      set(this, 'Handles', h);
      
      cleanresponses(this);
      
      if isa(hresps, 'sigresp.freqaxis')
        setcoincidentgrid(h.axes);
      else
        set(getline(this), 'Visible', 'On');
        set(h.axes, 'YLimMode', 'Auto');
        ylim = get(h.axes, 'YLim');
        set(getline(this), 'Visible', this.Visible);
        ylim = [ylim{:}];
        set(h.axes, 'YLim', [min(ylim), max(ylim)]);
      end
      
      % We have to call updatetitle directly because we delete it from the two
      % Analyses when we redraw.
      updatetitle(this);
      
      set(this, 'Grid', grid);
      
      objspecificdraw(this);
      
      linkaxes(h.axes, 'x');
      
    end
    
    
    function out = twoanalyses_setresps(this, out)
      %SETRESPS Perform the preset operations on the new analyses.

      if isempty(out)
        hPrm = [];
      else
        if ~isa(out, 'sigresp.freqaxis') && ~isa(out, 'sigresp.timeaxis')
          error(message('signal:sigresp:twoanalyses:twoanalyses_setresps:GUIErr'));
        end
        
        % The responses should always have grid and legend off.  The TWORESPS
        % object will take care of it.
        for i = 1:length(out)
          out(i).Legend = 'off';
        end
        set(out(2), 'Grid', 'Off');
        set(out(1), 'Grid', this.Grid);
        
        % Get the parameters from the responses and combine them.  Make sure
        % that the common parameters show up first in the same order as they
        % were in the first response.  Make sure that the "non common"
        % parameters show up in the same order that they are in their
        % individual responses by sorting the indx from setxor.  If the order
        % didn't matter we could just say "union(prm1, prm2)".
        prm1 = out(1).Parameters;
        prm2 = out(2).Parameters;
        [commonprm, indx] = intersect(prm1, prm2);
        [noncommonprm, indx1, indx2] = setxor(prm1, prm2);
        hPrm = [prm1(sort(indx)); prm1(sort(indx1)); prm2(sort(indx2))];
        
        % TWORESPS does not extend from SIGCONTAINER so it must handle the
        % notification listener itself.  In order for it to inherit from
        % SIGCONTAINER the entire FILTRESP package would have to inherit from
        % SIGCONTAINER.
        
        idx = 1;
        for iout = 1:length(out)
          ls(idx) = event.listener(out(iout), 'Notification', @lclnotification_listener);
          ls(idx+1) = event.listener(out(iout), 'DisabledListChanged', @(s, e) lcldisabledlist_listener(this, e));
          idx = idx+2;
        end
        
        this.ChildListener = ls;
        
        d = union(get(out(1), 'DisabledParameters'), get(out(2), 'DisabledParameters'));
        for indx = 1:length(d)
          disableparameter(this, d{indx});
        end
      end
      
      set(this, 'Parameters', hPrm);
      
    end
    
    
    function visible_listener(hObj, eventData)
      %VISIBLE_LISTENER Listener to the visible property

      analysisaxis_visible_listener(hObj, eventData);
      
      % The responses will always be rendered if the tworesps is rendered.
      for i = 1:length(hObj.Analyses)
        hObj.Analyses(i).Visible = hObj.Visible;
      end
      
      set(get(gettopaxes(hObj), 'XLabel'), 'Visible', 'Off');
      
      h = get(hObj, 'Handles');
      
      if isa(hObj.Analyses, 'sigresp.freqaxis')
        setcoincidentgrid(h.axes);
      else
        set(getline(hObj), 'Visible', 'On');
        set(h.axes, 'YLimMode', 'Auto');
        ylim = get(h.axes, 'YLim');
        set(getline(hObj), 'Visible', hObj.Visible);
        ylim = [ylim{:}];
        set(h.axes, 'YLim', [min(ylim), max(ylim)]);
      end
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function formataxislimits(this)
      %FORMATAXISLIMITS

      % NO OP. Let the contained analyses handle it.
      
    end
    
    
    function objspecificunrender(hObj)
      %OBJSPECIFICUNRENDER

      hresps = get(hObj, 'Analyses');
      
      % Unrender each of the contained Analyses.
      if isrendered(hresps(1)), unrender(hresps(1)); end
      if isrendered(hresps(2)), unrender(hresps(2)); end
      
      h = get(hObj, 'Handles');
      
      % We do not want to delete the axes and the cline is taken care of by the
      % contained response objects.
      h = convert2vector(rmfield(h, 'cline'));
      h(~ishghandle(h)) = [];
      
      delete(h);
      
    end
    
    function out = setresps(h, out)
      %SETRESPS
      
      out = twoanalyses_setresps(h, out);
      
    end
    
    
    function twoanalyses_attachlisteners(this)
      %TWOANALYSES_ATTACHLISTENERS
            
      l(1) = event.proplistener(this, this.findprop('Analyses'), 'PreSet', @(s,e)preresponses_listener(this,e));
      l(2) = event.proplistener(this, this.findprop('Analyses'), 'PostSet', @(s,e)postresponses_listener(this,e));
      
      set(this, 'WhenRenderedListeners', l);
      
    end    
    
  end  %% possibly private or hidden
  
end  % classdef

% -------------------------------------------------------------------------
function lclresponses_listener(hObj, eventData, hDlg)

hObj.setupparameterdlg(hDlg);

end


% ---------------------------------------------------------
function cleanresponses(this)

h = get(this, 'Handles');

delete(get(h.axes(1), 'Title'));
delete(get(h.axes(2), 'Title'));

% Delete the xtick and label for the axes on top.
tophax = gettopaxes(this);

set(get(tophax, 'XLabel'), 'Visible', 'Off');
set(tophax, 'XTick', []);

% If both ylabels are the same sync the limits
if strcmpi(get(get(h.axes(1), 'YLabel'), 'String'), ...
    get(get(h.axes(2), 'YLabel'), 'String'))
  
  ylim1 = get(h.axes(1), 'YLim');
  ylim2 = get(h.axes(2), 'YLim');
  
  ylim = [min(ylim1(1), ylim2(1)) max(ylim1(2), ylim2(2))];
  set(h.axes, 'YLim', ylim);
end

end


% ---------------------------------------------------------
function preresponses_listener(this, eventData)

h = get(this, 'Handles');
legendState = this.Legend;
if isfield(h, 'legend') && ishghandle(h.legend)
  delete(h.legend);
end
this.Legend = legendState;

oldresps = get(this, 'Analyses');
for indx = 1:length(oldresps)
  unrender(oldresps(indx));
end

end

% ---------------------------------------------------------
function postresponses_listener(this, eventData)

% Redraw the Analyses
thisdraw(this);

% We have to call updategrid ourselves because this is normally taken care
% of by THISRENDER at the USESAXES level.
updategrid(this);

% We must call updatelegend because the preset delete it.
updatelegend(this);

fixlisteners(this);

notify(this, 'NewPlot');

end

% ---------------------------------------------------------
function fixlisteners(this)

l = {get(this, 'UsesAxes_WhenRenderedListeners')};
l{1} = handle.listener(getparameter(this), 'NewValue', @(s,e)lclparameter_listener(this,e));
set(l{1}, 'CallbackTarget', this);

set(this, 'UsesAxes_WhenRenderedListeners', l);
end


% ---------------------------------------------------------
function lclparameter_listener(this, eventData)

thisdraw(this);

notify(this, 'NewPlot', handle.EventData(this, 'NewPlot'));

end

% -------------------------------------------------------------------------
function lclnotification_listener(this, eventData)

% We do not want to resend 'Computing ... done' statuses.  This status is
% sent from the TWORESPS object itself, not the contained objects.

if isprop(eventData,'NotificationType') && strcmpi(eventData.NotificationType, 'StatusChanged')
  if strcmpi(eventData.Data.StatusString, getString(message('signal:sigtools:filtresp:ComputingResponseDone')))
    return;
  end
end

notify(this, 'Notification', eventData);

end

% -------------------------------------------------------------------------
function lcldisabledlist_listener(this, eventData)

d = get(eventData, 'Data');

if strcmpi(d.type, 'disabled')
  disableparameter(this, d.tag);
else
  enableparameter(this, d.tag);
end

end

