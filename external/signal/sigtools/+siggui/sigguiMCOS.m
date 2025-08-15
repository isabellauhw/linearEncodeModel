classdef (Abstract) sigguiMCOS < dynamicprops & matlab.mixin.SetGet & matlab.mixin.Copyable & matlab.mixin.internal.TreeNode & matlab.mixin.Heterogeneous
  %siggui.siggui class
  %    siggui.siggui properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %
  %    siggui.siggui methods:
  %       cshelpcontextmenu - ADDCSH Add context sensitive help to the frame
  %       deletewarndlgs - Delete warning dialogs
  %       destroy - Delete the SIGGUI object
  %       disp - Display the siggui object.
  %       enable_listener - The listener for the enable property.
  %       enablelink_listener -   Listener to link enable states.
  %       error - Error mechanism
  %       figure_listener - Listener for the deletion of the figure
  %       figuresize - Return the figure size.
  %       framewlabel -   Create a framewlabel.
  %       getcshtags -   Returns the Tags and the Toolname for the CSH.
  %       getpixelpos - Get the position in pixel units.
  %       getstate - Get the state of the object
  %       gettooltips -   Returns the tooltips for the object
  %       gui_sizes - GUI_SPACING Returns a structure of spacings and generic sizes
  %       handles2vector - Convert the handles structure to a vector
  %       inputProcessingSelector - Render input processing selector popup
  %       ishandlefield - Returns true if the field is a handle
  %       isrendered - Returns true if the render method has been called
  %       parserenderinputs - Parse for the inputs to render
  %       prop_listener - Calls the property listener
  %       render - Render the object
  %       renderactionbtn -   Render the gui's action button
  %       renderactionbtn2 -   Render the gui's action button
  %       rendercontrols -   Render the properties.
  %       rendercontrols2 - RENDERCONTROLS   Render the properties.
  %       resizefcn -  Layout the uis if figure is different from default
  %       senderror - Send an error from the object
  %       sendfiledirty - Send the File Dirty notification
  %       sendstatus - Send a status from the object
  %       sendwarning - Send a warning from the object
  %       setPopupStrings - Set the PopupStrings
  %       setpixelpos - Set a handle's position in pixels.
  %       setstate - Set the state of the object
  %       settag - Set up the base elements of the object
  %       setunits - Sets all units in the frame
  %       setupenablelink -   Setup an enable link between properties
  %       siggui_cbs - Generic Callbacks for SIGGUI objects
  %       siggui_cshelpcontextmenu - ADDCSH Add context sensitive help to the frame
  %       siggui_enable_listener -   The listener for the enable property.
  %       siggui_error - ERROR Error mechanism
  %       siggui_getstate - Get the state of the object
  %       siggui_prop_listener - Listener to the public properties of the Filter Wizard
  %       siggui_resizefcn -  Layout the uis if figure is different from default
  %       siggui_setstate - Set the state of the object
  %       siggui_setunits - Sets all units in the frame
  %       siggui_visible_listener - The listener for the visible property
  %       siggui_warning - WARNING Display a warndlg
  %       thisrender - Pass control to the subclass when rendering
  %       thisunrender - Allow the subclass to take control
  %       unrender - Unrender the siggui object
  %       visible_listener - The listener for the visible property
  %       warning - SIGGUI's warning mechanism
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %TAG Property is of type 'string'
    Tag = '';
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %LINKDATABASE Property is of type 'mxArray'
    LinkDatabase = [];
    %CSHMENU Property is of type 'mxArray'
    CSHMenu
  end
  
  properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
    %VERSION Property is of type 'double' (read only)
    Version = 1.0;
  end  
  
  events
    sigguiRendering
    sigguiClosing
    Notification
    UserModifiedSpecs
  end  % events
  
  methods
    
    function value = get.Tag(obj)
      % value = get_tag(obj,obj.Tag);
      value = class(obj);
    end
    function set.Tag(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Tag')
      obj.Tag = value;
    end
    
    function set.Version(obj,value)
      % DataType = 'double'
      validateattributes(value,{'double'}, {'scalar'},'','Version')
      obj.Version = value;
    end
    
    function set.LinkDatabase(obj,value)
      obj.LinkDatabase = value;
    end
    
    function set.CSHMenu(obj,value)
      obj.CSHMenu = value;
    end
    
    function cshelpcontextmenu(hObj, varargin)
      %ADDCSH Add context sensitive help to the frame
      
      % Author(s): J. Schickler
      % Copyright 1988-2017 The MathWorks, Inc.
      
      siggui_cshelpcontextmenu(hObj, varargin{:});
      
    end
    
    function deletewarndlgs(hObj)
      %DELETEWARNDLGS Delete warning dialogs
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      h = get(hObj, 'Handles');
      
      if isfield(h, 'warn') && ~isempty(h.warn)
        hwarn = h.warn(ishghandle(h.warn));
        delete(hwarn);
        h.warn = [];
        set(hObj, 'Handles', h);
      end
      
    end
    
    function destroy(h)
      %DESTROY Delete the SIGGUI object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      if isrendered(h)
        unrender(h);
      end
      
      delete(h);
      clear h
      
    end
    
    function disp(hObj)
      %DISP Display the siggui object.
      
      % Copyright 1988-2003 The MathWorks, Inc.
      
      if length(hObj) > 1
        for indx = 1:length(hObj)
          disp(class(hObj(indx)));
        end
        fprintf(1, '\n');
      else
        disp(get(hObj))
      end
      
      
    end
    
    function enable_listener(hObj, varargin)
      %ENABLE_LISTENER The listener for the enable property.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      % WARNING: This is the superclass listener which will perform a "blind"
      % enable or disable.  If you want to only disable/enable certain UIControls
      % you must overload this method.  It is recommended that you always disable
      % all UIcontrols when the object is disabled.
      
      siggui_enable_listener(hObj, varargin{:});
      
    end
    
    function enablelink_listener(this, eventData, enabvalue, varargin)
      %ENABLELINK_LISTENER   Listener to link enable states.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      if ischar(eventData), prop = eventData;
      else,                 prop = get(eventData.Source, 'Name'); end
      
      value = get(this, prop);
      if ~iscell(enabvalue), enabvalue = {enabvalue}; end
      
      enab = 'Off';
      indx = 1;
      while strcmpi(enab, 'off') && length(enabvalue) >= indx
        if ischar(value) && strcmpi(value, enabvalue{indx}) || isequal(value, enabvalue{indx})
          enab = this.Enable;
        end
        indx = indx + 1;
      end
      
      if strcmpi(varargin{end}, '-update')
        update = true;
        varargin(end) = [];
      else
        update = false;
      end
      
      % Gather the handles to disable.
      if ischar(varargin{1})
        h = get(this, 'Handles');
        henab = [];
        for indx = 1:length(varargin)
          henab = [henab; h.(varargin{indx})];
          if isfield(h, [varargin{indx} '_lbl'])
            henab = [henab; h.([varargin{indx} '_lbl'])];
          end
        end
        setenableprop(henab(:), enab, false);
      elseif isa(varargin{1}, 'siggui.sigguiMCOS')
        set([varargin{:}], 'Enable', enab);
      else
        error(message('signal:siggui:siggui:enablelink_listener:invalidLink'));
      end
      
      if update
        for indx = 1:length(varargin)
          prop_listener(this, varargin{indx});
        end
      end
      
    end
    
    
    function error(hObj, varargin)
      %ERROR Error mechanism
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      siggui_error(hObj, varargin{:});
      
    end
    
    function figure_listener(h, eventData)
      %FIGURE_LISTENER Listener for the deletion of the figure
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      if isa(h, 'siggui.sigguiMCOS')
        unrender(h);
      end
      
    end
    
    function size = figuresize(hBase, units)
      %FIGURESIZE Return the figure size.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      narginchk(1,2);
      
      if nargin == 1, units = 'pixels'; end
      
      hFig = get(hBase, 'FigureHandle');
      
      if ~ishghandle(hFig)
        error(message('signal:siggui:siggui:figuresize:InvalidParam'));
      end
      
      origUnits = get(hFig,'Units');
      set(hFig,'Units',units);
      pos = get(hFig,'Position');
      set(hFig,'Units',origUnits);
      
      size = pos(3:4);
      
    end
    
    
    function framewlabel(this, pos, lbl)
      %FRAMEWLABEL   Create a framewlabel.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      narginchk(2,3);
      
      if nargin < 3
        lbl = get(classhandle(this), 'Description');
        lbl = getTranslatedString('signal:sigtools:siggui',lbl);
      end
      
      h = get(this, 'Handles');
      
      hnew = framewlabel(this.FigureHandle, pos, lbl, ...
        [strrep(class(this), '.', '_'), '_framewlabel'], ...
        get(0, 'DefaultUicontrolBackgroundColor'), 'Off');
      
      if isfield(h, 'framewlabel')
        h.framewlabel = [h.framewlabel hnew];
      else
        h.framewlabel = hnew;
      end
      
      [cshtags, cshtool] = getcshtags(this);
      if isfield(cshtags, 'framewlabel')
        cshelpcontextmenu(hnew, cshtags.framewlabel, cshtool);
      end
      
      set(this, 'Handles', h);
      
    end
    
    function [cshtags, cshtool] = getcshtags(this)
      %GETCSHTAGS   Returns the Tags and the Toolname for the CSH.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      cshtags = [];
      cshtool = '';
      
    end
    
    function pos = getpixelpos(this, field, varargin)
      %GETPIXELPOS Get the position in pixel units.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      narginchk(2,inf);
      
      if ischar(field)
        field = this.Handles.(field);
        for indx = 1:length(varargin)
          if ischar(varargin{indx})
            field = field.(varargin{indx});
          else
            field = field(varargin{indx});
          end
        end
      end
      
      pos = getpixelposition(field);
      
    end
    
    function s = getstate(h)
      %GETSTATE Get the state of the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      s = siggui_getstate(h);
      
    end
    
    
    function tooltips = gettooltips(this)
      %GETTOOLTIPS   Returns the tooltips for the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      tooltips = [];
      
    end
    
    
    function sz = gui_sizes(hSuper)
      %GUI_SPACING Returns a structure of spacings and generic sizes
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      pf = get(0,'ScreenPixelsPerInch')/96;
      if isunix
        pf = 1;
      end
      sz.pixf = pf;
      
      % Spacing
      sz.vfus = 5*pf;     % vertical space between frame and uicontrol
      sz.hfus = 10*pf;    % horizontal space between frame and uicontrol
      sz.ffs  = 5*pf;     % frame/figure spacing and horizontal frame/frame spacing
      sz.vffs = 15*pf;    % vertical space between frame and frame
      sz.lfs  = 10*pf;    % label/frame spacing
      sz.uuvs = 10*pf;    % uicontrol/uicontrol vertical spacing
      sz.uuhs = 10*pf;    % uicontrol/uicontrol horizontal spacing
      
      % Sizes
      sz.ebw  = 90*pf;    % edit box width
      sz.bh   = 20*pf;    % pushbutton heightsz.bw   = 165; % button width
      sz.tw   = 100*pf;   % text width
      
      % Unix needs a bigger fontsize
      if ispc
        sz.fontsize = 8;
        lang = get(0, 'Language');
        if strncmpi(lang, 'ja', 2)
          sz.fontsize = sz.fontsize+2;
        end
      else
        sz.fontsize = 10;
      end
      
      sz.lh = (sz.fontsize+10)*pf;  % label height
      sz.uh = sz.lh;
      
      % Tweak factors
      sz.lblTweak = 3*pf; % text ui tweak to vertically align popup labels
      sz.popwTweak = 22*pf;  % Extra width for popup
      sz.rbwTweak  = 22*pf;  % Extra width for radio button
      
      % New default Font Name/Size Standards for Graphics and UI objects
      sz.fontnamegraphics = get(0,'DefaultTextFontName');
      sz.fontsizegraphics = get(0,'DefaultTextFontSize');
      sz.fontnameui = get(0,'DefaultUiControlFontName');
      sz.fontsizeui = get(0,'DefaultUIControlFontSize');
      
    end
    
    
    function h = handles2vector(this)
      %HANDLES2VECTOR Convert the handles structure to a vector
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      h = get(this,'Handles');
      
      % The "controllers" are now uipanels.
      if isfield(h, 'java')
        if isfield(h.java, 'controller')
          h.controller = h.java.controller;
        end
        h = rmfield(h, 'java');
      end
      
      h = convert2vector(h);
      
      % Remove the non-handles.
      h(~ishghandle(h)) = [];
      
    end
    
    function [label, selectedinputprocessing, offset] = inputProcessingSelector(this,pos,varargin)
      %INPUTPROCESSINGSELECTOR Render input processing selector popup
      
      %   Copyright 2011 The MathWorks, Inc.
      
      bgc   = get(0,'DefaultUicontrolBackgroundColor');
      sz    = gui_sizes(this);

      specsX = {siggui.message(...
        'signal:siggui:siggui:inputProcessingSelector:ColumnsAsChannels'), ...
        siggui.message(...
        'signal:siggui:siggui:inputProcessingSelector:ElementsAsChannels')};
      
      specs = {'Columns as channels (frame based)',...
        'Elements as channels (sample based)'};

      hFig  = get(this,'FigureHandle');
      
      labelStr = siggui.message(...
        'signal:siggui:siggui:inputProcessingSelector:InputProcLabel');
      
      lblWidth =  largestuiwidth({labelStr},'text');
      lblPos = [pos(1) pos(2)+(2*sz.pixf) lblWidth sz.uh];
      
      sigguiType = class(this);
      idx = strfind(sigguiType,'.')+1;
      
      % Render the Input Processing label
      label = uicontrol(hFig,...
        'Style','text',...
        'HorizontalAlignment', 'Center', ...
        'BackgroundColor',bgc,...
        'Position', lblPos,...
        'String',labelStr,...
        'Visible','Off',...
        'Tag',[sigguiType(idx:end) '_inputproc_lbl']);
      
      popUpWidth  = largestuiwidth(specs,'popup');
      fsPopPos = [pos(1)+lblWidth+sz.uuhs+50 pos(2) popUpWidth sz.uh+(7*sz.pixf)];
      
      % Render the Input Processing popupmenu
      selectedinputprocessing = uicontrol(hFig,...
        'Style','Popup',...
        'BackgroundColor','White',...
        'HorizontalAlignment', 'Left', ...
        'Position', fsPopPos,...
        'Visible','Off',...
        'String', specsX,...
        'Tag',[sigguiType(idx:end) '_inputproc_popup'], ...
        'Callback',{@selectedinputprocessing_cb, this, specs});
      
      offset = lblWidth+sz.uuhs + popUpWidth;
      
      cshelpcontextmenu(label, 'fdatool_inputprocessing\signal', 'fdatool');
      cshelpcontextmenu(selectedinputprocessing, 'fdatool_inputprocessing\signal', 'fdatool');
      
    end
    
    
    function flag = iscalledbydspblks(this)
      %ISCALLEDBYDSPBLKS
      
      %   Copyright 2011 The MathWorks, Inc.
      
      try
        prt = get(this.Parent, 'UserData');
        flag = prt.flags.calledby.dspblks > 0 ;
      catch %#ok<CTCH>
        flag = false;
      end
      
    end
    
    function b = ishandlefield(hObj, field)
      %ISHANDLEFIELD Returns true if the field is a handle
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      h = get(hObj, 'Handles');
      
      if isfield(h, field)
        h = convert2vector(h.(field));
        
        if all(ishghandle(h))
          b = true;
        else
          b = false;
        end
      else
        b = false;
      end
      
    end
    
    function boolflag = isrendered(h)
      %ISRENDERED Returns true if the render method has been called
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      boolflag = ~isempty(findprop(h,'RenderedPropHandles'));
      
    end
    
    
    function pos = parserenderinputs(this, varargin)
      %PARSERENDERINPUTS Parse for the inputs to render
      %   PARSERENDERINPUTS Parse for the inputs to render (hFig, position)
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      hFig = -1;
      pos = [];
      
      for i = 1:length(varargin)
        if numel(varargin{i}) == 1 && ...
            (ishghandle(varargin{i}, 'figure') || ...
            ishghandle(varargin{i}, 'uipanel') || ...
            ishghandle(varargin{i}, 'uicontainer'))
          hFig = varargin{i};
        elseif isnumeric(varargin{i}) && length(varargin{i}) == 4
          pos = varargin{i};
        end
      end
      
      if ~ishghandle(hFig)
        if ishghandle(this.Parent, 'figure') || ...
            ishghandle(this.Parent, 'uipanel') || ...
            ishghandle(this.Parent, 'uicontainer')
          hFig = this.Parent;
        else
          hFig = gcf;
        end
      end
      
      set(this, 'Parent', hFig);
      
    end
    
    function prop_listener(hObj, varargin)
      %PROP_LISTENER Calls the property listener
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      siggui_prop_listener(hObj, varargin{:});
      
    end
    
    
    function varargout = render(this, varargin)
      %RENDER Render the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      if ~isrendered(this)
        
        sz = gui_sizes(this);
        origFontSize = get(0, 'DefaultUicontrolFontSize');
        set(0, 'DefaultUicontrolFontSize', sz.fontsize');
        
        % Add the rendered properties
        add_properties(this);
        
        % Install listeners to these properties
        install_listeners(this);
        
        try
          % Allow subclasses to do whatever rendering they need.
          if nargout
            [varargout{1:nargout}] = thisrender(this, varargin{:});
          else
            thisrender(this, varargin{:});
          end
        catch ME
          unrender(this);
          throwAsCaller(ME);
        end
        
        % Send the sigguiRendering event
        notify(this, 'sigguiRendering', event.EventData);
        
        install_figurelistener(this);
        if isempty(this.Container)
          setunits(this, 'normalized');
        end
        set(0, 'DefaultUicontrolFontSize', origFontSize);
        
      end
      
    end
    
    
    function renderactionbtn(this, pos, str, method, varargin)
      %RENDERACTIONBTN   Render the gui's action button
      %   RENDERACTIONBTN(THIS, POS, STR, METHOD) Render the GUI's action
      %   button to the center of POS with the label STR.  It will call the
      %   method METHOD (string or function handle) via the method_cb of
      %   SIGGUI_CBS.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      narginchk(4,5);
      
      sz  = gui_sizes(this);
      cbs = siggui_cbs(this);
      str = getTranslatedString('signal:sigtools:siggui',str);
      width = largestuiwidth({str}) + 20*sz.pixf;
      
      if ischar(method), field = lower(method);
      else,              field = lower(func2str(method)); end
      
      ClassName = regexp(class(this),'\.','split');
      ClassName = ClassName{end};
      
      tag = [ClassName '_' field];
      
      h = get(this, 'Handles');
      
      h.(field) = uicontrol(this.FigureHandle, ...
        'String',str , ...
        'Style', 'PushButton', ...
        'HorizontalAlignment', 'Center', ...
        'Tag', tag, ...
        'Visible', 'Off', ...
        'Position', [pos(1)+(pos(3)-width)/2 pos(2)+sz.vfus width sz.bh], ...
        'Callback', {cbs.method, this, method, varargin{:}});
      
      set(this, 'Handles', h);
      
      [cshtags, cshtool] = getcshtags(this);
      if isfield(cshtags, field)
        cshelpcontextmenu(h.(field), cshtags.(field), cshtool);
      end
      
    end
    
    
    function renderactionbtn2(this, row, col, str, method, varargin)
      %RENDERACTIONBTN2   Render the gui's action button
      %   RENDERACTIONBTN2(THIS, POS, STR, METHOD) Render the GUI's action
      %   button to the center of POS with the label STR.  It will call the
      %   method METHOD (string or function handle) via the method_cb of
      %   SIGGUI_CBS.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      narginchk(4,5);
      
      sz  = gui_sizes(this);
      cbs = siggui_cbs(this);
      
      if ischar(method), field = lower(method);
      else,              field = lower(func2str(method)); end
      
      tag = [get(classhandle(this), 'Name') '_' field];
      
      hPanel  = get(this, 'Container');
      hLayout = get(this, 'Layout');
      if isempty(hLayout)
        hLayout = siglayout.gridbaglayout(hPanel);
        set(this, 'Layout', hLayout);
      end
      
      h = get(this, 'Handles');
      
      h.(field) = uicontrol(hPanel, ...
        'String', getTranslatedString('sigtools/@siggui/@siggui/renderactionbtn2',str) , ...
        'Style', 'PushButton', ...
        'HorizontalAlignment', 'Center', ...
        'Tag', tag, ...
        'Callback', {cbs.method, this, method, varargin{:}});
      
      set(this, 'Handles', h);
      
      hLayout.add(h.(field), row, col, ...
        'MinimumHeight', sz.uh, ...
        'minimumwidth', largestuiwidth(h.(field))+20*sz.pixf);
      
      [cshtags, cshtool] = getcshtags(this);
      if isfield(cshtags, field)
        cshelpcontextmenu(h.(field), cshtags.(field), cshtool);
      end
      
    end
    
    
    function rendercontrols(this, pos, varargin)
      %RENDERCONTROLS   Render the properties.
      %   RENDERCONTROLS(THIS, POS) Render all the public set and get properties,
      %   using the 'Description' from the label and determining the UIControl
      %   style from the datatype of the property.  A listener will be created on
      %   all the properties' 'PropertyPostSet' event and will call the
      %   PROP_LISTENER method.  This listener will be saved in the
      %   WhenRenderedListeners property.  The handle to each of the UIControl's
      %   will be stored in the Handles property in a field of the same name as
      %   the property, but in all lower case.  If a label is needed it will be
      %   stored in '([propname '_lbl'])' and its string will be set to the
      %   Description.
      %
      %   RENDERCONTROLS(THIS, POS, PROPS) Render only the properties passed in
      %   the cell of strings PROPS.
      %
      %   RENDERCONTROLS(THIS, POS, PROPS, DESCS) Use the cell of strings DESCS to
      %   label the controls instead of their descriptions.
      %
      %   RENDERCONTROLS(THIS, POS, PROPS, DESCS, STYLES) Use the cell of strings
      %   STYLES instead of mapping the properties' DataTypes to UIControl
      %   styles.
      %
      %   DataType to UIControl Map
      %   On/Off          checkbox
      %   bool
      %   string          editbox
      %   all others      popup
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2011 The MathWorks, Inc.
      
      narginchk(2,5);
      
      hp = [];
      visState = 'Off';
      if length(pos) == 1 && ishghandle(pos)
        if ishghandle(pos, 'uipanel') || ishghandle(pos, 'uicontainer')
          ispanel = true;
          visState = 'On';
        end
        if ishghandle(pos, 'figure') || ispanel
          hp = pos;
          pos = [];
          if ~isempty(varargin)
            if length(varargin{1}) == 4 && isnumeric(varargin{1})
              pos = varargin{1};
              varargin(1) = [];
            end
          end
          if isempty(pos)
            pos = getpixelposition(hp);
            pos(1:2) = 0;
          end
        end
      end
      
      tagsUpper = varargin{:};
      [props, tags, strs, styles] = parseinputs(this, varargin{:});
      
      cbs  = siggui_cbs(this);
      
      if isempty(hp)
        hp   = get(this, 'Container');
        if isempty(hp)
          hp = get(this, 'Parent');
        end
      end
      sz   = gui_sizes(this);
      h    = get(this, 'Handles');
      
      skip  = (pos(4)-length(tags)*sz.uh)/(length(tags)+1)+sz.uh;
      
      lblwidth = zeros(1, numel(strs));
      for indx = 1:numel(strs)
        if ~strcmpi(styles{indx}, 'checkbox') && ~isempty(strs{indx})
          strs{indx} = sprintf('%s: ', getTranslatedString('signal:siggui:renderedlabel',strs{indx}));
          lblwidth(indx) = largestuiwidth(strs(indx));
        end
      end
      lblwidth = max(lblwidth);
      
      % Get total position.
      pos = [pos(1)+sz.hfus pos(2)-sz.uh pos(3)-sz.hfus*2 sz.uh];
      
      % Get the label position
      lblpos = pos;
      lblpos(3) = lblwidth;
      lblpos(2) = lblpos(2)-sz.lblTweak;
      
      % Get the edit/popup position
      editpos = pos;
      editpos(1) = editpos(1) + lblwidth + sz.uuhs/2;
      editpos(3) = pos(3) - lblwidth - sz.uuhs/2;
      
      minwidth = 20*sz.pixf;
      if editpos(3) < minwidth
        lblpos(3)  = lblpos(3)-minwidth+editpos(3);
        editpos(1) = editpos(1)-minwidth+editpos(3);
        editpos(3) = minwidth;
      end
      
      tooltips = gettooltips(this);
      [cshtags, cshtool] = getcshtags(this);
      
      % Render the controls
      for indx = length(tags):-1:1
        pos(2)     = pos(2) + skip;
        editpos(2) = editpos(2) + skip;
        lblpos(2)  = lblpos(2) + skip;
        ispop = false;
        switch styles{indx}
          case 'checkbox'
            cpos = pos;
            strs{indx} = getTranslatedString('signal:siggui:renderedlabel',strs{indx});
            cpos(3) = largestuiwidth(strs(indx))+sz.rbwTweak;
            inputs = {'Position', cpos, 'String', strs{indx}};
          case {'edit', 'popup'}
            inputs = {'Position', editpos};
            if iscell(props(indx)) && all(cellfun(@ischar,this.(props(indx).Name)))
              inputs = [inputs, {'Max', 2}]; %#ok<AGROW>
            end
            if strcmpi(styles{indx}, 'popup')
              ispop = true;
              validStrings = set(this, tagsUpper{indx});
              if ~isempty(validStrings)
                for m = 1:length(validStrings)
                  validStringsT{m} = ...
                    getTranslatedString('signal:siggui:renderedlabel',validStrings{m});
                end
              end
              inputs = [inputs, {'String', validStringsT}]; %#ok<AGROW>
            end
            if ~isempty(strs{indx})
              tag = [tags{indx} '_lbl'];
              if isfield(tooltips, tag)
                lblinputs = {'TooltipString', tooltips.(tag)};
              else
                lblinputs = {};
              end
              
              h.(tag) = uicontrol(hp, ...
                'Style', 'Text', ...
                'Visible', visState, ...
                'HorizontalAlignment', 'Left', ...
                'Tag', tag, ...
                'String', strs{indx}, ...
                lblinputs{:}, ...
                'Position', lblpos);
              if isfield(cshtags, tags{indx})
                cshelpcontextmenu(h.(tag), cshtags.(tags{indx}), cshtool);
              end
            end
        end
        if isfield(tooltips, tags{indx})
          inputs = [inputs {'TooltipString', tooltips.(tags{indx})}]; %#ok<AGROW>
        end
        h.(tags{indx}) = uicontrol(hp, ...
          'Style', styles{indx}, ...
          'Visible', visState, ...
          'HorizontalAlignment', 'Left', ...
          'Tag', tags{indx}, ...
          inputs{:}, ...
          'Callback', {cbs.property, this, props(indx).Name, sprintf('Change %s', strs{indx})});
        if ispop
          setappdata(h.(tags{indx}), 'PopupStrings', validStrings);
        end
        if isfield(cshtags, tags{indx})
          cshelpcontextmenu(h.(tags{indx}), cshtags.(tags{indx}), cshtool);
        end
      end
      
      set(this, 'Handles', h);
      
      % Make sure everything is enabled properly.
      h = handles2vector(this);
      h(~isprop(h, 'Enable')) = [];
      setenableprop(h, this.Enable);
      
      % Add the listener to capture the property changes.
      l = event.proplistener(this, props, 'PostSet', @(s,e)prop_listener(this,e));
      set(this, 'WhenRenderedListeners', union(this.WhenRenderedListeners, l));
      
      for indx = 1:length(tagsUpper)
        try
          prop_listener(this, tagsUpper{indx});
        catch ME %#ok<NASGU>
          % NO OP
        end
      end
      
    end
    
    function rendercontrols2(this, row, col, varargin)
      %RENDERCONTROLS   Render the properties.
      %   RENDERCONTROLS(THIS) Render all the public set and get properties,
      %   using the 'Description' from the label and determining the UIControl
      %   style from the datatype of the property.  A listener will be created on
      %   all the properties' 'PropertyPostSet' event and will call the
      %   PROP_LISTENER method.  This listener will be saved in the
      %   WhenRenderedListeners property.  The handle to each of the UIControl's
      %   will be stored in the Handles property in a field of the same name as
      %   the property, but in all lower case.  If a label is needed it will be
      %   stored in '([propname '_lbl'])' and its string will be set to the
      %   Description.
      %
      %   RENDERCONTROLS(THIS, PROPS) Render only the properties passed in
      %   the cell of strings PROPS.
      %
      %   RENDERCONTROLS(THIS, PROPS, DESCS) Use the cell of strings DESCS to
      %   label the controls instead of their descriptions.
      %
      %   RENDERCONTROLS(THIS, PROPS, DESCS, STYLES) Use the cell of strings
      %   STYLES instead of mapping the properties' DataTypes to UIControl
      %   styles.
      %
      %   DataType to UIControl Map
      %   On/Off          checkbox
      %   bool
      %   string          editbox
      %   all others      popup
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      narginchk(2,5);
      
      [props, tags, strs, styles] = parseinputs2(this, varargin{:});
      
      sz     = gui_sizes(this);
      cbs    = siggui_cbs(this);
      hPanel = get(this, 'Container');
      h      = get(this, 'Handles');
      
      hLayout = get(this, 'Layout');
      if isempty(hLayout)
        hLayout = siglayout.gridbaglayout(this.Container);
        set(this, 'Layout', hLayout);
      end
      
      tooltips = gettooltips(this);
      [cshtags, cshtool] = getcshtags(this);
      
      % Render the controls
      for indx = 1:length(tags)
        
        switch styles{indx}
          case 'checkbox'
            width = 2;
            inputs = {'String', strs{indx}};
          case {'edit', 'popup'}
            width = 1;
            inputs = {};
            if strcmpi(get(props(indx), 'DataType'), 'string vector')
              inputs = [inputs, {'Max', 2}];
            end
            if strcmpi(styles{indx}, 'popup')
              inputs = {inputs{:}, 'String', set(this, tags{indx})};
            end
            if ~isempty(strs{indx})
              tag = [tags{indx} '_lbl'];
              if isfield(tooltips, tag)
                lblinputs = {'TooltipString', tooltips.(tag)};
              else
                lblinputs = {};
              end
              
              h.(tag) = uicontrol(hPanel, ...
                'Style', 'Text', ...
                'HorizontalAlignment', 'Left', ...
                'Tag', tag, ...
                'String', strs{indx}, ...
                lblinputs{:});
              if isfield(cshtags, tags{indx})
                cshelpcontextmenu(h.(tag), cshtags.(tags{indx}), cshtool);
              end
              
              hLayout.add(h.(tag), row+indx-1, col, ...
                'Fill', 'Horizontal', ...
                'Anchor', 'SouthWest', ...
                'MinimumHeight', sz.uh-sz.lblTweak);
              
            end
        end
        if isfield(tooltips, tags{indx})
          inputs = {inputs{:}, 'TooltipString', tooltips.(tags{indx})};
        end
        h.(tags{indx}) = uicontrol(hPanel, ...
          'Style', styles{indx}, ...
          'HorizontalAlignment', 'Left', ...
          'Tag', tags{indx}, ...
          inputs{:}, ...
          'Callback', {cbs.property, this, tags{indx}, sprintf('Change %s', strs{indx})});
        if isfield(cshtags, tags{indx})
          cshelpcontextmenu(h.(tags{indx}), cshtags.(tags{indx}), cshtool);
        end
        
        if width == 2
          colindx = [col:col+1];
        else
          colindx = col+1;
        end
        
        hLayout.add(h.(tags{indx}), row+indx-1, colindx, ...
          'Fill', 'Horizontal', ...
          'MinimumHeight', sz.uh);
      end
      
      set(this, 'Handles', h);
      
      % Make sure everything is enabled properly.
      h = handles2vector(this);
      h(~isprop(h, 'Enable')) = [];
      setenableprop(h, this.Enable);
      
      % Add the listener to capture the property changes.
      l = event.proplistener(this, props, 'PostSet', @prop_listener);
      set(l, 'CallbackTarget', this);
      set(this, 'WhenRenderedListeners', union(this.WhenRenderedListeners, l));
      
      for indx = 1:length(tags)
        try
          prop_listener(this, tags{indx});
        catch
          % NO OP
        end
      end
      
    end
    
    
    function resizefcn(hObj, varargin)
      % Layout the uis if figure is different from default
      % hObj - Input is the handle to the object after all children have been added
      % IdealSize - Size at which the figure would ideally have been created
      
      %   Author(s): Z. Mecklai, J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      siggui_resizefcn(hObj, varargin{:});
      
    end
    
    
    function senderror(hObj, lid, lstr)
      %SENDERROR Send an error from the object
      %   SENDERROR(H, ERRSTR) Send an ErrorOccurred Notification using ERRSTR as
      %   the error.
      %
      %   SENDERROR(H, ERRID, ERRSTR) Send an ErrorOccurred Notification using
      %   ERRID as the error identifier.
      %
      %   SENDERROR(H) Send an ErrorOccurred Notification using LASTERR as the error
      %   and error identifier.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      narginchk(1,3);
      
      switch nargin
        
        case 2
          lstr = lid;
          lid = '';
      end
      
      if isempty(lstr) & isempty(lid), return; end
      
      errinfo.ErrorString = lstr;
      errinfo.ErrorID = lid;
      
      obj = sigdatatypes.notificationeventdataMCOS(hObj, 'ErrorOccurred', errinfo);
      
      notify(hObj, 'Notification', obj);
      
    end
    
    
    function sendfiledirty(hObj)
      %SENDFILEDIRTY Send the File Dirty notification
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      notify(hObj, 'Notification', sigdatatypes.notificationeventdataMCOS(hObj, 'FileDirty'));
      
    end
    
    function sendstatus(hObj, str)
      %SENDSTATUS Send a status from the object
      %   SENDSTATUS(H, STR) Send the StatusChanged Notification using STR as the
      %   new status.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(2,2);
      
      statusinfo.StatusString = str;
      
      notify(hObj, 'Notification', ...
        sigdatatypes.notificationeventdataMCOS(hObj, 'StatusChanged', statusinfo));
      
    end
    
    
    function sendwarning(hObj, wid, wstr)
      %SENDWARNING Send a warning from the object
      %   SENDWARNING(H, WARNSTR) Send a WarningOccurred Notification using WARNSTR as
      %   the warning.
      %
      %   SENDWARNING(H, WARNID, WARNSTR) Send a WarningOccurred Notification using
      %   WARNID as the warning identifier.
      %
      %   SENDWARNING(H) Send a WarningOccurred Notificatio using LASTWARN for the
      %   warning and the warning identifier.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(1,3);
      
      switch nargin
        case 1
          [wstr, wid] = lastwarn;
          lastwarn('');
          
          % Ignore this dispatcher warning and MFILT deprecation warning
          if strcmp(wid, 'MATLAB:dispatcher:pathWarning') || ...
                  strcmp(wid, 'dsp:mfilt:mfilt:Obsolete')
            return;
          end
        case 2
          wstr = wid;
          wid = [];
      end
      
      if isempty(wstr) && isempty(wid)
        return;
      end
      
      warninfo.WarningString = wstr;
      warninfo.WarningID     = wid;
      
      notify(hObj, 'Notification', ...
        sigdatatypes.notificationeventdataMCOS(hObj, 'WarningOccurred', warninfo));
      
    end
    
    
    function setInputProcessingState(this, s)
      %setInputProcessingState
      
      %   Copyright 2011 The MathWorks, Inc.
      
      % Set the input processing option. If loading from a pre R2011b block, then
      % set input processing to frame-based.
      
      if ~iscalledbydspblks(this)
        return;
      end
      
      if isfield(s,'InputProcessing')
        set(this,'InputProcessing',s.InputProcessing);
        if strcmpi(s.InputProcessing,'columns as channels (frame based)')
          idx = 1;
        elseif strcmpi(s.InputProcessing,'elements as channels (sample based)')
          idx = 2;
        else
          idx = 1;
        end
      else
        idx = 1;
        set(this,'InputProcessing',...
          'columns as channels (frame based)');
      end
      hdls = get(this,'Handles');
      set(hdls.inputprocessing_popup,'Value',idx)
      
      
    end
    
    
    function setpixelpos(this, field, varargin)
      %SETPIXELPOS Set a handle's position in pixels.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      narginchk(3,inf);
      
      % Get the handle if we are passed a field
      if ischar(field)
        field = this.Handles.(field);
        for indx = 1:length(varargin)-1
          if ischar(varargin{indx})
            field = field.(varargin{indx});
          else
            field = field(varargin{indx});
          end
        end
        pos = varargin{end};
      else
        pos = varargin{1};
      end
      
      origUnits = get(field, 'Units');
      set(field, 'Units', 'Pixels');
      set(field, 'Position', pos);
      if ~iscell(origUnits), origUnits = {origUnits}; end
      for indx = 1:length(origUnits)
        set(field(indx), 'Units', origUnits{indx});
      end
      
    end
    
    
    function setPopupStrings(this, field, objectStrings, popupStrings)
      %SETPOPUPSTRINGS Set the PopupStrings
      %   setPopupStrings(H, PROPNAME, STRINGS) Set the values in STRINGS into
      %   the string of the popup widget controlling the property in PROPNAME.
      %
      %   setPopupStrings(H, PROPNAME, STRINGS, XLATESTRINGS) Pass in the
      %   translated strings XLATESTRINGS and the value of the strings that are
      %   set into the object in STRINGS.
      
      %   Copyright 2009 The MathWorks, Inc.
      
      if nargin < 4
        popupStrings = objectStrings;
      end
      
      % Get the handle we need to update.
      h = get(this, 'Handles');
      h = h.(field);
      
      % See if the new string contains the value stored in the object.  It
      % should, but this is managed by the concrete class.  Put in safety to
      % select the first entry.
      value = find(strcmpi(this.(field), objectStrings));
      if isempty(value)
        value = 1;
      end
      
      % Set the english strings
      setappdata(h, 'PopupStrings', objectStrings);
      set(h, 'String', popupStrings, 'Value', value);
      
    end
    
    
    function setstate(hObj,s)
      %SETSTATE Set the state of the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(2,2);
      
      siggui_setstate(hObj, s);
      
    end
    
    function settag(h, tag)
      %SETTAG Set up the base elements of the object
      %   SETTAG(H, TAG)
      %
      %   Inputs:
      %       TAG     - The tag of the object
      %
      %   If no input is given <package>.<class> is used.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      if nargin < 2, tag = class(h); end
      set(h, 'Tag', tag);
      
    end
    
    
    function setunits(hObj,units)
      %SETUNITS Sets all units in the frame
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(2,2);
      
      siggui_setunits(hObj, units);
      
    end
    
    function setupenablelink(this, prop, varargin)
      %SETUPENABLELINK   Setup an enable link between properties
      %   SETUPENABLELINK(H, PROP, ENABVAL, LINKEDPROP1, LINKEDPROP2, etc.) Setup
      %   an enable link between PROP and LINKEDPROP1, LINKEDPROP2, etc. so that
      %   when PROP is set to ENABVALUE the linked properties UIControl's will
      %   become disabled.  If PROP is 'yes' or 'on' the linked properties
      %   UIControl's will be set to the enable state of the object.  ENABVALUE
      %   can be a cell array of values.
      
      narginchk(4,inf);
      
      % Create a listener on the link property and pass the extra inputs.
      l = event.proplistener(this, this.findprop(prop), 'PostSet', @(s,e)lclenablelink_listener(this,prop,varargin{:}));
      
      if ~isempty(this.WhenRenderedListeners)
        l = [l; this.WhenRenderedListeners(:)];
      end
      set(this, 'WhenRenderedListeners', l);
      
      db = this.LinkDatabase;
      
      newdb.prop = prop;
      newdb.enabvalue = varargin{1};
      newdb.linkedprops = varargin(2:end);
      
      if isempty(db)
        db = newdb;
      else
        db = [db, newdb];
      end
      
      this.LinkDatabase = db;
      
      % Call the listener to make sure that the controls are linked up.
      enablelink_listener(this, prop, varargin{:});
      
    end
    
    function cbs = siggui_cbs(this) %#ok
      %SIGGUI_CBS Generic Callbacks for SIGGUI objects
      %   SIGGUI_CBS Returns a structure of function handles to be used as
      %   callbacks.
      %
      %   method_cb(hcbo, eventStruct, this, method, transstr, varargin) will
      %   call the method like this:
      %
      %   method(this, varargin{:})
      %
      %   property_cb(hcbo, eventStruct, property, transstr) will set the
      %   property to sync up with the UIControl hcbo that sent the callback.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2011 The MathWorks, Inc.
      
      cbs.method   = @method_cb;
      cbs.property = @property_cb;
      cbs.event    = @event_cb;
      
    end
    
    
    function siggui_cshelpcontextmenu(hObj, cshtag, toolname)
      %ADDCSH Add context sensitive help to the frame
      
      % Author(s): J. Schickler
      % Copyright 1988-2008 The MathWorks, Inc.
      
      narginchk(2,3);
      
      if isempty(cshtag), return; end
      
      if nargin < 3, toolname = 'fdatool'; end
      
      h = handles2vector(hObj);
      
      % If there are no handles that can use a context menu return.
      if isempty(h), return; end
      
      h = h(logical(isprop(h, 'UIContextMenu'))); % G152363
      
      % If there are no handles that can use a context menu return.
      if isempty(h), return; end
      
      hc = hObj.CSHMenu;
      
      if ishghandle(hc), delete(hc); end
      
      hc = cshelpcontextmenu(h, cshtag, toolname);
      
      hObj.CSHMenu = hc;
      
    end
    
    
    function siggui_enable_listener(this, ~)
      %SIGGUI_ENABLE_LISTENER   The listener for the enable property.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      enabState = get(this, 'Enable');
      hall      = get(this, 'Handles');
      
      if isfield(hall, 'framewlabel')
        set(this, 'Handles', rmfield(hall, 'framewlabel'));
      end
      
      h         = handles2vector(this);
      
      set(this, 'Handles', hall);
      
      if isempty(h), return; end
      
      % Eliminate objects that cannot be disabled
      h(~isprop(h, 'Enable')) = [];
      
      setenableprop(h,enabState);
      
      % If there are any links in the enable database, make sure they are
      % updated properly.
      db = this.LinkDatabase;
      for indx = 1:length(db)
        enablelink_listener(this, db(indx).prop, db(indx).enabvalue, db(indx).linkedprops{:});
      end
      
      
    end
    
    function siggui_error(hObj, Title, errstr)
      %ERROR Error mechanism
      %   ERROR(H) Display an errordlg using 'Error' as the title and lasterr
      %   as the string.
      %
      %   ERROR(H, TITLE) Display an errordlg using TITLE as the title and lasterr
      %   as the string.
      %
      %   ERROR(H, TITLE, ERRSTR) Display an errordlg using TITLE as the title and
      %   ERRSTR as the string.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      narginchk(1,3);
      
      if isrendered(hObj)
        
        % Not sure about this.  Subclasses should probably take care of this.
        hFig = get(hObj,'FigureHandle');
        setptr(hFig, 'arrow');
      end
      
      if nargin < 2
        Title = 'Error';
      end
      if nargin < 3
        ME = MException.last;
        errstr = cleanerrormsg(ME.message);
      end
      
      % If there is no error string we cannot produce a worthwhile dialog.  This
      % fixes a dspblks problem.
      if isempty(errstr), return; end
      
      errordlg(errstr, getTranslatedString('signal:sigtools:siggui',Title), 'modal');
      
      
    end
    
    
    function s = siggui_getstate(hObj)
      %SIGGUI_GETSTATE Get the state of the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      s = get(hObj);
      
      if isrendered(hObj)
        p = findobj(hObj.RenderedPropHandles, 'Visible', 1);
        s = rmfield(s, {p.Name});
      end
      
    end
    
    
    function siggui_prop_listener(this, eventData)
      %SIGGUI_PROP_LISTENER Listener to the public properties of the Filter Wizard
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % If prop_listener is called with no inputs, we treat it as a global
      % update.  If called with a string input we just update that property.
      if nargin > 1
        if ischar(eventData)
          prop = eventData;
        else
          prop = eventData.Source.Name;
        end
      else
        props = fieldnames(getstate(this));
        for indx = 1:length(props)
          prop_listener(this, props{indx});
        end
        return;
      end
      
      h = get(this, 'Handles');
      
      % If is the property is not a field in the handles structure, ignore it
      if ~isfield(h, lower(prop))
        return;
      end
      
      uistyle = lower(get(h.(lower(prop)), 'Style'));
      
      hprop = findprop(this, prop);
      
      switch uistyle
        case 'checkbox'
          if isnumeric(this.(prop)) || islogical(this.(prop))
            if this.(prop) == 1
              val = 1;
            else
              val = 0;
            end
          elseif any(strcmpi(this.(hprop.Name),{'on','off','yes','no'}))
            if any(strcmpi(this.(hprop.Name),{'on','yes'}))
              val = 1;
            else
              val = 0;
            end
          else
            error(message('signal:siggui:siggui:siggui_prop_listener:InternalError', this.prop ))
          end
          
          set(h.(lower(prop)), 'Value', val);
        case {'edit', 'text'}
          if isnumeric(this.(prop))
            value = get(this, prop);
            if isreal(value)
              str = sprintf('%g', value);
            else
              if sign(imag(value)) == 1
                signstr = '+';
              else
                signstr = '';
              end
              str = sprintf('%g%s%gi', real(value), signstr, imag(value));
            end
          elseif ischar(this.(prop))
            str = this.(prop);
          elseif iscell(this.(hprop.Name)) && all(cellfun(@ischar,this.(hprop.Name)))
            str = get(this, prop);
            if isempty(str)
              str = '';
            else
              str = sprintf('%s\n', str{:});
              str(end) = [];
            end
          end
          set(h.(lower(prop)), 'String', str);
        case 'popupmenu'
          value = get(this, prop);
          if isnumeric(value)
            value = num2str(value);
          end
          
          % If we store the popupstrings (always english), get those, otherwise
          % get the strings in the popups.
          if isappdata(h.(lower(prop)), 'PopupStrings')
            allvs = lower(getappdata(h.(lower(prop)), 'PopupStrings'));
          else
            allvs = lower(get(h.(lower(prop)), 'String'));
          end
          % try for an exact match first.
          indx  = find(strcmpi(value, allvs));
          if isempty(indx)
            indx = strmatch(value, allvs);
            if isempty(indx)
              indx = 1;
            else
              indx = indx(1);
            end
          end
          set(h.(lower(prop)), 'Value', indx);
      end
      
    end
    
    function siggui_resizefcn(this, IdealSizeW, IdealSizeH)
      % Layout the uis if figure is different from default
      % this - Input is the handle to the object after all children have been added
      % IdealSize - Size at which the figure would ideally have been created
      
      %   Author(s): Z. Mecklai, J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      if nargin == 2
        if length(IdealSizeW) == 2
          IdealSizeH = IdealSizeW(2);
          IdealSizeW = IdealSizeW(1);
        else
          error(message('signal:siggui:siggui:siggui_resizefcn:GUIErr'))
        end
        
      end
      
      % Get the handle to the figure
      hFig = get(this, 'FigureHandle');
      
      % Store the figure units for later restoration
      FigureUnits = get(hFig,'Units');
      
      % Determine the figure's current size
      set(hFig,'Units','Pixels');
      FigureSize = get(hFig,'Position');
      set(hFig,'Units',FigureUnits);
      
      ratW = FigureSize(3)./(IdealSizeW);
      ratH = FigureSize(4)./(IdealSizeH);
      
      SizeRatio = [ratW ratH ratW ratH];
      
      % Get the handles of the object
      h = handles2vector(this);
      h = unique(h);
      h(strcmpi('uimenu', get(h, 'Type'))) = [];
      h(strcmpi('text', get(h, 'Type'))) = [];
      h(strcmpi('uicontextmenu', get(h, 'Type'))) = [];
      
      if isempty(h), return; end
      
      h = h(isprop(h, 'Position'));
      
      if isempty(h), return; end
      
      for indx = 1:length(h)
        set(h(indx), 'Position', get(h(indx), 'Position').*SizeRatio);
      end
      
    end
    
    
    function siggui_setstate(hObj,s)
      %SIGGUI_SETSTATE Set the state of the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(2,2);
      
      if isfield(s, 'Tag'),  s = rmfield(s, 'Tag'); end
      if isfield(s, 'Version'),  s = rmfield(s, 'Version'); end
      
      if ~isempty(s)
        flds = fields(s);
        for i = 1:length(flds)
          hObj.(flds{i}) = s.(flds{i});
        end
      end
      
    end
    
    function siggui_setunits(this, units)
      %SIGGUI_SETUNITS Sets all units in the frame
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      narginchk(2,2);
      
      if isempty(this.Container) || ~ishghandle(this.Container)
        
        hvec = handles2vector(this);
        
        if ~isempty(hvec)
          % Remove all objects that do not have a Units property.
          hvec(~isprop(hvec, 'Units')) = [];
          
          % Remove Text objects.  Do not set their units.
          hvec(ishghandle(hvec, 'text')) = [];
          
          set(hvec,'Units',units);
        end
      else
        set(this.Container, 'Units', units)
      end
      
    end
    
    
    function siggui_visible_listener(hObj, eventData)
      %SIGGUI_VISIBLE_LISTENER The listener for the visible property
      %   Does the actual work
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      visState = get(hObj, 'Visible');
      
      if isempty(hObj.Container) || ~ishghandle(hObj.Container)
        
        h = handles2vector(hObj);
        
        if length(h) == 1 && strcmp('uicontextmenu', get(h, 'Type'))
          h = [];
        else
          h(strcmp('uicontextmenu', get(h, 'Type'))) = [];
        end
        
        set(h,'Visible',visState);
      else
        set(hObj.Container, 'Visible', visState);
      end
      
    end
    
    
    function siggui_warning(hObj, title, wstr, wid)
      %WARNING Display a warndlg
      %   WARNING(H) Display a warndlg using 'Warning' as the title and lastwarn
      %   as the string.
      %
      %   WARNING(H, TITLE) Display a warndlg using TITLE as the title and lastwarn
      %   as the string.
      %
      %   WARNING(H, TITLE, WSTR) Display a warndlg using TITLE as the title and
      %   WSTR as the string.
      
      %   Copyright 1988-2011 The MathWorks, Inc.
      
      narginchk(1,4);
      
      if nargin < 4
        if nargin < 3
          [wstr, wid] = lastwarn;
        else
          wid = '';
        end
        if nargin < 2
          title = 'Warning';
        end
      end
      
      % Reset mouse pointer and status line.
      hFig = get(hObj, 'FigureHandle');
      setptr(hFig, 'arrow');
      
      actualwid = wid;
      wid = fliplr(strtok(fliplr(wid), ':'));
      
      % When we have the ID system working for all warnings we can do this:
      %
      switch lower(wid)
        case {'syntaxchanged', 'pathwarning'}
          % NO OP
        otherwise
          
          if any(strcmpi(wstr, {'negative data ignored.'}))
            return;
          end
          
          h_warn = warndlg(wstr, title);
          % Pass the warning id to the user data for testing purposes
          set(h_warn,'UserData',actualwid)
          
          h = get(hObj, 'Handles');
          
          if isfield(h, 'warn')
            h.warn(end+1) = h_warn;
          else
            h.warn = h_warn;
          end
          
          set(hObj, 'Handles', h);
      end
      
    end
    
    
    function thisrender(h, varargin)
      %THISRENDER Pass control to the subclass when rendering
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % NO OP
      
      % [EOF]
      
      
    end
    
    
    function thisselectedinputprocessing_cb(~)
      %THISSELECTEDINPUTPROCESSING_CB
      
      %   Copyright 2011 The MathWorks, Inc.
      
      % Let the subclass react to a change in the input processing popup
      
      % NO OP
      
      
    end
    
    
    function thisunrender(this, varargin)
      %THISUNRENDER Allow the subclass to take control
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      delete(handles2vector(this));
      
      if ~isempty(this.Container) && ishghandle(this.Container)
        delete(this.Container);
      end
      
    end
    
    
    function varargout = unrender(h, varargin)
      %UNRENDER Unrender the siggui object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      if isrendered(h)
        
        delete(h.Layout);
        
        % Send the sigguiUnrendering event
        notify(h, 'sigguiClosing');
        
        h.WhenRenderedListeners = [];
        %     delete(convert2vector(h.WhenRenderedListeners));
        
        % Allow subclasses to do whatever rendering they need.
        if nargout
          [varargout{1:nargout}] = thisunrender(h, varargin{:});
        else
          thisunrender(h, varargin{:});
        end
        
        % Make sure that the GUI is still rendered.  This check safeguards against
        % THISRENDER doing things that result in recursion.
        if isrendered(h)
          
          % Delete the rendered properties
          deleteproperties(h);
        end
      end
      
    end
    
    
    function visible_listener(hBase, eventData)
      %VISIBLE_LISTENER The listener for the visible property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % WARNING: This is the superclass listener which will perform a "blind"
      % set(h,'visible').  If you want to only certain UIControls to be made visible
      % or invisible you must overload this method.  It is recommended that you make
      % all UIcontrols invisible when the object is invisible.
      
      siggui_visible_listener(hBase, eventData);
      
    end
    
    
    function warning(h, varargin)
      %WARNING SIGGUI's warning mechanism
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      siggui_warning(h, varargin{:});
      
    end
    
    
    
  end
  
  
  methods (Sealed)
    function h = findobj(varargin)
      h = findobj@handle(varargin{:});
    end
  end
  
  
end


%----------------------------------------------------------------------
function selectedinputprocessing_cb(hcbo, ~, this, strs)

indx = get(hcbo, 'Value');
set(this, 'InputProcessing', strs{indx});

thisselectedinputprocessing_cb(this)

sendfiledirty(this);

end


% -------------------------------------------------------------------------
function add_properties(this)

this.addprop('Visible');
dy(1) = this.findprop('Visible');
dy(1).SetObservable = true;
this.Visible = 'off';

this.addprop('Enable');
dy(2) = this.findprop('Enable');
dy(2).SetObservable = true;
this.Enable = 'off';

this.addprop('FigureHandle');
dy(3) = this.findprop('FigureHandle');
dy(3).Hidden = true;
dy(3).SetMethod = @set_figurehandle;
dy(3).GetMethod = @get_figurehandle;

this.addprop('Parent');
dy(4) = this.findprop('Parent');

this.addprop('Container');
dy(5) = this.findprop('Container');

this.addprop('Handles');
dy(6) = this.findprop('Handles');

this.addprop('BaseListeners');
dy(7) = this.findprop('BaseListeners');

this.addprop('WhenRenderedListeners');
dy(8) = this.findprop('WhenRenderedListeners');

this.addprop('RenderedPropHandles');
dy(9) = this.findprop('RenderedPropHandles');

this.addprop('Layout');
dy(10) = this.findprop('Layout');

this.RenderedPropHandles = dy;
this.Enable = 'on';
this.Parent = -1;

dy(6).Hidden = true;
dy(7).Hidden = true;
dy(8).Hidden = true;
dy(9).Hidden = true;
dy(10).Hidden = true;

end

% -------------------------------------------------------------------------
function hf = set_figurehandle(this, hf)

set(this, 'Parent', hf);

hf = [];

end

% -------------------------------------------------------------------------
function hf = get_figurehandle(this, hf) %#ok

if ishghandle(this.Parent)
  hf = ancestor(this.Parent, 'figure');
else
  hf = -1;
end

end

% -------------------------------------------------------------------------
function install_listeners(this)

% Create listeners on the visible and enable properties
listener{1} = event.proplistener(this, this.findprop('Visible'), ...
  'PostSet', makeVisibleListener(this));
listener{2} = event.proplistener(this, this.findprop('Enable'), ...
  'PostSet', makeEnableListener(this));

% Save the listeners in WhenRenderedListeners
this.BaseListeners = listener;

end

% -------------------------------------------------------------------------
function cb = makeVisibleListener(this)

cb = @(h, ev) lclvisible_listener(this, ev);

end

% -------------------------------------------------------------------------
function cb = makeEnableListener(this,val)

cb = @(h, ev) lclenable_listener(this, ev);

end

% -------------------------------------------------------------------------
function install_figurelistener(this)

hFig = get(this, 'Parent');

if ishghandle(hFig)
  
  listener = this.BaseListeners;
  
  % Create the listener
  listener{end+1} = addlistener(hFig, ...
    'ObjectBeingDestroyed', makeFigureDestroyListener(this));
  listener{end+1} = addlistener(this, ...
    'ObjectBeingDestroyed', makeObjectDestroyListener(this));
  
  this.BaseListeners = listener;
end

end

% -------------------------------------------------------------------------
function cb = makeObjectDestroyListener(this)

cb = @(h, ev) objectbeingdestroyed_listener(this, ev);

end


% -------------------------------------------------------------------------
function cb = makeFigureDestroyListener(this)

cb = @(h, ev) lclfigure_listener(this, ev);

end


% -------------------------------------------------------------------------
%       Local Listeners (local function handles are faster)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
function lclfigure_listener(this, eventData)

% Make sure the object is still valid.  The event is being cached and the
% object is being deleted before coming into this listener
if isa(this, 'siggui.sigguiMCOS')
  figure_listener(this, eventData)
end

end


% -------------------------------------------------------------------------
function lclenable_listener(this, eventData)

enable_listener(this, eventData)

end


% -------------------------------------------------------------------------
function lclvisible_listener(this, eventData)

visible_listener(this, eventData)

end


% -------------------------------------------------------------------------
function objectbeingdestroyed_listener(this, eventData) %#ok

if isrendered(this) && ~strcmpi(this.Tag, 'siggui.cfi') 
  if (isprop(this,'Visible'))
    % Protect against being called when object has already been deleted.
    this.Visible = 'Off';
    unrender(this);
  end  
end

end


% --------------------------------------------------------
function [props, tags, strs, styles] = parseinputs(this, tags, strs, styles)

% Get the tags (properties)
if nargin < 2
  props = find(this.classhandle.Properties, ...
    'AccessFlags.PublicSet', 'On', 'AccessFlags.PublicGet', 'On', ...
    '-not', 'Name', 'Tag'); %#ok<GTARG>
  tags  = get(props, 'Name');
  
else
  tags = cellstr(tags);
  for indx = 1:length(tags)
    props(indx) = findprop(this, tags{indx}); %#ok<AGROW>
  end
end
tags = lower(tags);

% Get the descriptions
if nargin < 3
  for indx = 1:length(props)
    strs{indx} = props(indx).Description;
    
    % If the description is empty, get the string from the name.  Don't
    % get it from "tags" as this is lower cased.
    if isempty(strs{indx})
      strs{indx} = interspace(props(indx).Name);
    end
  end
else
  strs = cellstr(strs);
end

% Get the uicontrol styles
if nargin < 4
  for indx = 1:length(tags)
    
    defVal = this.(props(indx).Name);
    if isnumeric(defVal) && (defVal==0 || defVal==1)
      styles{indx} = 'checkbox';
    elseif islogical(defVal) && (defVal==true || defVal==false)
      styles{indx} = 'checkbox';
    elseif ischar(defVal) && any(strcmpi(defVal,{'on','off','yes','no'}))
      styles{indx} = 'checkbox';
    elseif ischar(defVal)
      out = set(this,props(indx).Name);
      if ~isempty(out) && all(cellfun(@ischar,out))
        styles{indx} = 'popup';
      else
        styles{indx} = 'edit';
      end
    end
  end
  
else
  styles = cellstr(styles);
end

end


% --------------------------------------------------------
function [props, tags, strs, styles] = parseinputs2(this, tags, strs, styles)

% Get the tags (properties)
if nargin < 2
  props = find(this.classhandle.Properties, ...
    'AccessFlags.PublicSet', 'On', 'AccessFlags.PublicGet', 'On', ...
    '-not', 'Name', 'Tag');
  tags  = get(props, 'Name');
  
else
  tags = cellstr(tags);
  for indx = 1:length(tags)
    props(indx) = findprop(this, tags{indx});
  end
end
tags = lower(tags);

% Get the descriptions
if nargin < 3
  for indx = 1:length(props)
    strs{indx} = get(props(indx), 'Description');
    
    % If the description is empty, get the string from the name.  Don't
    % get it from "tags" as this is lower cased.
    if isempty(strs{indx})
      strs{indx} = interspace(get(props(indx), 'Name'));
    end
  end
else
  strs = cellstr(strs);
end

% Get the uicontrol styles
if nargin < 4
  for indx = 1:length(tags)
    switch lower(get(props(indx), 'DataType'))
      case {'on/off', 'bool', 'strictbool', 'yes/no'}
        styles{indx} = 'checkbox';
      case {'string','ustring', 'string vector'}
        styles{indx} = 'edit';
      otherwise
        styles{indx} = 'popup';
    end
  end
else
  styles = cellstr(styles);
end

end


% -------------------------------------------------------------- --
function method_cb(hcbo, eventStruct, this, method, transstr, varargin) %#ok

narginchk(4,inf);

% Change the pointer to a 'watch'
hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

% Set the warning state to off
w = warning('off'); %#ok
lastwarn('');

try
  
  feval(method, this, varargin{:});
  % Protect against cases where the callback is deleting the object.
  if ~isa(this, 'siggui.sigguiMCOS')
    warning(w);
    return;
  end
  
catch ME
  try
    
    % Send the error, clean up the message to work around
    % udd/mexception issue.
    senderror(this, ME.identifier, cleanerrormsg(ME.message));
    
  catch ME %#ok<NASGU>
    % NO OP, if there is something wrong with the transaction we dont
    % want to send an error.
  end
  
end

% Reset the warning state and send any new warnings
warning(w);
sendwarning(this);

% Reset the figure pointer
set(hFig, p{:});

end


% ----------------------------------------------------------------
function property_cb(hcbo, eventStruct, this, property, tstr) %#ok

narginchk(4,5);

hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

w = warning('off'); %#ok
lastwarn('');

uistyle = lower(get(hcbo, 'Style'));

% Listboxes that can only select one thing act like popups.
if strcmpi(uistyle, 'listbox') && (get(hcbo, 'Max')-get(hcbo, 'Min')) < 2
  uistyle = 'popupmenu';
end

hprop = findprop(this, property);
defVal = this.(hprop.Name);

% Get the new value from the callback object
switch uistyle 
  
  case 'checkbox'
    if (islogical(defVal) || isnumeric(defVal))  && (defVal==true || defVal==false)
      newvalue = get(hcbo, 'Value');
    elseif ischar(defVal) && any(strcmpi(defVal,{'on','off'}))
      if get(hcbo, 'Value') 
          newvalue = 'On';
        else
          newvalue = 'Off'; 
      end
    elseif ischar(defVal) && any(strcmpi(defVal,{'yes','no'}))
       if get(hcbo, 'Value') 
          newvalue = 'Yes';
        else
          newvalue = 'No'; 
       end
    end
    
  case 'edit'
    newvalue = fixup_uiedit(hcbo);
    newvalue = newvalue{1};
    if iscellstr(this.(property))
      newvaluecell = cell(1, size(newvalue, 1));
      for indx = 1:size(newvalue, 1)
        newvaluecell{indx} = deblank(newvalue(indx, :));
      end
      newvalue = newvaluecell;
    end
  case 'popupmenu'
    newvalue = lclpopupstr(hcbo);
  case 'listbox'
    indx = get(hcbo, 'Value');
    str  = get(hcbo, 'String');
    newvalue = str(indx);
end

% Perform the property setting.
try
  this.(property) = newvalue;
  sendfiledirty(this);
  notify(this, 'UserModifiedSpecs');
catch ME
  senderror(this, ME.identifier, ME.message);
end

warning(w);
sendwarning(this);

set(hFig, p{:});

end

%-------------------------------------------------------------------------
function string = lclpopupstr(hcbo)

if isappdata(hcbo, 'PopupStrings')
  strings = getappdata(hcbo, 'PopupStrings');
else
  strings = get(hcbo, 'String');
end

index  = get(hcbo, 'Value');
string = strings{index};

end

%-------------------------------------------------------------------------
function event_cb(hcbo, eventStruct, this, event, data) %#ok

narginchk(4,5);

% Set up the figure's pointer
hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

w = warning('off'); %#ok
lastwarn('');

% Build the eventdata.  If data was passed in, use sigeventdata.
if nargin > 4, ed = sigdatatypes.sigeventdata(this, event, data);
else           ed = handle.EventData(this, event); end

% Send the event
send(this, event, ed);

%Protect against cases where the callback is deleting the object
if ~isa(this, 'siggui.sigguiMCOS')
  warning(w);
  return;
end

warning(w);
sendwarning(this);

% Reset the figure's pointer
set(hFig, p{:});

end

% -------------------------------------------------------------------------
function lclenablelink_listener(varargin)

enablelink_listener(varargin{:});

end


% ---------------------------------------------------------------------------
function deleteproperties(h)

% hRProps = get(h, 'RenderedPropHandles');

% If hRProps is empty (this was probably caused by an undo operation), just
% find all the properties.
% if isempty(hRProps),
hRProps = [h.findprop('Visible'), ...
  h.findprop('Enable'), ...
  h.findprop('Layout'), ...
  h.findprop('FigureHandle'), ...
  h.findprop('Handles'), ...
  h.findprop('WhenRenderedListeners'), ...
  h.findprop('RenderedPropHandles'), ...
  h.findprop('BaseListeners'), ...
  h.findprop('Parent'), ...
  h.findprop('Container')];
% end
delete(hRProps);

end
