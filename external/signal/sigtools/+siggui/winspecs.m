classdef winspecs < siggui.sigguiMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.winspecs class
  %   siggui.winspecs extends siggui.siggui.
  %
  %    siggui.winspecs properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Window - Property is of type 'sigwin.window'
  %       Name - Property is of type 'string'
  %       MATLABExpression - Property is of type 'string'
  %       Length - Property is of type 'string'
  %       SamplingFlag - Property is of type 'signalSignalwindowsExtendedWindowSampling_flag enumeration: {'none','symmetric','periodic'}'
  %       Data - Property is of type 'mxArray'
  %
  %    siggui.winspecs methods:
  %       apply - Update the GUI and send an event
  %       enable_listener - Overload the siggui superclass's enable listener
  %       getparameter -   Get the parameter.
  %       getstate -   Get the state.
  %       newcurrentwin_eventcb - NEWCURRETWIN_EVENTCB
  %       select_currentwin - Send an NewCurrentwinIndex
  %       set_selectednames - Set the selected names in the combo box
  %       setstate - Sets the state of a winspecs object
  %       thisrender - Render the window specifications component.
  %       userfcn_listener - Listener to the MATLAB_expression property
  
  properties (SetObservable, GetObservable)
    %WINDOW Property is of type 'sigwin.window'  
    Window = [];
  end
    
  properties (AbortSet, SetObservable, GetObservable)
    %NAME Property is of type 'string'
    Name = 'window_';
    %MATLABEXPRESSION Property is of type 'string'
    MATLABExpression = '';
    %LENGTH Property is of type 'string'
    Length = '64';
    %SAMPLINGFLAG Property is of type 'signalSignalwindowsExtendedWindowSampling_flag enumeration: {'none','symmetric','periodic'}'
    SamplingFlag = 'none';
    %DATA Property is of type 'mxArray'
    Data = [];
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %ISMODIFIED Property is of type 'bool' (hidden)
    isModified
    %PARAMETERS Property is of type 'mxArray' (hidden)
    Parameters = [];
  end
  
  
  events
    NewState
    NewCurrentwinIndex
  end  % events
  
  methods  % constructor block
    function this = winspecs
      %WINSPECS Constructor for the winspecs object.
      
      
      % Set up the default
      this.Window = sigwin.hamming;
      this.SamplingFlag = 'symmetric';
      this.isModified = 0;
      this.Version = 1;
      
      
    end  % winspecs
    
   
    function set.Window(obj,value)
      % DataType = 'sigwin.window'
      validateattributes(value,{'sigwin.window'}, {'scalar'},'','Window')
      obj.Window = set_window(obj,value);
    end
    
    function set.Name(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Name')
      obj.Name = set_name(obj,value);
    end
    
    function set.MATLABExpression(obj,value)
      % DataType = 'string'
      if ~isempty(value)
        validateattributes(value,{'char'}, {'row'},'','MATLABExpression')
        obj.MATLABExpression = set_prop(obj,value);
      end
    end
    
    function set.Length(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Length')
      obj.Length = set_prop(obj,value);
    end
    
    function set.SamplingFlag(obj,value)
      % Enumerated DataType = 'signalSignalwindowsExtendedWindowSampling_flag enumeration: {'none','symmetric','periodic'}'
      value = validatestring(value,{'none','symmetric','periodic'},'','SamplingFlag');
      obj.SamplingFlag = set_prop(obj,value);
    end
    
    function set.Data(obj,value)
      obj.Data = value;
    end
    
    function set.isModified(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'double'}, {'scalar'},'','isModified')
      obj.isModified = value;
    end
    
    function set.Parameters(obj,value)
      obj.Parameters = set_prop(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    
    function apply(this)
      %APPLY Update the GUI and send an event
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      % If the Apply button is disabled or the GUI not rendered
      isModified = this.isModified;
      if ~isModified
        return;
      end
      
      new_length = evaluatevars(this.Length);
      
      %Check that length is positive
      if new_length < 1
        error(message('signal:siggui:winspecs:apply:WinLenMustPositive'))
      end
      
      window = this.Window;
      
      if isa(window, 'sigwin.variablelength')
        set(window, 'Length', new_length);
      end
      
      p = getparameter(this);
      
      if ~isempty(p)
        set(window, p{1}, evaluatevars(this.Parameters.(p{1})));
        if ~isempty(p{2})
          set(window, p{2}, evaluatevars(this.Parameters.(p{2})));
        end
        data = generate(window);
      elseif isa(window, 'sigwin.samplingflagwin')
        set(window, 'SamplingFlag', this.SamplingFlag);
        data = generate(window);
      elseif isa(window, 'sigwin.userdefined')
        str = get(this.Handles.matlabexpression, 'String');
        set(this, 'MATLABExpression', str);
       
        if isempty(str)
          error(message('signal:siggui:winspecs:apply:GUIErr'));
        end
        
        % Error checking
        data = evalin('base', str);
        if ~isnumeric(data)
          error(message('signal:siggui:winspecs:apply:MustBeNumeric'));
        else
          [M,N] = size(data);
          if M==1
            data = data(:);
          end
          if size(data,2)~=1
            error(message('signal:siggui:winspecs:apply:InvalidDimensions'));
          end
        end
        
        % Instantiate a new window object
        window.MATLAB_expression = str;
        data = generate(window);
        
        % Set the Length property
        this.Length = sprintf('%d', length(data));
      else
        data = generate(window);
      end
      
      % Set the 'Data' property
      this.Data = data(:);
      
      % Send an event
      newstate = getstate(this);
      hEventData = sigdatatypes.sigeventdataMCOS(this, 'NewState', newstate);
      notify(this, 'NewState', hEventData);      
    end
    
    function enable_listener(this, varargin)
      %ENABLE_LISTENER Overload the siggui superclass's enable listener
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      enabState = get(this, 'Enable');
      
      if strcmpi(enabState, 'Off')
        siggui_enable_listener(this, varargin{:})
      else
        
        window = this.Window;
        
        h = get(this, 'Handles');
        
        setenableprop([h.winname_lbl h.winname h.type_lbl h.type], 'On');
        
        if isa(window, 'sigwin.userdefined')
          enab = 'On';
        else
          enab = 'Off';
        end
        
        setenableprop([h.matlabexpression h.matlabexpression_lbl], enab);
        
        if isa(window, 'sigwin.variablelength')
          style = 'edit';
        else
          style = 'text';
        end
        
        set(h.length, 'Style', style);
        setenableprop([h.length_lbl h.length], 'On');
        
        lbl = getparameter(this);
        if isempty(lbl)
          lbl  = {'Parameter' 'Parameter2'};
          str  = {'' ''};
          enab = {'Off' 'Off'};
        else
          paramstruct = get(this, 'Parameters');
          str  = {paramstruct.(lbl{1}) ''};
          enab = {'On' 'Off'};
          if ~isempty(lbl{2})
            str{2}  = paramstruct.(lbl{2});
            enab{2} = 'On';
          else
            lbl{2}='Parameter2';
          end
        end
        
        set(h.parameter_lbl, 'String', sprintf('%s:', getTranslatedString('signal:sigtools:siggui',lbl{1})));
        set(h.parameter,     'String', str{1});
        setenableprop([h.parameter_lbl h.parameter], enab{1});
        set(h.parameter2_lbl, 'String', sprintf('%s:', getTranslatedString('signal:sigtools:siggui',lbl{2})));
        set(h.parameter2,     'String', str{2});
        setenableprop([h.parameter2_lbl h.parameter2], enab{2});
        
        if isa(window, 'sigwin.samplingflagwin')
          enab = 'On';
        else
          enab = 'Off';
        end
        
        setenableprop([h.samplingflag h.samplingflag_lbl], enab);
        
        [classnames, winnames] = findallwinclasses;
        winnames(end) = [];
        ClassName = regexp(class(window),'\.','split');
        ClassName = ClassName{end};
        indx = find(strcmpi(ClassName, classnames));
        set(h.type, 'Value', indx);
      end
      
    end
    
    function param = getparameter(this)
      %GETPARAMETER   Get the parameter.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      window = this.Window;
      
      if isa(window, 'sigwin.parameterizewin')
        p = getparamnames(window);
        if ~iscell(p)
          param{1}=p;
          param{2}='';
        else
          param = p;
        end
      else
        param = '';
      end
      
    end
    
    function state = getstate(this)
      %GETSTATE   Get the state.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      state = get(this);
      
      state.Parameters = get(this, 'Parameters');
      
    end
    
    
    function newcurrentwin_eventcb(hSpecs, eventData)
      %NEWCURRETWIN_EVENTCB
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      % Callback executed by the listener to an event thrown by another component.
      % The Data property stores a handle of a winspecs object
      currentwin = eventData.Data;
      
      % Set the state of winSpecs object
      if ~isempty(currentwin)
        state = getstate(currentwin);
        setstate(hSpecs, state);
        hSpecs.isModified = 0;
      end
      
    end
    
    function select_currentwin(hSpecs, val)
      %SELECT_CURRENTWIN Send an NewCurrentwinIndex
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Send an event
      hEventData = sigdatatypes.sigeventdataMCOS(hSpecs, 'NewCurrentwinIndex', val);
      notify(hSpecs, 'NewCurrentwinIndex', hEventData);
      
    end
    
    function set_selectednames(this, winnames, index)
      %SET_SELECTEDNAMES Set the selected names in the combo box
      %   Set the 'String' property of the combo with the cell array
      %   stored in WINNAMES. The window editable in the combo is defined
      %   by INDEX.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      if ~isrendered(this)
        return
      end
      
      h = get(this, 'Handles');
      
      % Update the combo box
      if isempty(winnames{1})
        % Disable the component
        set(this, 'Enable', 'off');
        set(h.winname, 'String', {''}, 'Max', 0, 'Value', 1);
      else
        % Enable the component
        set(this, 'Enable', 'on');
        set(h.winname, 'Value', index, 'String', winnames, 'Max', 1);
      end
      
    end
    
    function setstate(this, state)
      %SETSTATE Sets the state of a winspecs object
      %   This function is required because of the 'Window' property :
      %   we need to copy the window object (and not just copy the handle).
      
      %   Author(s): V. Pellissier
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      narginchk(1,2);
      
      if isrendered(this)
        l = get(this, 'WhenRenderedListeners');
        l = findobj(l,'Source',{findprop(this,'isModified')});
      else
        l = [];
      end
      
      l.Enabled = 0;
      
      if isempty(state)
        this.Window = [];
        this.MATLABExpression = '';
        this.Name = '';
        this.Data = [];
        this.Parameters = [];
      else
        
        % Keep that order
        this.Parameters = state.Parameters;
        
        if ~isempty(state.Window)
          % Copy of the window object is needed to have two different objects
          this.Window = copyobj(state.Window);
        end
        % Keep that order
        this.MATLABExpression = state.MATLABExpression;
        this.Name = state.Name;
        this.Data = state.Data;
        this.Length = state.Length;
        this.SamplingFlag = state.SamplingFlag;
        
      end
      
      l.Enabled = true;
      
      this.isModified = 0;
      
    end
    
    function thisrender(this, hFig, pos)
      %THISRENDER Render the window specifications component.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      sz = gui_sizes(this);
      if nargin < 3
        pos  = [10 10 232 212]*sz.pixf;
        if nargin < 2
          hFig = gcf;
        end
      end
      
      hPanel = uipanel('Parent', hFig, ...
        'Units', 'Pixels', ...
        'Position', pos, ...
        'Visible', 'Off', ...
        'Title', getString(message('signal:sigtools:siggui:CurrentWindowInformation')));
      
      lbls = {getString(message('signal:sigtools:siggui:Name')), ...
        getString(message('signal:sigtools:siggui:Type')), ...
        getString(message('signal:sigtools:siggui:MATLABCode')), ...
        getString(message('signal:sigtools:siggui:Length1')), ...
        [getString(message('signal:sigtools:siggui:Parameter')) ':'], ...
        [getString(message('signal:sigtools:siggui:Parameter2')) ':'], ...
        getString(message('signal:sigtools:siggui:Sampling'))};
      
      style = {'', ...
        'popupmenu', ...
        'edit', ...
        'edit', ...
        'edit', ...
        'edit', ...
        'popupmenu'};
      
      tags = {'winname', ...
        'type', ...
        'matlabexpression', ...
        'length', ...
        'parameter', ...
        'parameter2', ...
        'samplingflag'};
      
      [winclassnames, winnames] = findallwinclasses;
      
      % Remove the functiondefined class
      index = strcmpi('functiondefined', winclassnames);
      winnames(index) = [];
      
      param = getparameter(this);
      if isempty(param)
        strs = {{this.Name}, ...
          winnames, ...
          this.MATLABExpression, ...
          this.Length, ...
          param, ...
          param, ...
          {getString(message('signal:sigtools:siggui:Symmetric')), ...
          getString(message('signal:sigtools:siggui:Periodic'))}};
      else
        strs = {{this.Name}, ...
          winnames, ...
          this.MATLABExpression, ...
          this.Length, ...
          param{1}, ...
          param{2}, ...
          {getString(message('signal:sigtools:siggui:Symmetric')), ...
          getString(message('signal:sigtools:siggui:Periodic'))}};
      end
      
      cb = siggui_cbs(this);
      cbs = {{cb.method, this, @select_cb}, ...
        {cb.method, this, @type_cb}, ...
        {cb.method, this, @userdef_cb}, ...
        {cb.property, this, 'Length', ''}, ...
        {cb.method, this, @parameter_cb}, ...
        {cb.method, this, @parameter_cb}, ...
        {cb.property, this, 'SamplingFlag', ''}};
      
      % Position relative to the UIPanel, not the figure.
      lblpos = [sz.hfus pos(4)-40*sz.pixf 100*sz.pixf sz.uh-sz.lblTweak];
      x      = lblpos(1)+lblpos(3)+sz.uuhs;
      ctlpos = [x lblpos(2) pos(3)-x-sz.uuhs sz.uh];
      
      % Render the combo box
      h.winname = sigcombobox(hPanel, ...
        'Callback', cbs{1}, ...
        'String', strs{1}, ...
        'Position', ctlpos, ...
        'tag', 'combopop');
      
      % hLayout = siglayout.gridbaglayout(hPanel);
      %
      % set(hLayout, ...
      %     'VerticalGap', 5, ...
      %     'HorizontalGap', 5, ...
      %     'HorizontalWeights', [0 1]);
      %
      % hLayout.add(h.winname, 1, 2, ...
      %     'Fill', 'Horizontal', ...
      %     'TopInset', 10*sz.pixf, ...
      %     'MinimumHeight', sz.uh);
      
      nlbls = length(lbls);
      
      skip = (lblpos(2)-40*sz.pixf-(nlbls-1)*sz.uh)/(nlbls-1);
      
      % Render labels from top to bottom
      for n=1:nlbls
        
        h.([tags{n} '_lbl']) = uicontrol(hPanel, ...
          'Style', 'text',...
          'HorizontalAlignment', 'left', ...
          'String', lbls{n},...
          'Position', lblpos, ...
          'Tag', [tags{n} '_lbl']);
        
        %     hLayout.add(h.([tags{n} '_lbl']), n, 1, ...
        %         'MinimumHeight', sz.uh-sz.lblTweak, ...
        %         'MinimumWidth',  90*sz.pixf, ...
        %         'Anchor', 'Southwest', ...
        %         'Fill', 'Horizontal');
        
        if n > 1
          % Create the uicontrol
          h.(tags{n}) = uicontrol(hPanel, ...
            'Style', style{n}, ...
            'Callback', cbs{n}, ...
            'HorizontalAlignment', 'left', ...
            'String', getTranslatedStringcell('signal:sigtools',strs{n}), ...
            'Position', ctlpos, ...
            'Tag', tags{n});
          
          if strcmp(tags{n},'samplingflag')
            setappdata(h.samplingflag, 'PopupStrings',...
              {'Symmetric', 'Periodic'});
          end
          %         hLayout.add(h.(tags{n}), n, 2, ...
          %             'MinimumHeight', sz.uh, ...
          %             'Fill', 'Horizontal');
        end
        
        ctlpos(2) = ctlpos(2)-sz.uh-skip;
        lblpos(2) = ctlpos(2);
      end
      
      set(h.type, 'BackgroundColor', 'w');
      
      ctlpos = get(h.length, 'Position');
      ctlpos = ctlpos+[60 0 -60 0]*sz.pixf;
      set(h.length, 'Position', ctlpos);
      
      ctlpos = get(h.parameter, 'Position');
      ctlpos = ctlpos+[60 0 -60 0]*sz.pixf;
      set(h.parameter, 'Position', ctlpos);
      
      ctlpos = get(h.parameter2, 'Position');
      ctlpos = ctlpos+[60 0 -60 0]*sz.pixf;
      set(h.parameter2, 'Position', ctlpos);
      
      ch1 = findobj(hFig,'tag','parameter_lbl');
      ch2 = findobj(hFig,'tag','parameter2_lbl');
      
      if ~isempty(ishandle(ch1)) && ~isempty(ishandle(ch2))
        tempPos1 = get(ch1,'Position');
        tempPos2 = get(ch2,'Position');
        set(ch1,'Position',[tempPos1(1:2), tempPos1(3)+30*sz.pixf,tempPos1(4)]);
        set(ch2,'Position',[tempPos2(1:2), tempPos2(3)+30*sz.pixf,tempPos2(4)]);
      end
      
      % hLayout.setconstraints(4, 2, 'LeftInset', 60*sz.pixf);
      % hLayout.setconstraints(5, 2, 'LeftInset', 60*sz.pixf);
      
      w = 70*sz.pixf;
      
      h.pb = uicontrol(hPanel, ...
        'Style', 'pushbutton', ...
        'Callback', {cb.method, this, 'apply'}, ...
        'String', getString(message('signal:sigtools:siggui:Apply')), ...
        'Position', [(pos(3)-w)/2 10*sz.pixf w sz.bh], ...
        'Tag', 'apply');
      
      % hLayout.add(h.pb, 7, 1:2, ...
      %     'MinimumWidth', largestuiwidth(h.pb)+20*sz.pixf, ...
      %     'MinimumHeight', sz.bh);
      
      % Store handles in object
      set(this,'Handles', h, ...
        'FigureHandle', hFig, ...
        'Container', hPanel); %, ...
      %     'Layout', hLayout);
      
      % Create the listeners
      listener = [ ...
        event.proplistener(this, this.findprop('Name'), ...
        'PostSet', @(s,e)name_listener(this,e)); ...
        event.proplistener(this, this.findprop('Window'), ...
        'PostSet', @(s,e)window_listener(this,e)); ...
        event.proplistener(this, [this.findprop('MATLABExpression'), ...
        this.findprop('Length') this.findprop('SamplingFlag')], ...
        'PostSet', @(s,e)lclprop_listener(this,e)); ...
        event.proplistener(this, this.findprop('isModified'), ...
        'PostSet', @(s,e)lclismodified_listener(this,e));...   
        event.proplistener(h.winname, h.winname.findprop('String'), ...
        'PostSet', @(hSrc,ev) lclname_listener(this, ev, h.winname))];               
      
      % Set this to be the input argument to these listeners
      set(this, 'WhenRenderedListeners', listener);
      
      % Add context-sensitive help
      cshelpcontextmenu(this, 'wintool_winspecs_frame', 'WinTool');
      
      window_listener(this);
      
    end
    
    function userfcn_listener(hSpecs, eventData)
      %USERFCN_LISTENER Listener to the MATLAB_expression property
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      % This can be a private method
      
      str = get(hSpecs, 'MATLAB_expression');
      
      if ~isempty(str)
        
        try
          % Error checking
          data = evalin('base', str);
          if ~isnumeric(data)
            senderror(hSpecs, getString(message('signal:sigtools:siggui:Numericarrayexpected')));
            return
          else
            [M,N] = size(data);
            if M==1
              data = data(:);
            end
            if size(data,2)~=1
              senderror(hSpecs, getString(message('signal:sigtools:siggui:Vectorexpected')) );
              return
            end
          end
        catch ME
          senderror(hSpecs, ME.identifier, ME.message);
          return
        end
        
        % Instantiate a new window object
        newwin = sigwin.userdefined;
        newwin.MATLAB_expression = str;
        data = generate(newwin);
        
        % Set the 'Window' property
        hSpecs.Window = newwin;
        
        % Set the Length property
        hSpecs.Length = length(data);
        
        % Set the 'Data' property
        hSpecs.Data = data(:);
        
      end
      
      % Update the User-Defined uicontrol
      hndls = get(hSpecs,'Handles');
      if isfield(hndls, 'controls')
        huserdef = findobj(hndls.controls, 'Tag', 'userdef');
        set(huserdef, 'String', str);
      end
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function newselection_eventcb1(this, eventData)
      %NEWSELECTION_EVENTCB
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      % Callback executed by the listener to an event thrown by another component.
      % The Data property stores a vector of handles of winspecs objects
      s = eventData.Data;
      selectedwin = s.selectedwindows;
      
      % Get the names of the selected windows
      winnames = get(selectedwin, 'Name');
      if ~iscell(winnames)
        winnames = {winnames};
      end
      
      % Set the names of selected windows in the combobox
      index = [];
      if ~isempty(s.currentindex)
        index = find(s.currentindex == s.selection);
      end
      
      if isrendered(this)
        l = findobj(this.WhenRenderedListeners, 'Source', {findprop(this, 'isModified')});
      else
        l = [];
      end
      l.Enabled = 0;
      
      set_selectednames(this, winnames, index);
      selectedwin = selectedwin(index);
      if ~isempty(selectedwin)
        setstate(this, getstate(selectedwin));
      end
      
      l.Enabled = 1;
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function window = set_window(this, window)

if isempty(window)
  return;
end

if isa(window, 'sigwin.parameterizewin')
  param = getparamnames(window);
  
  paramstruct = get(this, 'Parameters');
  
  if ~iscell(param)
    if ~isfield(paramstruct, param)
      paramstruct.(param) = sprintf('%g', window.(param));
    end
  else
    for i=1:length(param)
      if ~isfield(paramstruct, param{i})
        paramstruct.(param{i}) = sprintf('%g', window.(param{i}));
      end
    end
  end
  set(this, 'Parameters', paramstruct);
end

% Set up flag
this.isModified = 1;
end  % set_window


% ------------------------------------------------------------------------
function len = set_prop(this, len)

this.isModified = 1;
end  % set_prop


% ------------------------------------------------------------------------
function name = set_name(this, name)

% Set up flag
this.isModified = 1;

if ~isvarname(name) || isreserved(name, 'm')
  error(message('signal:siggui:winspecs:schema:InternalError', name));
end
end  % set_name


%-------------------------------------------------------------------------
%         CALLBACKS
%-------------------------------------------------------------------------
function select_cb(this)
%SELECT_CB Callback of the popup of the combobox

val = get(this.Handles.winname, 'Value');
select_currentwin(this, val);

end

%-------------------------------------------------------------------------
function type_cb(this)
%TYPE_CB Callback of the Type popup

% Find the function handle of the window in the database
[winclassnames, winnames] = findallwinclasses;
% Remove the functiondefined class
index = strcmpi('functiondefined', winclassnames);
winclassnames(index) = [];

ind = get(this.Handles.type, 'Value');

% Instantiate a new window object
newwin = feval(str2func(['sigwin.',winclassnames{ind}]));

% Set the Window property
this.Window = newwin;

end

%-------------------------------------------------------------------------
function userdef_cb(this)
%USERDEF_CB Callback of the User Defined editbox

str = get(this.Handles.matlabexpression, 'String');
set(this, 'MATLABExpression', str);

end


%-------------------------------------------------------------------------
function parameter_cb(this)
%PARAMETER_CB Callback of the parameter editbox

strs{1} = get(this.Handles.parameter, 'String');
strs{2} = get(this.Handles.parameter2, 'String');
paramstruct = get(this, 'Parameters');
param=getparameter(this);

paramstruct.(param{1}) = strs{1};
if ~isempty(param{2})
  paramstruct.(param{2}) = strs{2};
end

set(this, 'Parameters', paramstruct);

end

%-------------------------------------------------------------------------
%         LISTENERS
%-------------------------------------------------------------------------
function lclismodified_listener(this, ~)

if this.isModified
  enab = this.Enable;
else
  enab = 'Off';
end

set(this.Handles.pb, 'Enable', enab);

end

%-------------------------------------------------------------------------
function lclprop_listener(this, eventData)

prop_listener(this, eventData);

end

%-------------------------------------------------------------------------
function window_listener(this, ~)

enable_listener(this);

end

%-------------------------------------------------------------------------
function name_listener(this, ~)

newname = get(this, 'Name');

% Update the editbox of the combobox
h   = get(this,'Handles');
val = get(h.winname, 'Value');
str = cellstr(get(h.winname, 'String'));
if ~isempty(str)
  str{val} = newname;
end

% Update the backgroundcolor
setenableprop(h.winname, this.Enable);

end

%-------------------------------------------------------------------------
function lclname_listener(this, ~, hcbo)
%NAME_CBS Callback of the editbox of the combobox

allstr = get(hcbo, 'String');
if length(allstr) == 1 && isempty(allstr{1})
    return;
end
name = popupstr(hcbo);
if isvarname(name) && ~isreserved(name, 'm')
  set(this, 'Name', name);
else
    senderror(this, ['''' name ''' ' getString(message('signal:sigtools:siggui:IsNotAValidName'))]);
    
    nameIdx = strcmp(allstr,name);
    allstr{nameIdx} = get(this,'Name');
    set(hcbo, 'String', allstr);
end

end
% [EOF]
