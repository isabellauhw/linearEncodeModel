classdef winmanagement < siggui.sigguiMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.winmanagement class
  %   siggui.winmanagement extends siggui.siggui.
  %
  %    siggui.winmanagement properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Window_list - Property is of type 'siggui.winspecs vector' (read only)
  %       Selection - Property is of type 'mxArray' (read only)
  %       Currentwin - Property is of type 'mxArray' (read only)
  %
  %    siggui.winmanagement methods:
  %       addnewwin - Add a new window to the list
  %       callbacks - Callbacks for the window management component
  %       copy_selection - Make a copy of the selected windows and add them to the list
  %       currentwin_listener - SELECTION_LISTENER Callback executed by listener to the currentwin property.
  %       defaultwindow - Instantiate a default window specifications object
  %       delete_selection - Delete the selected window
  %       enable_listener - Overload the siggui superclass's enable listener
  %       newcurrentwinindex_eventcb - NEWCURRETWININDEX_EVENTCB
  %       newcurrentwinstate_eventcb - NEWCURRETWINSTATE_EVENTCB
  %       save_selection - Save the selected windows to worskspace
  %       selection_listener - Callback executed by listener to the selection property.
  %       set_currentwin - SET_CURRETWIN Set the Currentwin property
  %       set_currentwin_state - SET_CURRETWIN_STATE Sets the state of the current window
  %       set_selection - Set the Selection property
  %       thisrender - Render the window Management component
  %       window_list_listener - Callback executed by listener to the Window_list property.
  
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %NBWIN Property is of type 'int32'
    Nbwin;
    %LISTENERS Property is of type 'handle vector'
    Listeners = [];
  end
  
  properties (SetAccess=protected, SetObservable, GetObservable)
    %WINDOW_LIST Property is of type 'siggui.winspecs vector' (read only)
    Window_list = [];
    %SELECTION Property is of type 'mxArray' (read only)
    Selection = [];
    %CURRENTWIN Property is of type 'mxArray' (read only)
    Currentwin = [];
  end
  
  
  events
    NewSelection
    NewCurrentwin
  end  % events
  
  methods  % constructor block
    function hManag = winmanagement
      %WINMANAGEMENT Constructor for the winmanagement object.
      
      %   Author(s): V.Pellissier
      
      % Set up the default
      hManag.Nbwin = 0;
      hManag.Version = 1;
      
      % Install listeners
      installListeners(hManag);
    end  % winmanagement
    
    function set.Window_list(obj,value)
      % DataType = 'siggui.winspecs vector'
      validateattributes(value,{'siggui.winspecs'}, {'vector'},'','Window_list')
      obj.Window_list = value;
    end
    
    function set.Selection(obj,value)
      obj.Selection = value;
    end
    
    function set.Currentwin(obj,value)
      obj.Currentwin = value;
    end
    
    function set.Nbwin(obj,value)
      % DataType = 'int32'
      validateattributes(value,{'numeric'}, {'scalar'},'','Nbwin')
      obj.Nbwin = value;
    end
    
    function set.Listeners(obj,value)
      % DataType = 'handle vector'
      validateattributes(value,{'handle'}, {'vector'},'','Listeners')
      obj.Listeners = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function addnewwin(hManag, newwin)
      %ADDNEWWIN Add a new window to the list
      %   ADDNEWWIN(HMANAG, NEWWIN) adds a new siggui.winspecs object NEWWIN
      %   into the winmanagement component HMANAG.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      % Error checking
      if ~isa(newwin, 'siggui.winspecs')
        error(message('signal:siggui:winmanagement:addnewwin:InternalError'));
      end
      
      % Add the new window on top of the list
      winlist = hManag.Window_list;
      hManag.Window_list = [newwin; winlist];
      
      % Add the new window to selection      
      hManag.Selection = 1;
      
      % Make the new window the current one
      hManag.Currentwin = 1;
      
      % Increase counter
      nb_win = hManag.Nbwin;
      hManag.Nbwin = nb_win+1;
      
    end
    
    function cbs = callbacks(hManag)
      %CALLBACKS Callbacks for the window management component
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % This can be a private method
      
      cbs.set_selection    = {@listbox_cbs, hManag};
      cbs.addnewwin        = {@addnewwin_cbs, hManag};
      cbs.copywindow       = {@copywindow_cbs, hManag};
      cbs.save_selection   = {@save_cbs, hManag};
      cbs.delete_selection = {@delete_cbs, hManag};
      
    end
    
    function copy_selection(hManag)
      %COPY_SELECTION Make a copy of the selected windows and add them to the list
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      % Get the selected windows
      winlist = hManag.Window_list;
      select = hManag.Selection;
      if isempty(select)
        error(message('signal:siggui:winmanagement:copy_selection:InternalError'));
      end
      selectedlist = winlist(select);
      
      for i = 1:length(selectedlist)
        hcopy = copy(selectedlist(i));
        % Change the name of the copy
        name = selectedlist(i).Name;
        newname = ['copy_of_', name];
        if length(newname) > 63
          newname(64:end) = [];
        end
        hcopy.Name =  newname;
        % Add the copy to the list
        addnewwin(hManag, hcopy);
      end
      
      
    end
    
    function currentwin_listener(hManag, eventData) %#ok<INUSD>
      %SELECTION_LISTENER Callback executed by listener to the currentwin property.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      newpos = hManag.Currentwin;
      winlist = hManag.Window_list;
      
      % Send an event
      hEventData = sigdatatypes.sigeventdataMCOS(hManag, 'NewCurrentwin', winlist(newpos));
      notify(hManag, 'NewCurrentwin', hEventData);
      
      
    end
    
    function win = defaultwindow(hManag)
      %DEFAULTWINDOW Instantiate a default window specifications object
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2018 The MathWorks, Inc.
      
      % Instantiate window specifications object
      win = siggui.winspecs;
      
      % Generate a default name
      nb_win = hManag.Nbwin;
      defaultname = ['window_',num2str(nb_win+1)];
      
      % Ensure that we do not choose an existing name
      if isprop(hManag,'Window_list') && ~isempty(hManag.Window_list)
          currentNames = {hManag.Window_list.Name};
          done = false;
          cnt = 0;
          while ~done
              if any(strcmp(defaultname,currentNames))
                  cnt = cnt + 1;
                  defaultname = ['window_',num2str(nb_win+1+cnt)];
              else
                  done = true;
              end
          end
      end
      
      % Instantiate default window object
      defaultwin = sigwin.hamming; %#ok<DHMMNG>
      
      % Set state of winspecs object
      win.Window = defaultwin;
      win.Name = defaultname;
      
      apply(win);
      
    end
    
    function delete_selection(hManag)
      %DELETE_SELECTION Delete the selected window
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Delete selection
      winlist = hManag.Window_list;
      select = hManag.Selection;
      if isempty(select)
        error(message('signal:siggui:winmanagement:delete_selection:InternalError'));
      end
      delete(winlist(select));
      winlist(select) = [];
      
      % Update the properties
      hManag.Window_list = winlist;
      if isempty(winlist)
        hManag.Selection = [];
        % Reset counter
        hManag.Nbwin = 0;
      else
        hManag.Selection = 1;
      end
      
    end
    
    function enable_listener(hManag, eventData) %#ok<INUSD>
      %ENABLE_LISTENER Overload the siggui superclass's enable listener
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      enabState = hManag.Enable;
      h = handles2vector(hManag);
      set(h, 'Enable', enabState)
      
      if strcmpi(enabState, 'on')
        % Fire listener to update the state of the listbox
        hManag.Window_list = hManag.Window_list;
        % Fire listener to update the state of the buttons
        hManag.Selection = hManag.Selection;
      else
        % Turn the backgroundcolor of the listbox
        hFig = hManag.FigureHandle;
        hndls = hManag.Handles;
        set(hndls.listbox, 'BackgroundColor', get(hFig, 'Color'));
      end
      
      
    end
    
    
    function newcurrentwinindex_eventcb(hManag, eventData)
      %NEWCURRETWININDEX_EVENTCB
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Callback executed by the listener to an event thrown by another component.
      % The Data property stores an index of the selection
      
      % Restore names in case a name was changed but apply button was never
      % pressed. Since we are changing the selection we need to revert the
      % name. 
      windows = hManag.Window_list(hManag.Selection);
      winNames = {windows.Name};
      popup = get(eventData.Source,'Handles');
      if isfield(popup,'winname')
          popup = popup.winname;
          popup.String = winNames;
      end
      
      index = eventData.Data;
      
      % Set the Currentwin property
      set_currentwin(hManag, index);
      
    end
    
    function newcurrentwinstate_eventcb(hManag, eventData)
      %NEWCURRETWINSTATE_EVENTCB
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Callback executed by the listener to an event thrown by another component.
      % The Data property stores the state of a winspecs object
      currentNames = {hManag.Window_list.Name};
      currentWinIdx = hManag.Currentwin;
      currentNames(currentWinIdx) = [];            
      newName = eventData.Source.Name;
      
      if any(strcmp(newName,currentNames))            
          senderror(hManag, ['''' newName ''' ' getString(message('signal:sigtools:siggui:IsNotAUniqueName'))]);
          return
      end
      
      state = eventData.Data;
      
      % Sets the state of the current window
      set_currentwin_state(hManag, state);
      
    end
    
    function save_selection(hManag)
      %SAVE_SELECTION Save the selected windows to worskspace
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      % Get the handles of the selected windows
      winlist = hManag.Window_list;
      select = hManag.Selection;
      if isempty(select)
        error(message('signal:siggui:winmanagement:save_selection:InternalError'));
      end
      selectedlist = winlist(select);
      
      for i = 1:length(selectedlist)
        name = get(selectedlist(i), 'Name');
        data = get(selectedlist(i), 'Data');
        if isvarname(name)
          % Assign the Data property to the Name property
          assignin('base', name, data);
          fprintf('%s\n',getString(message('signal:sigtools:siggui:HasBeenExportedToTheWorkspace', name)))
        else
          disp(getString(message('signal:sigtools:siggui:WinmanagementInternalErrorInvalidVariableName')))
        end
      end
      
    end
    
    function selection_listener(hManag, eventData) %#ok<INUSD>
      %SELECTION_LISTENER Callback executed by listener to the selection property.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      winlist = hManag.Window_list;
      select = hManag.Selection;
      
      % Update the GUI
      if isrendered(hManag)
        hndls = get(hManag,'Handles');
        hlistbox = hndls.listbox;
        pb_hndls = hndls.pbs;
        if isempty(select)
          % Disable delete copy and save buttons when the selection is empty
          set(pb_hndls(2:4), 'Enable', 'off');
        else
          set(pb_hndls(2:4), 'Enable', 'on');
        end
        set(hlistbox, 'Value', select);
      end
      
      % By default, the current window is the first of selection
      if isempty(select)
        hManag.Currentwin = [];
      else
        currentwin = hManag.Currentwin;
        if isempty(currentwin) || all(currentwin~=select)
          % Reset the currentwin property
          hManag.Currentwin = select(end);
        end
      end
      
      
      % Send an event
      s.selectedwindows = winlist(select);
      s.selection = select;
      s.currentindex = hManag.Currentwin;
      hEventData = sigdatatypes.sigeventdataMCOS(hManag, 'NewSelection', s);
      notify(hManag, 'NewSelection', hEventData);
      
    end
    
    
    function set_currentwin(hManag, index)
      %SET_CURRETWIN Set the Currentwin property
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Error ckecking
      if index < 0 || ~isequal(index,floor(index)) || length(index)>1
        error(message('signal:siggui:winmanagement:set_currentwin:InternalErrorPositive', 'winmanagement'))
      end
      selection = hManag.Selection;
      if index > length(selection)
        error(message('signal:siggui:winmanagement:set_currentwin:InternalErrorInvalidDim', 'winmanagement'));
      end
      
      % Sets the Currentwin property
      hManag.Currentwin = selection(index);
      
    end
    
    function set_currentwin_state(hManag, state)
      %SET_CURRETWIN_STATE Sets the state of the current window
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Gets the handle to the current window
      winlist = hManag.Window_list;
      index = hManag.Currentwin;
      currentwin = winlist(index);
      
      % Sets the state of the current window
      setstate(currentwin, state);
      
      % Fire listeners
      hManag.Window_list = hManag.Window_list;
      hManag.Selection = hManag.Selection;
      hManag.Currentwin = index;
      
    end
    
    
    function set_selection(hManag, selection)
      %SET_SELECTION Set the Selection property
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Error checking
      winlist = hManag.Window_list;
      N = length(winlist);
      if any(selection<0) || any(selection>N) || ~isequal(selection, floor(selection))
        error(message('signal:siggui:winmanagement:set_selection:InternalError'))
      end
      
      % Set the Selection property
      hManag.Selection = selection;
      
      
    end
    
    
    function thisrender(this, hFig, pos)
      %THISRENDER Render the window Management component
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      if nargin < 3 , pos =[]; end
      if nargin < 2 , hFig = gcf; end
      
      sz = gui_sizes(this);
      if isempty(pos)
        pos = [10 10 413 212]*sz.pixf;
      end
      
      cbs = callbacks(this);
      
      hPanel = uipanel('Parent', hFig, ...
        'Units', 'Pixels', ...
        'Position', pos, ...
        'Visible', 'Off', ...
        'Title', getString(message('signal:sigtools:siggui:WindowList')));
      
      hLayout = siglayout.gridbaglayout(hPanel);
      
      set(hLayout, ...
        'HorizontalGap',     15, ...
        'VerticalWeights',   [0 0 0 0 0 1], ...
        'HorizontalWeights', [1 0]);
      
      h.text = uicontrol(hPanel, 'Style', 'text', ...
        'Enable', 'on', ...
        'HorizontalAlignment', 'left', ...
        'String', getString(message('signal:sigtools:siggui:SelectWindowsToDisplay')));
      
      hLayout.add(h.text, 1, [1 2], ...
        'MinimumWidth', 100*sz.pixf, ...
        'MinimumHeight', sz.uh, ...
        'TopInset', 20*sz.pixf, ...
        'Fill', 'Horizontal');
      
      h.listbox = uicontrol(hPanel, 'Style', 'listbox',...
        'Max', 2, ...
        'Callback', cbs.set_selection);
      
      hLayout.add(h.listbox, 2:6, 1, ...
        'Fill', 'Both', ...
        'BottomInset', 10*sz.pixf);
      
      actionStrs = {getString(message('signal:sigtools:siggui:AddANewWindow')), ...
        getString(message('signal:sigtools:siggui:CopyWindow')), ...
        getString(message('signal:sigtools:siggui:SaveToWorkspace')), ...
        getString(message('signal:sigtools:siggui:Delete'))};
      
      tags = {'addwindow', ...
        'copywindow', ...
        'savewindow', ...
        'delete'};
      
      cb = callbacks(this);
      cbs = {cb.addnewwin, cb.copywindow, cb.save_selection, cb.delete_selection};
      
      % Render buttons from bottom to top
      for n=1:length(actionStrs)
        
        h.pbs(n)=uicontrol(hPanel, ...
          'Style',    'pushbutton',...
          'String',   actionStrs{n},...
          'Tag',      tags{n},...
          'Interruptible', 'Off', ...
          'BusyAction', 'cancel', ...
          'Callback', cbs{n});
        
        hLayout.add(h.pbs(n), 1+n, 2, ...
          'MinimumWidth', 123*sz.pixf, ...
          'BottomInset', 10*sz.pixf, ...
          'TopInset', 10*sz.pixf, ...
          'MinimumHeight', sz.bh);
      end
      
      % Store handles in object
      set(this, 'Handles', h, ...
        'FigureHandle', hFig, ...
        'Container', hPanel);
      
      % Install listeners
      installWindowListeners(this);
      
      % Add context-sensitive help
      cshelpcontextmenu(this, 'wintool_winmanagement_frame', 'WinTool');
      
      % Fire listeners to sync the GUI state with the object properties
      window_list_listener(this);
      selection_listener(this);
      
      
    end
    
    function window_list_listener(hManag, eventData) %#ok<INUSD>
      %WINDOW_LIST_LISTENER Callback executed by listener to the Window_list property.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Get the names of all the windows
      newlist = hManag.Window_list;
      
      if ~isempty(newlist)
        names = get(newlist,'Name');
      else
        names=[];
      end
      
      % Update the listbox string
      hndls = hManag.Handles;
      hlistbox = hndls.listbox;
      if isempty(names)
        names = ' ';
        hFig = get(hManag, 'FigureHandle');
        color = get(hFig, 'Color');
        % Disable listbox
        set(hlistbox, 'Enable', 'off');
      else
        color = 'White';
        set(hlistbox, 'Enable', 'on');
      end
      set(hlistbox, 'String', names, 'BackgroundColor', color);
      
    end
    
  end  %% public methods
  
end  % classdef

function installListeners(hManag)

listener(1) = event.proplistener(hManag, hManag.findprop('Selection'),'PostSet',@(s,e)selection_listener(hManag));
listener(2) = event.proplistener(hManag, hManag.findprop('Currentwin'),'PostSet', @(s,e)currentwin_listener(hManag));

% Save the listeners
% The following listeners need to be fired even if the object is
% not rendered because they send events
hManag.Listeners = listener;


end  % installListeners


%-------------------------------------------------------------------------
function listbox_cbs(hcbo, eventstruct, hManag) %#ok<INUSL>

select = get(hcbo, 'Value');
set_selection(hManag, select);

end

%-------------------------------------------------------------------------
function addnewwin_cbs(hcbo, eventstruct, hManag) %#ok<INUSL>

newwin = defaultwindow(hManag);
addnewwin(hManag, newwin);

end

%-------------------------------------------------------------------------
function copywindow_cbs(hcbo, eventstruct, hManag) %#ok<INUSL>

copy_selection(hManag);

end

%-------------------------------------------------------------------------
function save_cbs(hcbo, eventstruct, hManag) %#ok<INUSL>

save_selection(hManag);

end


%-------------------------------------------------------------------------
function delete_cbs(hcbo, eventstruct, hManag) %#ok<INUSL>

delete_selection(hManag);

end

%---------------------------------------------------------------------
function installWindowListeners(this)

% Create the listeners
listener    = event.proplistener(this, this.findprop('Window_list'), ...
  'PostSet', @(s,e)window_list_listener(this));

% Save the listeners
set(this, 'WhenRenderedListeners', listener);

end
