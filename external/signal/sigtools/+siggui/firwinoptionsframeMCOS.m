classdef firwinoptionsframeMCOS < siggui.sigcontainerMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.firwinoptionsframe class
  %   siggui.firwinoptionsframe extends siggui.sigcontainer.
  %
  %    siggui.firwinoptionsframe properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Scale - Property is of type 'on/off'
  %       Window - Property is of type 'SignalSpectrumWindowList enumeration: {'Bartlett','Bartlett-Hanning','Blackman','Blackman-Harris','Bohman','Chebyshev','Flat Top','Gaussian','Hamming','Hann','Kaiser','Nuttall','Parzen','Rectangular','Taylor','Triangular','Tukey','User Defined'}'
  %       Parameter - Property is of type 'string'
  %       Parameter2 - Property is of type 'string'
  %       isMinOrder - Property is of type 'bool'
  %
  %    siggui.firwinoptionsframe methods:
  %       getParamNames - Get the paramNames.
  %       get_window -   PreGet function for the 'window' property.
  %       isminordersupported -   Returns true if minimum order is supported.
  %       set_window -   PreSet function for the 'window' property.
  %       setorder - Set the length of the filter
  %       setstate - Set the state of the object
  %       thisrender - Render the FIR Options window frame for FDATool.
  %       updateparameter -   Update the Parameter controls.
  %       view - Launch WVTool
  %       visible_listener - Overload the siggui method to link the visible state of WVTool
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %SCALE Property is of type 'on/off'
    Scale = 'on';
    %WINDOW Property is of type 'SignalSpectrumWindowList enumeration: {'Bartlett','Bartlett-Hanning','Blackman','Blackman-Harris','Bohman','Chebyshev','Flat Top','Gaussian','Hamming','Hann','Kaiser','Nuttall','Parzen','Rectangular','Taylor','Triangular','Tukey','User Defined'}'
    Window = 'Bartlett';
    %PARAMETER Property is of type 'string'
    Parameter = '';
    %PARAMETER2 Property is of type 'string'
    Parameter2 = '';
    %ISMINORDER Property is of type 'bool'
    isMinOrder = 0;
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %PRIVWINDOW Property is of type 'mxArray' (hidden)
    privWindow = [];
    %PARAMETERCACHE Property is of type 'mxArray' (hidden)
    ParameterCache = [];
  end
  
  
  events
    OrderRequested
  end  % events
  
  methods  % constructor block
    function this = firwinoptionsframeMCOS(winobj)
      %FIRWINOPTIONSFRAME Constructor for the firwinoptionsframe class
      
      %   Author(s): V.Pellissier
      
      if nargin < 1
        winobj = sigwin.kaiser;
      end
      
      this.privWindow = winobj;
      this.Version = 3;
      
      settag(this);
      
      
    end  % firwinoptionsframe
    
    function set.Scale(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Scale')
      obj.Scale = value;
    end
    
    function value = get.Window(obj)
      value = get_window(obj,obj.Window);
    end
    function set.Window(obj,value)
      % Enumerated DataType = 'SignalSpectrumWindowList enumeration: {'Bartlett','Bartlett-Hanning','Blackman','Blackman-Harris','Bohman','Chebyshev','Flat Top','Gaussian','Hamming','Hann','Kaiser','Nuttall','Parzen','Rectangular','Taylor','Triangular','Tukey','User Defined'}'
      value = validatestring(value,{'Bartlett','Bartlett-Hanning','Blackman','Blackman-Harris','Bohman','Chebyshev','Flat Top','Gaussian','Hamming','Hann','Kaiser','Nuttall','Parzen','Rectangular','Taylor','Triangular','Tukey','User Defined'},'','Window');
      obj.Window = set_window(obj,value);
    end
    
    function value = get.Parameter(obj)
      value = get_parameter(obj,obj.Parameter);
    end
    function set.Parameter(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Parameter')
      obj.Parameter = set_parameter(obj,value);
    end
    
    function value = get.Parameter2(obj)
      value = get_parameter2(obj,obj.Parameter2);
    end
    function set.Parameter2(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Parameter2')
      obj.Parameter2 = set_parameter2(obj,value);
    end
    
    function set.privWindow(obj,value)
      obj.privWindow = value;
    end
    
    function set.isMinOrder(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical'}, {'scalar'},'','isMinOrder')
      obj.isMinOrder = value;
    end
    
    function set.ParameterCache(obj,value)
      obj.ParameterCache = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    
    function values = getAllowedStringValues(~,prop)
      % This function gives the the valid string values for object properties.
      
      switch prop
        case 'Window'
          values = {...
            'Bartlett'
            'Bartlett-Hanning'
            'Blackman'
            'Blackman-Harris'
            'Bohman'
            'Chebyshev'
            'Flat Top'
            'Gaussian'
            'Hamming'
            'Hann'
            'Kaiser'
            'Nuttall'
            'Parzen'
            'Rectangular'
            'Taylor'
            'Triangular'
            'Tukey'
            'User Defined'
            'User Defined'};
        otherwise
          values = {};
      end
      
    end

    
    function paramNames = getParamNames(this)
      %GETPARAMNAMES Get the paramNames.
      
    
      if isa(this.privWindow, 'sigwin.functiondefined')
        paramNames = {'FunctionName', 'Parameter'};
      else
        paramNames = getparamnames(this.privWindow);
      end
      
      if ~iscell(paramNames)
        paramNames = {paramNames ''};
      elseif length(paramNames) == 1
        paramNames = {paramNames{1} ''};
      end
      
    end
    
    
    function window = get_window(this, window)
      %GET_WINDOW   PreGet function for the 'window' property.
      
      window = get(this.privWindow, 'Name');
      
    end
    
    function b = isminordersupported(this)
      %ISMINORDERSUPPORTED   Returns true if minimum order is supported.
      
      b = isminordersupported(this.privWindow);
      
    end
    
    function window = set_window(this, window)
      %SET_WINDOW   PreSet function for the 'window' property.
      
      this.privWindow = getwinobject(window);
      
    end
    
    function setorder(h, orderStr)
      %SETORDER Set the length of the filter
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      try
        order = evaluatevars(orderStr);
        set(h.privWindow, 'Length', order);
      catch %#ok<CTCH>
        str = getString(message('signal:siggui:firwinoptionsframe:setorder:InvalidVar'));
        warning(h, str);  % warning is a method of h not the function
      end
      
    end
    
    function setstate(this, s)
      %SETSTATE Set the state of the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      narginchk(2,2);
      
      switch s.Version
        case 1
          s.Parameter = s.ParamCell;
          s = rmfield(s, 'ParamCell');
          this.privWindow = feval(['sigwin.' s.Window]);
          s = rmfield(s, 'Window');
        case 2
          if strcmpi(s.Window, 'user defined')
            s.Parameter2 = s.Parameter;
            s.Parameter  = s.FunctionName;
          end
          s = rmfield(s, 'FunctionName');
        case 3
          % Currently defined properties match this case.  There is no
          % transformation needed, we can set the structure into the object.
      end
      
      siggui_setstate(this, s);
      
    end
    
    function thisrender(this, varargin)
      %THISRENDER Render the FIR Options window frame for FDATool.
      
      %   Author(s): V.Pellissier & Z. Mecklai
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      pos = parserenderinputs(this, varargin{:});
      if nargin < 2
        hFig = gcf;
      end
      
      if isempty(pos)
        % Get the gui sizes
        sz = gui_sizes(this);
        pos = sz.pixf.*[217, 55, 178, 133-(sz.vffs/sz.pixf)];
      end
      
      framewlabel(this, pos, getString(message('signal:sigtools:siggui:Options')));
      renderactionbtn(this, pos-[0 2*sz.pixf 0 0], getString(message('signal:sigtools:siggui:View')), 'view');
      
      %reduce the buttom height
      H = get(this,'Handles');
      P = get(H.view, 'Position');
      set(H.view, 'Position', P);
      
      rendercontrols(this, pos + [0 sz.uh+2*sz.pixf 0 -sz.uh], ...
        {'Scale', 'Window', 'Parameter', 'Parameter2'});
      
      % Reposition Window Label - avoid overlap
      H = get(this,'Handles');
      posWinLbl = get(H.window_lbl,'Position');
      winWidth = largestuiwidth({getTranslatedString('signal:siggui:renderedlabel','Window')});
      posWinLbl(3) = winWidth + sz.lfs;
      set(H.window_lbl,'Position',posWinLbl);
      
      %Set pop-up menu position explicitly
      posWinPop = get(H.window,'Position');
      startPos = posWinLbl(1)+posWinLbl(3);
      set(H.window,'Position',[startPos+0.5*sz.popwTweak, posWinPop(2), pos(1)+pos(3)-startPos-sz.popwTweak, posWinPop(4)])
      
      % Add context-sensitive help
      cshelpcontextmenu(this, 'fdatool_firwin_options_frame');
      
      l = [ this.WhenRenderedListeners; ...
        event.proplistener(this, this.findprop('privWindow'),'PostSet', @(h, ev) updateparameter(this)); ...
        event.proplistener(this, this.findprop('isMinOrder'),'PostSet', @(h, ev) updateparameter(this)); ...
        ];
      
      this.WhenRenderedListeners = l;
      
    end
    
    function updateparameter(this)
      %UPDATEPARAMETER   Update the Parameter controls.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2009 The MathWorks, Inc.
      
      h = get(this, 'Handles');
      
      p = getParamNames(this);
      
      visState = 'off';
      
      if ~isempty(p{1}) && ~(isminordersupported(this) && this.isMinOrder)
        % Can't just look at MinOrder because of the other factors.
        visState = this.Visible;
      end
      
      set([h.parameter h.parameter_lbl], 'Visible', visState);
      set(h.parameter_lbl, ...
        'Tag', [p{1} '_lbl'], ...
        'String', sprintf('%s: ', getTranslatedString('signal:sigtools:siggui',interspace(p{1}))));
      
      set(h.parameter, ...
        'Tag', p{1}, ...
        'String', get(this, 'Parameter'));
      
      if isempty(p{2})
        visState = 'Off';
      else
        visState = this.Visible;
      end
      set([h.parameter2 h.parameter2_lbl], 'Visible', visState);
      set(h.parameter2_lbl, ...
        'Tag',    [p{2} '_lbl'], ...
        'String', sprintf('%s: ', getTranslatedString('signal:sigtools:siggui',interspace(p{2}))));
      
      set(h.parameter2, ...
        'Tag',    p{2}, ...
        'String', get(this, 'Parameter2'));
      
    end
        
    function view(this)
      %VIEW Launch WVTool
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      % sync the gui values
      hwin = get(this, 'privWindow');
      
      if isa(hwin, 'sigwin.functiondefined')
        set(hwin, 'MATLABExpression', this.FunctionName, ...
          'Parameters', evaluatevars(this.Parameter));
      else
        p = getparamnames(hwin);
        if ~isempty(p)
          if ~iscell(p)
            set(hwin, p, evaluatevars(this.Parameter));
          else
            set(hwin, p{1}, evaluatevars(this.Parameter));
            set(hwin, p{2}, evaluatevars(this.Parameter2));
          end
        end
      end
      
      % Test is there's a valid window object
      try
        data = generate(hwin);
      catch
        error(message('signal:siggui:firwinoptionsframe:view:InvalidParam'));
      end
      
      notify(this, 'OrderRequested');
      
      hV = getcomponent(this, '-class', 'sigtools.wvtool');
      if isempty(hV)
        % Instantiate the Viewer
        hV = sigtools.wvtool;
        render(hV);
        
        % Install a listener to the WVToolClosing event
        listener = addlistener(hV, 'WVToolClosing', @(s,e)updatebtnstring(this));
        setappdata(this.Handles.view, 'Listener', listener);
        
        % Create a mean to setup the link mode (Add/Replace)
        createlinkmode(hV);
        
        addcomponent(this, hV);
      end
      
      % Add or Replace window in the viewer
      hFig = get(hV, 'FigureHandle');
      AddReplaceMode = getappdata(hFig, 'AddReplaceMode');
      addwin(hV, {hwin}, [], AddReplaceMode);
      
      % Turn visibility on
      set(hV, 'Visible', 'on');
      
      hndls = get(this, 'Handles');
      set(hndls.view, 'String', getString(message('signal:sigtools:siggui:Update')));
      
    end
    
    
    function visible_listener(this, eventData)
      %VISIBLE_LISTENER Overload the siggui method to link the visible state of WVTool
      
      %   Author(s): V. Pellissier
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      visState = get(this, 'Visible');
      
      set(this, 'Visible', visState);
      
      if strcmpi(visState, 'Off')
        set(allchild(this), 'Visible', 'Off');
      end
      
      updateparameter(this);
      
      
    end
    
  end  %% public methods
  
  methods
    function varargout = set(obj,varargin)
      [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});
    end
    
  end
  
end  % classdef

function parameter = set_parameter(this, parameter)

% Get the parameter name
paramName = getParamNames(this);
paramName = paramName{1};

% Set the parameter into the cache
if ~isempty(paramName)
  this.ParameterCache.(paramName) = parameter;
end
end  % set_parameter


% -------------------------------------------------------------------------
function parameter = get_parameter(this, parameter)

% Get the parameter name
paramName = getParamNames(this);
paramName = paramName{1};

% Get the parameter from the cache
if ~isempty(paramName)
  parameter = getParameterFromCache(this, paramName);
end
end  % get_parameter


% -------------------------------------------------------------------------
function parameter = set_parameter2(this, parameter)

% Get the parameter name
paramName = getParamNames(this);
paramName = paramName{2};

% Set the parameter into the cache
if ~isempty(paramName)
  this.ParameterCache.(paramName) = parameter;
end
end  % set_parameter2


% -------------------------------------------------------------------------
function parameter = get_parameter2(this, parameter)

% Get the parameter name
paramName = getParamNames(this);
paramName = paramName{2};

if ~isempty(paramName)
  
  % Get the parameter from the cache
  parameter = getParameterFromCache(this, paramName);
end
end  % get_parameter2


% -------------------------------------------------------------------------
function parameter = getParameterFromCache(this, paramName)

if isfield(this.ParameterCache, paramName)
  parameter = this.ParameterCache.(paramName);
elseif isprop(this.privWindow, paramName)
  parameter = mat2str(this.privWindow.(paramName));
else
  parameter = '';
end
end  % getParameterFromCache


%-------------------------------------------------------------------------
function createlinkmode(hV)

hFig = get(hV, 'FigureHandle');

% Add a menu
hndl = addmenu(hFig,[1 3],'FDAToolLink','','fdatoollink','On','');
strs  = {getString(message('signal:sigtools:siggui:ReplaceCurrentWindow')),getString(message('signal:sigtools:siggui:AddNewWindow'))};
cbs   = {{@replace_cb, hV},{@add_cb, hV}};
tags  = {'replace','add'};
sep   = {'Off','Off'};
accel = {'J','K'};
hndl  = addmenu(hFig,[1 3 1],strs,cbs,tags,sep,accel);

% Default: Replace
set(hndl(1), 'Checked', 'on');

% Save the handles
setappdata(hndl(1), 'ExclusiveMenu', hndl(2));
setappdata(hndl(2), 'ExclusiveMenu', hndl(1));
setappdata(hFig, 'ReplaceMenuHandle', hndl(1));
setappdata(hFig, 'AddMenuHandle', hndl(2));

% Find the toolbar of the Viewer and add a button.
load(fullfile(matlabroot,'toolbox','signal', 'sigtools', 'private', 'fatoolicons.mat'));
hFig = get(hV, 'FigureHandle');
htoolbar = findobj(hFig, 'type', 'uitoolbar');
link = [];
link.hbutton = uitoggletool('Parent', htoolbar, ...
  'ClickedCallback', {@addreplace_cb, hV}, ...
  'State', 'On', 'TooltipString', getString(message('signal:sigtools:siggui:SetLinkmodeadd')), ...
  'Separator','On', 'CData', icons.add, ...
  'Tag' , 'AddReplace');
setappdata(hFig, 'AddReplaceToggleHandle', link.hbutton);

setappdata(hFig, 'AddReplaceMode', 'Replace');

end


%-------------------------------------------------------------------------
function addreplace_cb(hcbo, eventStruct, hV)
% Callback of the toggle button

load(fullfile(matlabroot,'toolbox','signal', 'sigtools', 'private', 'fatoolicons.mat'));

hFig = get(hV, 'FigureHandle');
state = get(hcbo, 'State');

if strcmpi(state, 'on')
  setlinktoreplace(hFig);
else
  setlinktoadd(hFig);
end

end

%-------------------------------------------------------------------------
function replace_cb(hcbo, eventStruct, hV)
% Callback of the Replace menu

hFig = get(hV, 'FigureHandle');
state = get(hcbo, 'Checked');

if strcmpi(state, 'off')
  setlinktoreplace(hFig);
end

end

%-------------------------------------------------------------------------
function add_cb(hcbo, eventStruct, hV)
% Callback of the Add menu

hFig = get(hV, 'FigureHandle');
state = get(hcbo, 'Checked');

if strcmpi(state, 'off')
  setlinktoadd(hFig);
end

end


%-------------------------------------------------------------------------
function setlinktoreplace(hFig)

load(fullfile(matlabroot,'toolbox','signal', 'sigtools', 'private', 'fatoolicons.mat'));

% Update toggle
set(getappdata(hFig, 'AddReplaceToggleHandle'), 'TooltipString', getString(message('signal:sigtools:siggui:SetLinkmodeadd')), ...
  'CData', icons.replace, 'State', 'on');

% Update menus
set(getappdata(hFig, 'ReplaceMenuHandle'), 'Checked', 'on');
set(getappdata(hFig, 'AddMenuHandle'), 'Checked', 'off');

% Update Applicationdata
setappdata(hFig, 'AddReplaceMode', 'Replace');

end


%-------------------------------------------------------------------------
function setlinktoadd(hFig)

load(fullfile(matlabroot,'toolbox','signal', 'sigtools', 'private', 'fatoolicons.mat'));

% Update toggle
set(getappdata(hFig, 'AddReplaceToggleHandle'), 'TooltipString', getString(message('signal:sigtools:siggui:SetLinkmodereplace')), ...
  'CData', icons.add, 'State', 'off');

% Update menus
set(getappdata(hFig, 'ReplaceMenuHandle'), 'Checked', 'off');
set(getappdata(hFig, 'AddMenuHandle'), 'Checked', 'on');

% Update Applicationdata
setappdata(hFig, 'AddReplaceMode', 'Add');

end


%-------------------------------------------------------------------------
function updatebtnstring(this, eventStruct)

set(this.Handles.view, 'String', getString(message('signal:sigtools:siggui:View')));

end

% [EOF]
