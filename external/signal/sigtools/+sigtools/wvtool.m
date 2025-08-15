classdef wvtool < siggui.sigcontainerMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigtools.wvtool class
  %   sigtools.wvtool extends siggui.sigcontainer.
  %
  %    sigtools.wvtool properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %
  %    sigtools.wvtool methods:
  %       addwin - Add windows to WVTool.
  %       callbacks - Callbacks of WVTool.
  %       close - Close WVTool.
  %       thisrender - Render the wvtool object.
  %       visible_listener - Overload the base class method.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %NAME Property is of type 'string'
    Name = 'Window Visualization Tool';
    %LEGEND Property is of type 'on/off'
    Legend;
  end
  
  
  events
    WVToolClosing
  end  % events
  
  methods  % constructor block
    function hV = wvtool(varargin)
      %WVTOOL Constructor for the wvtool class.
      
      %   Author(s): V.Pellissier
      
      % Set up the default
      addcomponent(hV, siggui.winviewer(varargin{:}));
      hV.Version = 1;
      
      
    end  % wvtool
    
    function set.Name(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Name')
      obj.Name = value;
    end
    
    function value = get.Legend(obj)
      value = getlegend(obj,obj.Legend);
    end
    
    function set.Legend(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Legend');
      obj.Legend = setlegend(obj,value);
    end
    
    function addwin(hV, winobjs, winvects, AddReplaceMode, currentindex, names)
      %ADDWIN Add windows to WVTool.
      %
      %   ADDWIN(HV, WINOBJS) adds the WINOBJS sigwin.window objects in the
      %   HV instance of WVTOOL.
      %
      %   ADDWIN(HV, WINOBJS, WINVECTS) adds the WINOBJS sigwin.window
      %   objects and the WINVECTS window vectors (cell array) into WVTool.
      %
      %   ADDWIN(HV, WINOBJS, WINVECTS, ADDREPLACEMODE) the ADDREPLACEMODE can be
      %   'Add' or 'Replace'(default).
      %
      %   ADDWIN(HV, WINOBJS, WINVECTS, ADDREPLACEMODE, CURRENTINDEX) allow the user to specify
      %   which window is the current one (bold and measured). By default, CURRENTINDEX = 1.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      if ~isrendered(hV)
        error(message('signal:sigtools:wvtool:addwin:notRendered'));
      end
      if nargin<4, AddReplaceMode = 'Replace'; end
      if nargin<5, currentindex = 1; end
      
      oldM = 0;
      oldN = 0;
      
      % Get the current line handles in the "Time domain" plot
      htline = findall(get(hV, 'FigureHandle'), 'Tag' , 'tline');
      
      % Replace mode replaces the current (last) window
      if strcmpi(AddReplaceMode, 'Replace') && ~isempty(htline)
        htline(1) = [];
      end
      
      % Reverse order to keep the same colors
      htline = htline(end:-1:1);
      
      % Get the size of the datas (oldN lines of oldM points)
      if ~isempty(htline)
        oldM = length(get(htline(1), 'YData'));
        oldN = length(htline);
      end
      
      % Number of new windows
      newNObj = length(winobjs);
      newNVect = length(winvects);
      newN = newNObj+newNVect;
      
      % Define the maximum length of the new windows
      winlength = zeros(1, newNObj)+newNVect;
      for i=1:newNObj
        winlength(i) = length(generate(winobjs{i}));
      end
      for i=1:newNVect
        winlength(newNObj+i) = length(winvects{i});
      end
      newM = max(winlength);
      
      % Generate a matrix of NaN that can contains all the datas
      M = max(oldM, newM);
      N = oldN+newN;
      data = NaN*ones(M,N);
      
      % Put the old datas in the matrix
      % Each window is store in a column of the data matrix
      for i = 1:oldN
        data(1:oldM,i) = get(htline(i), 'YData')';
        if nargin < 6
          names{i} = ['window#',num2str(i)];
        end
      end
      
      % Concatenate the new datas with the old ones in the matrix
      % Each window is store in a column of the data matrix
      for i = 1:newN
        if i<=newNObj
          vect = generate(winobjs{i});
          data(1:winlength(i),oldN+i) = vect(:);
        else
          vect = winvects{i-newNObj};
          data(1:winlength(i),oldN+i) = vect(:);
        end
        if nargin < 6
          names{oldN+i} = ['window#',num2str(oldN+i)];
        end
      end
      
      names = strrep(names, '_', '\_');
      
      % Plot the data in the viewer
      hView = getcomponent(hV, '-class', 'siggui.winviewer');
      
      % Specify the names used for the legend
      set(hView, 'Names', names);
      
      % Compute the spectral window
      [t, f, fresp] = spectralwin(hView, data);
      
      % Plot
      plot(hView, t, data, f, fresp);
      
      % Bold the first (current) window
      boldcurrentwin(hView, currentindex);
      
      % Measure the current window
      [FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, 1);
      
      % Display the measurements
      display_measurements(hView, FLoss, RSAttenuation, MLWidth);
      
    end
    
    function cbs = callbacks(hV)
      %CALLBACKS Callbacks of WVTool.
      %
      %   This method should be removed once we'll be able to define a callback
      %   as a method.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      cbs.close = {@close_cbs, hV};
      cbs.helpwvtool = @helpwvtool_cbs;
      
    end
    
    function close(hV)
      %CLOSE Close WVTool.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      % Send an event
      notify(hV, 'WVToolClosing');
      
      hFig = get(hV, 'FigureHandle');
      hView = getcomponent(hV, '-class', 'siggui.winviewer');
      destroy(hView);
      destroy(hV);
      delete(hFig);
      
    end
    
    function thisrender(this)
      %THISRENDER Render the wvtool object.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % Set up the figure handle
      hFig = setup_figure(this);
      
      % Render menus
      h.menus = render_menus(hFig,this);
      
      % Render toolbar
      h.toolbar = render_toolbar(hFig, this);
      
      % Store handles in object
      set(this,'Handles', h);
      
      % Render siggui.winviewer
      thisiew = getcomponent(this, '-class', 'siggui.winviewer');
      render(thisiew, hFig, [], 3);
      
      hL = siglayout.gridlayout(hFig, 'HorizontalGap', 5, 'VerticalGap', 5);
      hL.add(thisiew.Container, 1, 1);
      
      % Render the CSHelp button
      render_cshelpbtn(hFig, 'WVTool');
      
    end
    
    function visible_listener(hV, eventData)
      %VISIBLE_LISTENER Overload the base class method.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      hFig = get(hV, 'FigureHandle');
      visState = get(hV, 'Visible');
      set(hFig, 'Visible', visState);
      
      hView = getcomponent(hV, '-class', 'siggui.winviewer');
      set(hView, 'Visible', visState)
      
    end
    
  end  %% public methods
  
end  % classdef

function l = setlegend(this, l)

h = getcomponent(this, '-class', 'siggui.winviewer');
set(h, 'Legend', l);
end  % setlegend


% ------------------------------------------------------------------------
function l = getlegend(this, l)

h = getcomponent(this, '-class', 'siggui.winviewer');
l = get(h, 'Legend');
end  % getlegend


%-------------------------------------------------------------------
function close_cbs(hco, eventstruct, hV)

close(hV);

end

%-------------------------------------------------------------------
function helpwvtool_cbs(hco, eventstruct)

doc wvtool;

end


%-------------------------------------------------------------------
function hFig = setup_figure(this)

% Get the default background color
bgc  = get(0,'DefaultUicontrolBackgroundColor');

name = get(this, 'Name');

cbs = callbacks(this);

hFig = figure('CloseRequestFcn', cbs.close, ...
  'Color', bgc, ...
  'HandleVisibility', 'callback', ...
  'MenuBar', 'None', ...
  'NumberTitle', 'On', ...
  'IntegerHandle', 'On', ...
  'Name', name, ...
  'ToolBar', 'None', ...
  'Visible', 'off');

% Center figure
sz = local_gui_sizes(this);
origUnits = get(0, 'Units'); set(0, 'Units', 'Pixels');
screensize = get(0, 'ScreenSize'); set(0, 'Units', origUnits);
xpos = round((screensize(3)-sz.fig_w)/2);
ypos = round((screensize(4)-sz.fig_h)/2);
set(hFig, 'Position', [xpos ypos sz.fig_w sz.fig_h]);


% Print option default : don't print uicontrols (measurements)
pt = printtemplate;
pt.PrintUI = 0;
set(hFig, 'PrintTemplate', pt);

set(this, 'FigureHandle', hFig);

end

%-------------------------------------------------------------------
function sz = local_gui_sizes(this)

% Get the generic gui sizes
sz = gui_sizes(this);

% Figure width and height
sz.fig_w = 674*sz.pixf;
sz.fig_h = 335*sz.pixf;

end

%-------------------------------------------------------------------
function hmenus = render_menus(hFig,this)

% Render the "File" menu
hmenus.hfile = render_sptfilemenu(hFig);

set(findobj(hmenus.hfile, 'tag', 'print'),        'Callback', {@print_cb,     this});
set(findobj(hmenus.hfile, 'tag', 'printpreview'), 'Callback', {@printprev_cb, this});

% Render the "Edit" menu
hmenus.hedit = render_spteditmenu(hFig);

set(findobj(hmenus.hedit, 'Tag', 'figMenuEditCopyFigure'), 'Callback', {@copyfig_cb, this});

% Render the "Insert" menu
hmenus.hinsert = render_sptinsertmenu(hFig,3);

% Render the "Tools" menu
hmenus.htools = render_spttoolsmenu(hFig,4);

% Render the "Window" menu
hmenus.hwindow = render_sptwindowmenu(hFig,5);

% Render a Signal Processing Toolbox "Help" menu
hmenus.hhelp = render_helpmenu(hFig,this);

end

%-------------------------------------------------------------------
function hhelp = render_helpmenu(hFig,this)

[hhelpmenu, hhelpmenuitems] = render_spthelpmenu(hFig,6);

strs  = getString(message('signal:sigtools:sigtools:WhatsThis'));
cbs   = {@cshelpgeneral_cb, 'WinView'};
tags  = 'whatsthis';
sep   = 'on';
accel = '';
hwhatsthis = addmenu(hFig,[6 2],strs,cbs,tags,sep,accel);

cbs = callbacks(this);
strs  = getString(message('signal:sigtools:sigtools:WVToolHelp'));
cb    = cbs.helpwvtool;
tags  = 'wvtool help';
sep   = 'off';
accel = '';
hwvtoolhelp = addmenu(hFig,[6 1],strs,cb,tags,sep,accel);


hhelp = [hwvtoolhelp, hhelpmenu, hhelpmenuitems(1), hwhatsthis, hhelpmenuitems(2:end)];

end

%-------------------------------------------------------------------
function htoolbar = render_toolbar(hFig, this)

htoolbar.htoolbar = uitoolbar('Parent',hFig);

% Render Print buttons (Print, Print Preview)
htoolbar.hprintbtns = render_sptprintbtns(htoolbar.htoolbar);

set(findobj(htoolbar.hprintbtns, 'tag', 'printresp'), ...
  'ClickedCallback', {@print_cb,     this});
set(findobj(htoolbar.hprintbtns, 'tag', 'printprev'), ...
  'ClickedCallback', {@printprev_cb, this});

% Render the annotation buttons (Edit Plot, Insert Arrow, etc)
htoolbar.hscribebtns = render_sptscribebtns(htoolbar.htoolbar);

% Render the zoom buttons
htoolbar.hzoombtns = render_zoombtns(hFig);

end

%-------------------------------------------------------------------
function copyfig_cb(hcbo, eventStruct, this)

hFig    = get(this, 'FigureHandle');
old_ppm = get(hFig, 'PaperPositionMode');
set(hFig, 'PaperPositionMode', 'auto');

hv = getcomponent(this, '-class', 'siggui.winviewer');
copyfigure(hv);

set(hFig, 'PaperPositionMode', old_ppm);

end

%-------------------------------------------------------------------
function print_cb(hcbo, eventStruct, this)

hFig = get(this, 'FigureHandle');
old_resize = get(hFig, 'ResizeFcn');
set(hFig, 'ResizeFcn', []);

hv = getcomponent(this, '-class', 'siggui.winviewer');
print(hv, ...
  'PaperUnits', get(hFig, 'PaperUnits'), ...
  'PaperOrientation', get(hFig, 'PaperOrientation'), ...
  'PaperPosition', get(hFig, 'PaperPosition'), ...
  'PaperSize', get(hFig, 'PaperSize'), ...
  'PaperType', get(hFig, 'PaperType'));

set(hFig, 'ResizeFcn', old_resize);

end

%-------------------------------------------------------------------
function printprev_cb(hcbo, eventStruct, this)

hFig = get(this, 'FigureHandle');
old_resize = get(hFig, 'ResizeFcn');
set(hFig, 'ResizeFcn', []);

hv = getcomponent(this, '-class', 'siggui.winviewer');
printpreview(hv, ...
  'PaperUnits', get(hFig, 'PaperUnits'), ...
  'PaperOrientation', get(hFig, 'PaperOrientation'), ...
  'PaperPosition', get(hFig, 'PaperPosition'), ...
  'PaperSize', get(hFig, 'PaperSize'), ...
  'PaperType', get(hFig, 'PaperType'));

% Ensure that the figure is available before updating the ResizeFcn.
if ishghandle(hFig)
  set(hFig, 'ResizeFcn', old_resize);
end

end
