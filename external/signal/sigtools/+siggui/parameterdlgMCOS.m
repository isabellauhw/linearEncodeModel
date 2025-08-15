classdef parameterdlgMCOS < siggui.helpdialogMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.parameterdlg class
  %   siggui.parameterdlg extends siggui.helpdialog.
  %
  %    siggui.parameterdlg properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Name - Property is of type 'String'
  %       Label - Property is of type 'String'
  %       Parameters - Property is of type 'sigdatatypes.parameter vector'
  %       HelpLocation - Property is of type 'string vector'
  %       Tool - Property is of type 'string'
  %       StaticParameters - Property is of type 'string vector'
  %       DisabledParameters - Property is of type 'string vector'
  %
  %    siggui.parameterdlg methods:
  %       action - Perform the action of the parameter dialog
  %       cancel - Perform the cancel action of the Parameter Dialog
  %       disabledparameters_listener - Listener to the disabledparameters property
  %       disableparameter - Disable a parameter by it's tag
  %       enableparameter - Enable a parameter on the parameter dialog
  %       getvaluesfromgui - Gets the parameter values from the GUI
  %       help - Help for the dialog
  %       label_listener - Listener to the label property
  %       makedefault -   Make these parameters the defaults.
  %       name_listener - Listener to the title property
  %       parameter_gui_sizes - GUI sizes and spaces for the export dialog
  %       parameters_listener - Listener to the parameters Property
  %       render_controls - Render the controls for the parameter dialog
  %       resetoperations - Parameter dialog does not use reset operations
  %       setup_figure - Create the figure for the parameter dialog
  %       setvaluesingui -   Set the values in the gui
  %       thisunrender - Unrender for the parameter dialog
  %       update_uis -   Update the UIControls
  %       usermodified_eventcb - Callback to the 'UserModified' event of the PARAMETER
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %NAME Property is of type 'String'
    Name = '';
    %LABEL Property is of type 'String'
    Label = '';
    %PARAMETERS Property is of type 'sigdatatypes.parameter vector'
    Parameters = [];
    %HELPLOCATION Property is of type 'string vector'
    HelpLocation
    %TOOL Property is of type 'string'
    Tool = '';
    %STATICPARAMETERS Property is of type 'string vector'
    StaticParameters = {};
    %DISABLEDPARAMETERS Property is of type 'string vector'
    DisabledParameters;
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %USERMODIFIEDLISTENER Property is of type 'handle.listener'
    UserModifiedListener = [];
  end
  
  
  methods  % constructor block
    function hPD = parameterdlgMCOS(hPrm, name, label)
      %PARAMETERDIALOG Create a parameter dialog object
      %   SIGGUI.PARAMETERDIALOG(hPRM) Create a parameter dialog object using the
      %   parameters in hPRM.  hPRM must be a vector of SIGDATATYPES.PARAMETER
      %   objects.
      
      %   Author(s): J. Schickler
      
      narginchk(1,3);
      
      if nargin < 3
        label = 'Set Parameters';
      end
      
      if nargin < 2
        name  = 'Set Parameters';
      end
      
      hPD.Parameters = hPrm;
      hPD.Name = name;
      hPD.Label = label;
      hPD.Version = 1;
      
    end  % parameterdlg
    
    function set.Name(obj,value)
      % DataType = 'String'
      % no cell string checks yet'
      obj.Name = value;
    end
    
    function set.Label(obj,value)
      % DataType = 'String'
      % no cell string checks yet'
      obj.Label = value;
    end
    
    function set.Parameters(obj,value)
      % DataType = 'sigdatatypes.parameter vector'
      if ~isempty(value)
        validateattributes(value,{'sigdatatypes.parameter'}, {'vector'},'','Parameters')
      end
      obj.Parameters = value;
    end
    
    function set.HelpLocation(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.HelpLocation = value;
    end
    
    function set.Tool(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Tool')
      obj.Tool = value;
    end
    
    function set.StaticParameters(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.StaticParameters = value;
    end
    
    function set.DisabledParameters(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.DisabledParameters = value;
    end
    
    function set.UserModifiedListener(obj,value)
      % DataType = 'handle.listener'
      if ~isempty(value)
        validateattributes(value,{'handle.listener'}, {'scalar'},'','UserModifiedListener')
      end
      obj.UserModifiedListener = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    
    function aClose = action(hDlg)
      %ACTION Perform the action of the parameter dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      aClose = true;
      
      h = get(hDlg, 'Handles');
      
      allPrm = get(hDlg, 'Parameters');
      
      msg = '';
      for indx = 1:length(h.controls)
        l{indx} = getappdata(h.controls(indx).edit, 'ParameterListener');
        set(l{indx}, 'Enabled', 'Off');
        
        val{indx} = getvaluesfromgui(hDlg,indx);
      end
      
      if length(val) == 1
        val = val{1};
      end
      
      msg = setvalue(allPrm, val);
      
      if ~isempty(msg)
        
        for indx = 1:length(allPrm)
          hPrm = allPrm(indx);
          if ~isempty(strfind(msg, hPrm.Tag))
            if iscell(hPrm.ValidValues)
              popindx = find(strcmpi(hPrm.Value, hPrm.ValidValues));
              set(h.controls(indx).specpopup, 'Value', popindx);
            else
              set(h.controls(indx).edit, 'String', hPrm.Value);
            end
          end
        end
      end
      
      set([l{:}], 'Enabled', 'On');
      
      % Since we shut off the listeners, there may be updates that need to be
      % made.
      send(allPrm, 'ForceUpdate');
      
      % Call setvalue again, now with no output arguments so that an error is
      % thrown if one occurs.
      setvalue(allPrm, val);
      
    end
    
    function cancel(this)
      %CANCEL Perform the cancel action of the Parameter Dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      if isrendered(this)
        set(this, 'Visible', 'Off');
        
        dp = get(this, 'DisabledParameters');
        
        % Redraw the controls
        parameters_listener(this);
        this.DisabledParameters = dp;
      end
      
      % Reset the parameters.
      hPrm = get(this, 'Parameters');
      for indx = 1:length(hPrm)
        send(hPrm(1), 'UserModified', sigdatatypes.sigeventdata(hPrm(1), ...
          'UserModified', get(hPrm(1), 'Value')));
      end
      
    end
    
    function disabledparameters_listener(hDlg, eventData)
      %DISABLEDPARAMETERS_LISTENER Listener to the disabledparameters property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      if isempty(hDlg.Parameters), return; end
      
      hPrm    = get(hDlg, 'Parameters');
      dparams = get(hDlg, 'DisabledParameters');
      h       = get(hDlg, 'Handles');
      tags    = get(hPrm, 'Tag');
      
      dindx = [];
      
      % Find the indices of the parameters to disable.
      for i = 1:length(dparams)
        dindx = [dindx find(strcmpi(dparams{i}, tags))];
      end
      
      eindx = setdiff(1:length(h.controls), dindx);
      
      if ~isempty(dindx)
        setenableprop(convert2vector(h.controls(dindx)), 'Off');
      end
      if ~isempty(eindx)
        setenableprop(convert2vector(h.controls(eindx)), hDlg.Enable);
      end
      
      
      for indx = 1:length(hPrm)
        vv = get(hPrm(indx), 'ValidValues');
        if iscell(vv) & length(vv) == 1
          setenableprop(convert2vector(h.controls(indx)), 'Off');
        end
      end
      
    end
    
    function disableparameter(hDlg, tag)
      %DISABLEPARAMETER Disable a parameter by it's tag
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(2,2);
      
      if ~ischar(tag)
        error(message('signal:siggui:parameterdlg:disableparameter:MustBeAString'));
      end
      
      tags = get(hDlg.Parameters, 'Tag');
      
      indx = find(strcmpi(tag, tags), 1);
      
      if isempty(indx)
        error(message('signal:siggui:parameterdlg:disableparameter:NotSupported'));
      end
      
      dparams = hDlg.DisabledParameters;
      
      % Only use store the string if it is not already in the vector.
      if isempty(find(strcmpi(tag, dparams), 1))
        dparams = {dparams(:), tag};
      end
      
      hDlg.DisabledParameters = dparams;
      
    end
    
    function enableparameter(hDlg, tag)
      %ENABLEPARAMETER Enable a parameter on the parameter dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      dparams = get(hDlg, 'DisabledParameters');
      
      indx = find(strcmpi(tag, dparams));
      
      if ~isempty(indx)
        dparams(indx) = [];
      end
      
      hDlg.DisabledParameters = dparams;
      
    end
    
    function values = getvaluesfromgui(this, indx)
      %GETVALUESFROMGUI Gets the parameter values from the GUI
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      if nargin == 1
        for i = 1:length(this.Parameters)
          values{i} = getvalue(this, i);
        end
      else
        if isa(indx, 'sigdatatypes.parameter')
          indx = get(indx, 'Tag');
          if iscell(indx)
            for jndx = 1:length(indx)
              values{jndx} = getvalue(this, find(strcmpi(get(this.Parameters, 'Tag'), indx{jndx})));
            end
            return;
          end
        end
        if ischar(indx)
          indx = find(strcmpi(get(this.Parameters, 'Tag'), indx));
        end
        values = getvalue(this, indx);
      end
      
    end
    
    
    function help(hObj)
      %HELP Help for the dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      str = get(hObj, 'HelpLocation');
      
      if isempty(str)
        doc signal
      else
        helpview(str{:});
      end
      
      
    end
    
    
    function label_listener(hDlg, eventData)
      %LABEL_LISTENER Listener to the label property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      name = get(hDlg, 'Label');
      sz   = gui_sizes(hDlg);
      
      % Determine the proper width of the label
      h   = get(hDlg, 'Handles');
      width = largestuiwidth({name});
      
      % h.frame(1) is the frame.
      origUnits = get(h.frame(1), 'Units');
      set(h.frame(1), 'Units', 'Pixels');
      posF = get(h.frame(1), 'Position');
      set(h.frame(1), 'Units', origUnits);
      
      % Make sure that the width doesn't exceed the frame
      if width > posF(3) - sz.hfus
        width = posF(3) - sz.hfus;
      end
      
      % h.frame(2) is the label
      origUnits = get(h.frame(2), 'Units');
      set(h.frame(2), 'Units', 'Pixels');
      pos = get(h.frame(2), 'Position');
      pos(3) = width;
      
      visState = get(hDlg, 'Visible');
      if isempty(name)
        visState = 'Off';
      end
      
      % Set the new name and position
      set(h.frame(2), ...
        'Position', pos, ...
        'String', name, ...
        'Units', origUnits);
      
    end
    
    function makedefault(this)
      %MAKEDEFAULT   Make these parameters the defaults.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      hPrm = get(this, 'Parameters');
      
      % We do not save disabled or static parameters.
      for indx = 1:length(this.DisabledParameters)
        hPrm = find(hPrm, '-not', 'tag', this.DisabledParameters{indx});
      end
      
      for indx = 1:length(this.StaticParameters)
        hPrm = find(hPrm, '-not', 'tag', this.StaticParameters{indx});
      end
      
      if isempty(hPrm), return; end
      
      values = getvaluesfromgui(this, hPrm);
      
      makedefault(hPrm, this.Tool, values);
      
    end
    
    function name_listener(hDlg, hPrm)
      %NAME_LISTENER Listener to the title property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      set(hDlg.FigureHandle, 'Name', hDlg.Name);
      
    end
    
    function sz = parameter_gui_sizes(this)
      %PARAMETER_GUI_SIZES GUI sizes and spaces for the export dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      sz    = dialog_gui_sizes(this);
      count = length(this.Parameters);
      
      sz.makedefault = largestuiwidth({getString(message('signal:sigtools:siggui:SaveAsDefault'))})+16*sz.pixf;
      sz.restore     = largestuiwidth({getString(message('signal:sigtools:siggui:RestoreOriginalDefaults'))})+16*sz.pixf;
      
      % Set up the fig position using the # of parameters
      % [",", 40 +.., "] added to increase to fit Japanese Characters - g897246
      sz.fig    = [300 500 40+sz.hfus*4+sz.uuhs+sz.makedefault+sz.restore ...
        85+(sz.uuvs+sz.uh)*count/sz.pixf] * sz.pixf;
      % if isunix, sz.fig(3) = sz.fig(3)+30*sz.pixf; end
      
      frY       = sz.button(2) + sz.button(4) + sz.vfus;
      sz.frame  = [sz.hfus frY sz.fig(3)-2*sz.hfus sz.fig(4)-frY - 2*sz.vfus];
      
    end
    
    function parameters_listener(hPD, eventData)
      %PARAMETERS_LISTENER Listener to the parameters Property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % This is a when rendered listener
      
      % Update the size of the figure
      fix_figure(hPD);
      
      % Delete the old handles.  This will leave the dialog buttons because they
      % are stored in DialogHandles
      delete(handles2vector(hPD));
      
      % Render the controls for the new parameters.
      render_controls(hPD);
      
      hPD.DisabledParameters = {''};
      
    end
    
    function render_controls(this)
      %RENDER_CONTROLS Render the controls for the parameter dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % This should be a private method
      
      render_frame(this);
      render_parameters(this);
      render_buttons(this);
      update_uis(this);
      
    end
    
    function resetoperations(hPD)
      %RESETOPERATIONS Parameter dialog does not use reset operations
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % NO OP
      % We do not want to listen to any of the properties.  Cancel takes care of this.
      
    end
    
    function setup_figure(hPD)
      %SETUP_FIGURE Create the figure for the parameter dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      sz  = parameter_gui_sizes(hPD);
      cbs = dialog_cbs(hPD);
      
      hFig = figure('Position', sz.fig, ...
        'IntegerHandle',    'Off', ...
        'NumberTitle',      'Off', ...
        'Name',             hPD.Name, ...
        'MenuBar',          'None', ...
        'HandleVisibility', 'Off', ...
        'Resize',           'Off', ...
        'Color',            get(0,'DefaultUicontrolBackgroundColor'), ...
        'Visible',          hPD.Visible);
      
      set(hPD, 'FigureHandle', hFig);
      
    end
    
    function setvaluesingui(this, indx, value)
      %SETVALUESINGUI   Set the values in the gui
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      narginchk(3,3);
      
      if isa(indx, 'sigdatatypes.parameter')
        indx = get(indx, 'Tag');
      elseif ischar(indx)
        indx  = find(strcmpi(get(this.Parameters, 'Tag'), indx));
        value = {value};
      elseif iscell(indx)
        for jndx = 1:length(indx)
          indx{jndx} = find(strcmpi(get(this.Parameters, 'Tag'), indx{jndx}));
        end
        indx = [indx{:}];
      end
      
      for jndx = 1:length(indx)
        lclsetvalue(this, indx(jndx), value{jndx});
      end
      
    end
    
    
    function thisunrender(this)
      %THISUNRENDER Unrender for the parameter dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      for indx = 1:numel(this.BaseListeners)
        delete(this.BaseListeners{indx});
      end
      
      hFig = get(this, 'FigureHandle');
      if ~isempty(hFig) && ishghandle(hFig)
        delete(hFig);
      end
      
    end
    
    
    function update_uis(this, eventData)
      %UPDATE_UIS   Update the UIControls
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      if isempty(this.Parameters), return; end
      
      hPrm    = get(this, 'Parameters');
      sparams = get(this, 'StaticParameters');
      dparams = get(this, 'DisabledParameters');
      h       = get(this, 'Handles');
      tags    = get(hPrm, 'Tag');
      
      sindx = [];
      dindx = [];
      
      % Find the indices of the parameters to make static.
      for i = 1:length(sparams)
        sindx = [sindx find(strcmpi(sparams{i}, tags))];
      end
      
      % Find the indices of the parameters to disable.
      for i = 1:length(dparams)
        dindx = [dindx find(strcmpi(dparams{i}, tags))];
      end
      
      eindx = setdiff(1:length(h.controls), sindx);
      
      if ~isempty(sindx)
        for indx = 1:length(sindx)
          hui = h.controls(sindx(indx)).specpopup;
          str = popupstr(hui);
          if ~isempty(str), set(hui, 'String', str); end
        end
        set(convert2vector(h.controls(sindx)), ...
          'HorizontalAlignment', 'Left', ...
          'Style', 'text', ...
          'BackgroundColor', get(0, 'DefaultUicontrolBackgroundColor'));
      end
      for indx = 1:length(eindx)
        lindx = eindx(indx);
        set(h.controls(lindx).edit, 'Style', 'edit');
        vv = get(hPrm(lindx), 'ValidValues');
        if iscell(vv)
          vv = getTranslatedStringcell('signal:sigtools:sigdatatypes',vv);
          if strcmpi(get(h.controls(lindx).specpopup, 'Style'), 'text')
            indx = find(strcmpi(vv, get(h.controls(lindx).specpopup, 'String')));
          else
            indx = get(h.controls(lindx).specpopup, 'Value');
          end
          set(h.controls(lindx).specpopup, ...
            'Style', 'popup', ...
            'String', vv, ...
            'Value', indx);
        end
      end
      
      eindx = setdiff(1:length(h.controls), dindx);
      
      if ~isempty(dindx)
        setenableprop(convert2vector(h.controls(dindx)), 'Off');
      end
      if ~isempty(eindx)
        setenableprop(convert2vector(h.controls(eindx)), this.Enable);
      end
      
      for indx = 1:length(hPrm)
        vv = get(hPrm(indx), 'ValidValues');
        if iscell(vv) & length(vv) == 1
          setenableprop(convert2vector(h.controls(indx)), 'Off');
        end
      end
      
    end
    
    function usermodified_eventcb(hDlg, eventData)
      %USERMODIFIED_EVENTCB Callback to the 'UserModified' event of the PARAMETER
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      set(hDlg, 'isApplied', 0);
      
    end
    
  end  %% public methods
  
end  % classdef



% ------------------------------------------------------------------
function value = getvalue(this, indx)

hPrm = get(this, 'Parameters');

if isrendered(this)
  h    = get(this, 'Handles');
  
  if isempty(hPrm)
    value = [];
    return;
  end
  
  % If validvalues for the parameter is a cell, then the info must be in
  % a popup
  vv = hPrm(indx).ValidValues;
  if isnumeric(vv)
    value = evaluatevars(get(h.controls(indx).edit,'String'));
  elseif iscell(vv)
    value = get(h.controls(indx).specpopup, 'Value');
  elseif ischar(vv) & strcmpi(vv, 'on/off')
    if get(h.controls(indx).checkbox, 'Value')
      value = 'on';
    else
      value = 'off';
    end
  else
    value = get(h.controls(indx).edit, 'String');
    if ~isvalid(hPrm(indx), value)
      value = evaluatevars(value);
    end
  end
else
  value = get(hPrm(indx), 'Value');
end

end


% -------------------------------------------------------
function fix_figure(hPD)

hFig = get(hPD, 'FigureHandle');
sz = parameter_gui_sizes(hPD);

pos = get(hFig, 'Position');
pos(3:4) = sz.fig(3:4);
set(hFig, 'Position', pos);

end


% ----------------------------------------------------------------
function render_parameters(this)

hPrm = get(this, 'Parameters');
sz   = parameter_gui_sizes(this);
hFig = get(this, 'FigureHandle');
h    = get(this, 'Handles');

if ~isempty(hPrm)
  
  pos = [2*sz.hfus sz.frame(2)+2*sz.uuvs+sz.bh sz.fig(3)-4*sz.hfus sz.uh];
  
  % Render the parameters with autoupdate off.
  h.controls = render(hPrm, hFig, pos, 0);
  
  listen = handle.listener(hPrm, 'UserModified', @(s,e)usermodified_eventcb(this,e));
  set(this, 'UserModifiedListener', listen);
  
  setenableprop([h.controls.edit h.controls.specpopup], this.Enable);
  set([h.controls.label], 'Enable', this.Enable);
  
  set(this, 'isApplied', 1);
  
  set(this, 'Handles', h);
  
  % Call the listener to sync the enable states.
  dialog_enable_listener(this,[]);
else
  h.controls   = [];
  h.noparamtxt = uicontrol(hFig, ...
    'Position', sz.frame - [-sz.hfus -sz.vfus 2*sz.hfus 3.5*sz.vfus], ...
    'String', getString(message('signal:sigtools:siggui:ThereAreCurrentlyNoParametersToSet')), ...
    'Style', 'Text');
  set(this, 'Handles', h);
  
  set(convert2vector(rmfield(this.DialogHandles, 'cancel')), 'Enable', 'Off');
end

% Install Listeners
install_listeners(this);

end

% -------------------------------------------------------------------
function render_frame(this)

sz   = parameter_gui_sizes(this);
hFig = get(this, 'FigureHandle');

h = get(this, 'Handles');

lbl = this.Label;

if isempty(lbl), lbl = ' '; end

h.frame = framewlabel(hFig, sz.frame, lbl, ...
  'parameterdialog_frame', get(0,'DefaultUicontrolBackgroundColor'));

if isempty(this.Label), set(h.frame(2), 'Visible', 'Off'); end

set(this, 'Handles', h);

end

% ----------------------------------------------------------------
function install_listeners(this)

oldlisten = this.WhenRenderedListeners;

% If there are any listeners, then there is no reason to create new ones.
if ~isempty(oldlisten)
  return;
end

listen = [ ...
  event.proplistener(this, this.findprop('Name'), 'PostSet', @(s,e)name_listener(this)); ...
  event.proplistener(this, this.findprop('Label'),'PostSet', @(s,e)label_listener(this)); ...
  event.proplistener(this, this.findprop('Parameters'),'PostSet', @(s,e)parameters_listener(this)); ...
  event.proplistener(this, this.findprop('DisabledParameters'), 'PostSet', @(s,e)update_uis(this));
  event.proplistener(this, this.findprop('StaticParameters'), 'PostSet', @(s,e)update_uis(this)); ...
  ];

this.WhenRenderedListeners = listen;

end


% -------------------------------------------------------------------
function render_buttons(this)

if isempty(this.Parameters), return; end

sz   = parameter_gui_sizes(this);
hFig = get(this, 'FigureHandle');
cbs  = siggui_cbs(this);

h = get(this, 'Handles');

pos = [sz.frame(1)+sz.hfus sz.frame(2)+sz.uuvs sz.makedefault sz.bh];
h.makedefault = uicontrol(hFig, ...
  'Style', 'Pushbutton', ...
  'Position', pos, ...
  'Callback', {cbs.method, this, 'makedefault'}, ...
  'String', getString(message('signal:sigtools:siggui:SaveAsDefault')), ...
  'Visible', 'On');

pos = [pos(1)+pos(3)+sz.uuhs pos(2) sz.restore sz.bh];
h.restoredefault = uicontrol(hFig, ...
  'Style', 'Pushbutton', ...
  'Position', pos, ...
  'Callback', {@lclRestoreOriginalValues, this}, ...
  'String', getString(message('signal:sigtools:siggui:RestoreOriginalDefaults')), ...
  'Visible', 'On');

set(this, 'Handles', h);

end


% -------------------------------------------------------------------
function lclRestoreOriginalValues(hcbo, eventStruct, this)

hPrm = get(this, 'Parameters');

restore(hPrm);

end



% ------------------------------------------------------------------
function lclsetvalue(this, indx, value)

hPrm = get(this, 'Parameters');

if isrendered(this)
  h    = get(this, 'Handles');
  
  if isempty(hPrm)
    value = [];
    return;
  end
  
  % If validvalues for the parameter is a cell, then the info must be in
  % a popup
  vv = hPrm(indx).ValidValues;
  if isnumeric(vv)
    set(h.controls(indx).edit, 'String', value);
  elseif iscell(vv)
    if isnumeric(value)
      set(h.controls(indx).specpopup, 'Value', value);
    else
      set(h.controls(indx).specpopup, 'Value', find(strcmpi(vv, value)));
    end
  elseif ischar(vv) & strcmpi(vv, 'on/off')
    if strcmpi(value, 'off')
      set(h.controls(indx).checkbox, 'Value', 0);
    else
      set(h.controls(indx).checkbox, 'Value', 1);
    end
  else
    set(h.controls(indx).edit, 'String', value);
  end
else
  return;
end

end

