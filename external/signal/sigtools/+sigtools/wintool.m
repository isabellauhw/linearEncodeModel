classdef wintool < siggui.sigcontainerMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigtools.wintool class
  %   sigtools.wintool extends siggui.sigcontainer.
  %
  %    sigtools.wintool properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %
  %    sigtools.wintool methods:
  %       addlistener - Add a listener to WinTool
  %       callbacks - Callbacks for the menus and toolbar buttons of the window GUI.
  %       isemptyselection_eventcb - Enable/Disable the Full View Analysis.
  %       notification_listener - Listener to the Notification event
  %       thisrender - Render the window GUI
  %       visible_listener - Listener to the visible property of WinTool
  %       wintool_export - Create an export dialog for wintool

%   Copyright 2014-2017 The MathWorks, Inc.
  
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %LISTENERS Property is of type 'mxArray'
    Listeners = [];    
  end
  
  
  methods  % constructor block
    function this = wintool(varargin)
      %WINTOOL Constructor for the wintool class.
            
      % Add components
      addcomponent(this,siggui.winmanagement);
      addcomponent(this,siggui.winspecs);
      addcomponent(this,siggui.winviewer);
      
      l.notification = event.listener(this, 'Notification', @(s,e)notification_listener(this,e));
      this.Listeners = l;
      
      % Set up the default
      this.Version = 1;
      
    end  % wintool
    
    function set.Listeners(obj,value)
      obj.Listeners = value;
    end
    
    function h = addlistenerwin(hWT, prop, callback, source, target ,filterOnListener,isEvent)
      %ADDLISTENER Add a listener to WinTool
      %   ADDLISTENER(hWT, PROP, CALLBACK, SOURCE) Add a listener to the PROP
      %   property of the SOURCE object whose callback is CALLBACK.
      %
      %   ADDLISTENER(hWT, PROP, CALLBACK, SOURCE, TARGET) An alternative target
      %   can also be specified.  TARGET will be passed as the first argument
      %   to the callback function, while EVENTDATA will remain as the second
      %   input argument.
      %
      %   ADDLISTENER(hWT, PROP, CALLBACK, SOURCE, TARGET, FILTERONLISTENER)
      %   An alternative filter on the listener can also be specified.  By default
      %   the listener is stored in the 'WhenRenderedListener' property so that it is
      %   fired only when the object is rendered.
            
      narginchk(4,7);
      
      if isempty(filterOnListener)
        filterOnListener = 'WhenRenderedListeners';
      end
      
      if nargin<7
        isEvent = 0;
      end
      
      % If findprop returned empty then prop must be an event.
      % Create the listener
      if isEvent
        cbk = func2str(callback);
        h = event.listener(source, prop, @(s,e)target.(cbk)(e));
      else
        h = event.proplistener(source, source.findprop(wt_p), 'PostSet', callback);
      end
      
      % Save the listener
      thisListeners = get(hWT, filterOnListener);
      prop = lower(prop);
      if isfield(thisListeners,prop)
        indx = length(getfield(thisListeners,prop)) + 1;
      else
        indx = 1;
      end
      thisListeners = setfield(thisListeners,prop,{indx},h);
      
      set(hWT, filterOnListener, thisListeners);
      
    end
    
    function hChildren = allchild(hParent)
      %ALLCHILD Return the children of this object
            
      % Get all the children of the object
      % hChildren = find(hParent, '-depth', 1);
      hChildren = getChildren(hParent);
      
      
      % Remove the first element which is hParent
      % hChildren(1) = [];
      
      hChildren = [hChildren(:)]';
      
    end
    
    function cbs = callbacks(this)
      %CALLBACKS Callbacks for the menus and toolbar buttons of the window GUI.
      
      % This can be a private method
      
      cbs     = siggui_cbs(this);
      cbs.new = {@new_cbs, this};
      cbs.close = {@close_cbs, this};
      cbs.export = {cbs.method, this, @wintool_export};
      cbs.preferences = {@preferences_cbs, this};
      % cbs.pagesetup = {@pagesetup_cbs, this};
      cbs.printsetup = {@printsetup_cbs, this};
      cbs.printpreview = {cbs.method, this, @printpreview};
      cbs.print = {cbs.method, this, @print};
      cbs.printtofigure = {@printofigure_cbs, this};
      cbs.wintoolhelp = {@wintoolhelp_cbs, this};
      
    end
    
    function hChild = getcomponent(hParent, tag, varargin)
      %GETCOMPONENT Retrieve a component handle from the container
      %   GETCOMPONENT(hOBJ, TAG) Retrieve a component handle from the container
      %   by searching for its tag.
      %
      %   GETCOMPONENT(hOBJ, PROP, VALUE, PROP2, VALUE2, ...) Retrieve a component
      %   handle from the container by searching according to property value pairs.
      %
      %   GETCOMPONENT returns an empty vector if the object is not found.
      
      narginchk(2,inf);
      
      if nargin > 2
        varargin = {tag, varargin{:}};
      elseif nargin > 1
        varargin = {'Tag', tag};
      end
      
      hChild = getChildren(hParent);
      
      if ~isempty(hChild)
        hChild = findobj(hChild, '-depth', 0, varargin{:});
      end
      
    end
    
    function isemptyselection_eventcb(hWT, eventData)
      %ISEMPTYSELECTION_EVENTCB Enable/Disable the Full View Analysis.
            
      % Callback executed by the listener to an event thrown by another object.
      % The Data property stores a vector of handles of winspecs objects
      s = eventData.Data;
      selectedwin = s.selectedwindows;
      
      % Get the handles to the Full View Analysis toolbar button and menu
      hndls = hWT.Handles;
      hFullButton = hndls.htoolbar(4);
      hFullMenu = hndls.hmenus(10);
      hFull = [hFullButton;hFullMenu];
      
      if isempty(selectedwin)
        set(hFull, 'Enable', 'off');
      else
        set(hFull, 'Enable', 'on');
      end
      
    end
    
    function notification_listener(hObj, eventData)
      %NOTIFICATION_LISTENER Listener to the Notification event
            
      % Get the Notification type and all it's possible settings
      NTypes = {'ErrorOccurred', 'WarningOccurred', 'StatusChanged', 'FileDirty'};
      
      % If eventData has any notification sent then execute the switch
      % conditions or exit this function
      if isprop(eventData,'NotificationType')
        NType  = eventData.NotificationType;
        % Switch on the Notification type. Note that warning and error are methods
        % of fvtool and not the warning and error functions.
        switch NType
          case NTypes{1} % 'ErrorOccurred'
            str = getString(message('signal:sigtools:wintool:notification_listener:WinToolError'));
            error(hObj, str, eventData.Data.ErrorString);
          case NTypes{2} % 'WarningOccurred'
            str = getString(message('signal:sigtools:wintool:notification_listener:WinToolWarning'));
            warning(hObj, str, eventData.Data.WarningString, eventData.Data.WarningID);
          case NTypes{3} % 'StatusChanged'
            % NO OP We are ignoring statuses for now.  See G 121740
          case NTypes{4} % 'FileDirty'
            % NO OP WINTool does not have files
          otherwise
            str = getString(message('signal:sigtools:wintool:notification_listener:UnhandledNotification',NType,class(eventData.Source)));
            error(hObj,str);
        end
      end
      
    end
    
    function thisrender(hWT, pos)
      %THISRENDER Render the window GUI
            
      if nargin < 2 , pos =[]; end
      
      % test screen resolution
      
      % Create figure and center it
      hFig = setup_figure(hWT);
      
      % Set up the figure handle
      hWT.FigureHandle = hFig;
      
      % Get the enable state
      enabstate = hWT.Enable;
      
      % Render menus
      hndls.hmenus = render_menus(hWT, enabstate);
      
      % Render toolbar
      hndls.htoolbar = render_toolbar(hWT, enabstate);
      
      % Store the handles of the menus and the toolbar buttons
      hWT.Handles = hndls;
      
      % Render components after having set the isRendered flag to 1
      % so that the listeners are fired.
      render_components(hWT, enabstate);
      
      % Render the "What's This?" button
      hndls.htoolbar(end+1) = render_cshelpbtn(hFig, 'Wintool');
      
      % Store the handles of the menus and the toolbar buttons
      hWT.Handles = hndls;
      
      % Add listeners
      installListeners(hWT);
      
    end
    
    function visible_listener(hWT, eventData)
      %VISIBLE_LISTENER Listener to the visible property of WinTool
            
      visState = get(hWT, 'Visible');
      
      if strcmpi(visState, 'On')
        sigcontainer_visible_listener(hWT, eventData);
      end
      
      hWT.FigureHandle.Visible = visState;
      
    end
    
    function wintool_export(this)
      %WINTOOL_EXPORT Create an export dialog for wintool
            
      inputs   = getselection(this);
      hwindows = get(inputs, 'Window');
      if isempty(hwindows)
        error(message('signal:sigtools:wintool:wintool_export:GUIErr'));
      end
      
      hXP = getcomponent(this, '-class', 'sigio.exportMCOS');
      
      if isempty(hXP)
        % Create the export dialog
        hXP = sigio.exportMCOS(hwindows);
        hXP.DefaultLabels = cellstr(get(inputs, 'Name'));
        
        % Define contextsensitive help
        set(hXP,'CSHelpTag','wintool_export_dlg');
        
        % Add the export component to wintool
        addcomponent(this, hXP);
        hManag = getcomponent(this, '-class', 'siggui.winmanagement');
        addlistenerwin(this, 'NewSelection', @exportselection_eventcb, hManag, this, 'Listeners',true);            
      end
      
      % Render the Export dialog (figure).
      if ~isrendered(hXP)
        render(hXP)
        centerdlgonfig(hXP, this);
      end
      
      if isempty(inputs)
        set(hXP, 'Enable', 'off');
      end
      
      set(hXP, 'Visible', 'On');
      figure(hXP.FigureHandle);
      
      
    end
    
    
    % -------------------------------------------------------------------------
    function hf = get_figurehandle(this, hf) %#ok
      
      if ishghandle(this.Parent)
        hf = ancestor(this.Parent, 'figure');
      else
        hf = -1;
      end
    end
        
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function setwindow(hWT, newwins)
      %SETWINDOW
      
      % Default window
      hManag = getcomponent(hWT, '-class', 'siggui.winmanagement');
      
      % Add windows
      for i = 1:length(newwins)
        if isa(newwins(i), 'sigwin.window')
          hSpecsDefault = hManag.defaultwindow;
          hSpecsDefault.Window = newwins(i);
          hSpecsDefault.Data = generate(newwins(i));
          hSpecsDefault.Length = int2str(newwins(i).Length);
          addnewwin(hManag, hSpecsDefault);
        end
      end
      
    end
    
    
    function exportselection_eventcb(this, eventData)
      %EXPORTSELECTION_EVENTCB Callback executed by the listener on the NewSelection event
      
      hXP = getcomponent(this, '-class', 'sigio.exportMCOS');
      winspecs = getselection(this);
      
      if isempty(winspecs)
        set(hXP, 'Visible', 'Off');
        return;
      end
      
      set(hXP, 'DefaultLabels', cellstr(get(winspecs, 'Name')), 'Data', get(winspecs, 'Window'));
      
      if isempty(winspecs)
        enab = 'off';
      else
        enab = this.Enable;
      end
      
      set(hXP, 'Enable', enab);
      
  end
    
    
    
  end  %% possibly private or hidden
  
end  % classdef


%-------------------------------------------------------------------------
function new_cbs(hcbo, eventstruct, this) %#ok

windowDesigner;

end

%-------------------------------------------------------------------------
function close_cbs(hcbo, eventstruct, this) %#ok

set(this, 'Visible', 'Off');
delete(this.FigureHandle);
delete(this);

end

%-------------------------------------------------------------------------
function preferences_cbs(hcbo, eventstruct, this) %#ok

preferences;

end

%-------------------------------------------------------------------------
function printsetup_cbs(hcbo, eventstruct, this) %#ok

% Print command has all the print setup features.
h = getcomponent(this, '-class', 'siggui.winviewer');
inputs = getprintinputs(this);
h.print(inputs{:});

end

%-------------------------------------------------------------------------
function printpreview(this)

h = getcomponent(this, '-class', 'siggui.winviewer');
inputs = getprintinputs(this);
h.printpreview(inputs{:});

end

%-------------------------------------------------------------------------
function print(this)

h = getcomponent(this, '-class', 'siggui.winviewer');
inputs = getprintinputs(this);
h.print(inputs{:});

end


%-------------------------------------------------------------------------
function printofigure_cbs(hcbo, eventstruct, this) %#ok
% Launch WVTool

hManag = getcomponent(this, '-class', 'siggui.winmanagement');
winspecs = hManag.Window_list;
selected = hManag.Selection;
currentindex = hManag.Currentwin;

if ~isempty(selected)
  
  hVold = getcomponent(this, '-class', 'siggui.winviewer');
  
  % Instantiate the wvtool object
  hV = sigtools.wvtool(copyparams(get(hVold, 'Parameters')));
  
  set(hV, 'Legend', get(hVold, 'Legend'));
  
  % Render the winview object
  render(hV);
  
  % Add the selected windows to WVTool
  N = length(selected);  
  for i = 1:N    
    winobjs{i} = get(winspecs(selected(N-i+1)),'Window'); %#ok<AGROW>
  end
  
  names = get(winspecs(selected), 'Name');
  if ~iscell(names)
    names = {names};
  end
  
  % Windows appear in the figure and legend in the opposite order they
  % appear in the listbox. See g1343165.
  names = flipud(names(:));
  
  % Find current (bold) window
  ind = find(selected==currentindex);
  addwin(hV, winobjs, [], 'Replace', ind, names);
  
  % Turn visibility on
  set(hV, 'Visible', 'on');
end

end

%-------------------------------------------------------------------------
function wintoolhelp_cbs(hcbo, eventstruct, this) %#ok

cbs = wintool_help;
hFig = get(this, 'FigureHandle');
feval(cbs.toolhelp, [], [], hFig);

end

%-------------------------------------------------------------------------
function inputs = getprintinputs(this)

hFig = get(this, 'FigureHandle');

inputs = {'PaperUnits',  get(hFig, 'PaperUnits'), ...
  'PaperOrientation',  get(hFig, 'PaperOrientation'), ...
  'PaperPosition',     get(hFig, 'PaperPosition'), ...
  'PaperPositionMode', get(hFig, 'PaperPositionMode'), ...
  'PaperSize',         get(hFig, 'PaperSize'), ...
  'PaperType',         get(hFig, 'PaperType')};

end


%-------------------------------------------------------------------
function h = copyparams(hold)

for i = 1:length(hold)
  h(i) = sigdatatypes.parameter(hold(i).Name, hold(i).Tag, ...
    hold(i).ValidValues, hold(i).Value); %#ok<AGROW>
end

end



%-------------------------------------------------------------------
%                       Utility Functions
%-------------------------------------------------------------------
function hFig = setup_figure(hWT)

hFig = hWT.FigureHandle;
visstate  = hWT.Visible;

bgc  = get(0,'DefaultUicontrolBackgroundColor');
cbs = callbacks(hWT);

hFig = figure( ...
  'Color', bgc, ...
  'CloseRequestFcn', cbs.close, ...
  'HandleVisibility', 'callback', ...
  'MenuBar' , 'none', ...
  'NumberTitle', 'off', ...
  'Name', getString(message('signal:sigtools:sigtools:WindowDesignAnalysisTool')), ...
  'Visible', visstate, ...
  'WindowStyle','normal',...
  'DefaultLegendAutoUpdate','off');

% Center figure
sz = local_gui_sizes(hWT);
screensize = get(0, 'ScreenSize');
xpos = round((screensize(3)-sz.fig_w)/2);
ypos = round((screensize(4)-sz.fig_h)/2);
set(hFig, 'Position', [xpos ypos sz.fig_w sz.fig_h]);

% Print option default : don't print uicontrols
pt = printtemplate;
pt.PrintUI = 0;
set(hFig, 'PrintTemplate', pt);

end

%-------------------------------------------------------------------
function sz = local_gui_sizes(hWT)

% Get the generic gui sizes
sz = gui_sizes(hWT);

% Figure width and height
sz.fig_w = 683*sz.pixf;;
sz.fig_h = 550*sz.pixf;;

% Management component
sz.manag_x = 12;
sz.manag_y = 13;

% Specifications component
sz.specs_x = 440;
sz.specs_y = 13;

% Viewer component
sz.view_x = 12;
sz.view_y = 230;

end


%-------------------------------------------------------------------
function hmenus = render_menus(hWT, enabstate)
%RENDER_MENUS Render the menus of the Window GUI.

hFig = hWT.FigureHandle;

% File menu
hfile = render_filemenu(hWT);

% Tools menu
[htoolsmenu, htoolsmenuitems] = render_toolsmenu(hFig);

% Window menu
hwindow = render_windowmenu(hFig);

% Help menu
[hhelpmenu, hhelpmenuitems] = render_helpmenu(hFig, hWT);

% Return the handles to all the menus
hmenus = [hfile(:); htoolsmenu; htoolsmenuitems(:); ...
  hwindow; hhelpmenu; hhelpmenuitems(:)];

% Set the enable state
set(hmenus, 'Enable', enabstate);

end


%-------------------------------------------------------------------
function hfile = render_filemenu(hWT)
%RENDER_FILEMENU Render the File menu

hFig = hWT.FigureHandle;

strs = {getString(message('signal:sigtools:sigtools:File')), ...
  getString(message('signal:sigtools:sigtools:NewWinTool')), ...
  getString(message('signal:sigtools:sigtools:Export')), ...
  getString(message('signal:sigtools:sigtools:PrintSetup')), ...
  [getString(message('signal:sigtools:sigtools:PrintPreview1')) '...'], ...
  [getString(message('signal:sigtools:sigtools:Print1')) '...'], ...
  getString(message('signal:sigtools:sigtools:FullViewAnalysis')), ...
  getString(message('signal:sigtools:sigtools:Close'))};
cb = callbacks(hWT);
cbs = {'', ...
  cb.new, ...
  cb.export, ...
  cb.printsetup, ...
  cb.printpreview, ...
  cb.print, ...
  cb.printtofigure, ...
  cb.close};
tags = {'file', ...
  'newwintool', ...
  'export', ...
  'printsetup', ...
  'printpreview', ...
  'print', ...
  'printtofigure', ...
  'close'};
sep = {'off', ...
  'off', ...
  'on', ...
  'on', ...
  'off', ...
  'off', ...
  'off', ...
  'on', ...
  'on'};
accel = {'', ...
  'N', ...
  'E', ...
  '', ...
  '', ...
  '', ...
  'P', ...
  '', ...
  'W'};
hfile = addmenu(hFig,1,strs,cbs,tags,sep,accel);

end

%-------------------------------------------------------------------
function [htoolsmenu, htoolsmenuitems] = render_toolsmenu(hFig)
%RENDER_TOOLSMENU Render the Tools menu

strs  = getString(message('signal:sigtools:sigtools:Tools'));
cbs   = '';
tags  = 'tools';
sep   = 'Off';
accel = '';
htoolsmenu = addmenu(hFig,2,strs,cbs,tags,sep,accel);
% render the "Zoom In" and "Zoom Out" menus
htoolsmenuitems = render_zoommenus(hFig, [2 1]);

end

%-------------------------------------------------------------------
function hwindow = render_windowmenu(hFig)
%RENDER_WINDOWMENU Render the Window menu

hwindow = matlab.ui.internal.createWinMenu(hFig);
set(hwindow,'Position',3);

end

%-------------------------------------------------------------------
function [hhelpmenu, hhelpmenuitems] = render_helpmenu(hFig, hWT)
%RENDER_HELPMENU Render the Help menu

[hhelpmenu, hhelpmenuitems] = render_spthelpmenu(hFig, 4);

strs  = getString(message('signal:sigtools:sigtools:WinToolHelp'));
cbs = callbacks(hWT);
tags  = 'wintoolhelp';
sep   = 'off';
accel = '';
hhelpmenuitems(end+1) = addmenu(hFig,[4 1],strs,cbs.wintoolhelp,tags,sep,accel);

strs  = getString(message('signal:sigtools:sigtools:WhatsThis'));
cbs   = {@cshelpgeneral_cb, 'WinTool'};
tags  = 'whatsthis';
sep   = 'on';
accel = '';
hhelpmenuitems(end+1) = addmenu(hFig,[4 3],strs,cbs,tags,sep,accel);

end

%-------------------------------------------------------------------
function htoolbar = render_toolbar(hWT, enabstate)
%RENDER_TOOLBAR Render the toolbar of the window GUI.

hFig = hWT.FigureHandle;

% Render a Toolbar
hut = uitoolbar('Parent',hFig);

% Render standard buttons (New, Print, Print Preview)
hstdbtns = render_standardbtns(hWT, hut);

% Render the Print to Figure button
hprint2figurebtn = render_print2figurebtn(hWT, hut);

% Render the Zoom In and Zoom Out buttons
hzoombtns = render_zoombtns(hFig);

% Return the handles to all the toolbar buttons
htoolbar = [hstdbtns(:); hprint2figurebtn; ...
  hzoombtns(:)];

% Set the enable state
set(htoolbar, 'Enable', enabstate);

end


%-------------------------------------------------------------------
function hstdbtns = render_standardbtns(hWT, hut)
% Render standard buttons (New, Print, Print Preview)

% Load new, open, save print and print preview icons.
load mwtoolbaricons;

% Structure of all local callback functions
cbs = callbacks(hWT);

% Cell array of cdata (properties) for the toolbar icons
pushbtns = {newdoc,...
  printdoc,...
  printprevdoc};

tooltips = {getString(message('signal:sigtools:sigtools:NewWinTool1')),...
  getString(message('signal:sigtools:sigtools:Print1')),...
  getString(message('signal:sigtools:sigtools:PrintPreview1'))};

tags = {'newwintool',...
  'printresp',...
  'printprev'};

% List callbacks for pushbuttons
btncbs = {cbs.new,...
  cbs.print,...
  cbs.printpreview};

% Render the PushButtons
for i = 1:length(pushbtns)
  hstdbtns(i) = uipushtool('CData',pushbtns{i},...
    'Parent', hut,...
    'ClickedCallback',btncbs{i},...
    'Tag',            tags{i},...
    'TooltipString',  tooltips{i});
end

end

%-------------------------------------------------------------------
function hprint2figurebtn = render_print2figurebtn(hWT, hut)
% Render the "Print to figure" toolbar button

% Load the MAT-file with the icon
load wintoolicons;

% Structure of all local callback functions
cbs = callbacks(hWT);

% Render the ToggleButtons
hprint2figurebtn = uipushtool('CData',icons.printtofigure,...
  'Parent', hut, ...
  'ClickedCallback', cbs.printtofigure, ...
  'Tag',            'printtofigure', ...
  'TooltipString',  getString(message('signal:sigtools:sigtools:FullViewAnalysis')), ...
  'Separator',      'On');

end

%-------------------------------------------------------------------
function render_components(hWT, enabstate)
%RENDER_COMPONENTS Render the components of the Window GUI.

hSpecs = findobj(hWT, '-class', 'siggui.winspecs');
hView  = findobj(hWT, '-class', 'siggui.winviewer');
hManag = findobj(hWT, '-class', 'siggui.winmanagement');

% Get the figure Handle
hFig = hWT.FigureHandle;

sz = gui_sizes(hWT);

% The management component MUST be render the last to be sure that
% the listeners are fired properly.
render(hSpecs, hFig);
render(hView, hFig);
render(hManag, hFig);

hLayout = siglayout.gridbaglayout(hFig);

set(hLayout, ...
  'HorizontalGap',     12*sz.pixf, ...
  'VerticalGap',       5*sz.pixf, ...
  'VerticalWeights',   [1 0], ...
  'HorizontalWeights', [1 0]);

hLayout.add(hView.Container, 1, 1:2, ...
  'Fill', 'Both');
hLayout.add(hManag.Container, 2, 1, ...
  'MinimumHeight', 212*sz.pixf, ...
  'Fill', 'Horizontal', ...
  'BottomInset', 8*sz.pixf);
hLayout.add(hSpecs.Container, 2, 2, ...
  'MinimumHeight', 212*sz.pixf, ...
  'MinimumWidth', 232*sz.pixf, ...
  'BottomInset', 8*sz.pixf);

end


%-------------------------------------------------------------------------
function selectedwin = getselection(this)
%GETSELECTION Return the names of the selected windows in TNAMES,
% and the corresponding objects in OBJECTS.

hManag = getcomponent(this, '-class', 'siggui.winmanagement');

window_list = get(hManag, 'Window_list');
selection = get(hManag, 'Selection');
selectedwin= window_list(selection);

end

%-------------------------------------------------------------------
function installListeners(hWT)

% Find the components
hSpecs = findobj(hWT, '-class', 'siggui.winspecs');
hView  = findobj(hWT, '-class', 'siggui.winviewer');
hManag = findobj(hWT, '-class', 'siggui.winmanagement');

%----------------- Create the listeners to event--------------------
% The Viewer and Specifications components listen to a NewSelection event
% % thrown by the Management component
addlistenerwin(hWT, 'NewSelection', @newselection_eventcb1,hManag,hSpecs,[],1);
addlistenerwin(hWT, 'NewSelection', @isemptyselection_eventcb,hManag,hWT,[],1);
addlistenerwin(hWT, 'NewSelection', @newselection_eventcb,hManag,hView,[],1);

% The Management and Viewer components listen to a NewCurrentwinIndex event
% thrown by the Specifications component
addlistenerwin(hWT, 'NewCurrentwinIndex', @newcurrentwinindex_eventcb, hSpecs, hView,[],1);
addlistenerwin(hWT, 'NewCurrentwinIndex', @newcurrentwinindex_eventcb, hSpecs, hManag,[],1);

% The Specifications component listen to a NewCurrentwin event
% thrown by the Management component
addlistenerwin(hWT, 'NewCurrentwin', @newcurrentwin_eventcb, hManag, hSpecs,[],1);

% The Management component listen to a NewState event
% thrown by the Specifications component
addlistenerwin(hWT, 'NewState', @newcurrentwinstate_eventcb, hSpecs, hManag,[],1);


end

