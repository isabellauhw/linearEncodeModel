classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) sigfig < hgsetget & matlab.mixin.Copyable
  %sigtools.sigfig class
  %    sigtools.sigfig properties:
  %       Alphamap - Property is of type 'mxArray'
  %       CloseRequestFcn - Property is of type 'mxArray'
  %       Color - Property is of type 'mxArray'
  %       Colormap - Property is of type 'mxArray'
  %       ContextMenu - Property is of type 'mxArray'
  %       CurrentAxes - Property is of type 'mxArray'
  %       CurrentCharacter - Property is of type 'mxArray'
  %       CurrentObject - Property is of type 'mxArray'
  %       CurrentPoint - Property is of type 'mxArray'
  %       DockControls - Property is of type 'on/off'
  %       FileName - Property is of type 'mxArray'
  %       IntegerHandle - Property is of type 'on/off'
  %       InvertHardcopy - Property is of type 'on/off'
  %       KeyPressFcn - Property is of type 'mxArray'
  %       KeyReleaseFcn - Property is of type 'mxArray'
  %       MenuBar - Property is of type 'mxArray'
  %       Name - Property is of type 'mxArray'
  %       NextPlot - Property is of type 'mxArray'
  %       NumberTitle - Property is of type 'on/off'
  %       PaperUnits - Property is of type 'mxArray'
  %       PaperOrientation - Property is of type 'mxArray'
  %       PaperPosition - Property is of type 'mxArray'
  %       PaperPositionMode - Property is of type 'mxArray'
  %       PaperSize - Property is of type 'mxArray'
  %       PaperType - Property is of type 'mxArray'
  %       Pointer - Property is of type 'mxArray'
  %       PointerShapeCData - Property is of type 'mxArray'
  %       PointerShapeHotSpot - Property is of type 'mxArray'
  %       Position - Property is of type 'mxArray'
  %       Renderer - Property is of type 'mxArray'
  %       RendererMode - Property is of type 'mxArray'
  %       Resize - Property is of type 'on/off'
  %       ResizeFcn - Property is of type 'mxArray'
  %       SelectionType - Property is of type 'mxArray'
  %       ToolBar - Property is of type 'mxArray'
  %       Type - Property is of type 'mxArray'
  %       Units - Property is of type 'mxArray'
  %       WindowButtonDownFcn - Property is of type 'mxArray'
  %       WindowButtonMotionFcn - Property is of type 'mxArray'
  %       WindowButtonUpFcn - Property is of type 'mxArray'
  %       WindowKeyPressFcn - Property is of type 'mxArray'
  %       WindowKeyReleaseFcn - Property is of type 'mxArray'
  %       WindowScrollWheelFcn - Property is of type 'mxArray'
  %       WindowStyle - Property is of type 'mxArray'
  %       BeingDeleted - Property is of type 'mxArray'
  %       ButtonDownFcn - Property is of type 'mxArray'
  %       Children - Property is of type 'mxArray'
  %       Clipping - Property is of type 'on/off'
  %       CreateFcn - Property is of type 'mxArray'
  %       DeleteFcn - Property is of type 'mxArray'
  %       BusyAction - Property is of type 'mxArray'
  %       HandleVisibility - Property is of type 'mxArray'
  %       HitTest - Property is of type 'on/off'
  %       Interruptible - Property is of type 'on/off'
  %       Parent - Property is of type 'mxArray'
  %       Selected - Property is of type 'on/off'
  %       SelectionHighlight - Property is of type 'on/off'
  %       Tag - Property is of type 'mxArray'
  %       UIContextMenu - Property is of type 'mxArray'
  %       UserData - Property is of type 'mxArray'
  %       Visible - Property is of type 'on/off'
  %
  %    sigtools.sigfig methods:
  %       addcomponent - Add a component to the container
  %       addmenu - Add a menu to figure.
  %       allchild - Returns all the children of the figure
  %       close - Close the figure
  %       disp - Display the figure handle
  %       double -   Return the figure handle.
  %       figure - Bring figure forward.
  %       findobj - Find objects with specified property values.
  %       getappdata - Returns the application data specified
  %       getcomponent - Retrieve a component handle from the container
  %       getprop - GETFCN Get the property from the contained figure
  %       isappdata - Returns true if the application data exists
  %       print - Print the contained figure
  %       printdlg -  Print dialog box.
  %       printpreview -  Display preview of figure to be printed
  %       rmappdata - Remove the application data
  %       rmcomponent - Remove a component
  %       setappdata - Saves the application data specified
  %       setintegerhandle - Set the integer handle of the contained figure
  %       setprop - SETFCN Set the property in the contained figure
  %       sigfig_construct - Create the contained figure
  
  %   Copyright 2015-2017 The MathWorks, Inc.
  
  properties (AbortSet, SetObservable, GetObservable)
    %ALPHAMAP Property is of type 'mxArray'
    Alphamap = [];
    %CLOSEREQUESTFCN Property is of type 'mxArray'
    CloseRequestFcn = [];
    %COLOR Property is of type 'mxArray'
    Color = [];
    %COLORMAP Property is of type 'mxArray'
    Colormap = [];
    %CONTEXTMENU Property is of type 'mxArray'
    ContextMenu = [];
    %CURRENTAXES Property is of type 'mxArray'
    CurrentAxes = [];
    %CURRENTCHARACTER Property is of type 'mxArray'
    CurrentCharacter = [];
    %CURRENTOBJECT Property is of type 'mxArray'
    CurrentObject = [];
    %CURRENTPOINT Property is of type 'mxArray'
    CurrentPoint = [];
    %DOCKCONTROLS Property is of type 'on/off'
    DockControls
    %FILENAME Property is of type 'mxArray'
    FileName = [];
    %INTEGERHANDLE Property is of type 'on/off'
    IntegerHandle
    %INVERTHARDCOPY Property is of type 'on/off'
    InvertHardcopy
    %KEYPRESSFCN Property is of type 'mxArray'
    KeyPressFcn = [];
    %KEYRELEASEFCN Property is of type 'mxArray'
    KeyReleaseFcn = [];
    %MENUBAR Property is of type 'mxArray'
    MenuBar = [];
    %NAME Property is of type 'mxArray'
    Name = [];
    %NEXTPLOT Property is of type 'mxArray'
    NextPlot = [];
    %NUMBERTITLE Property is of type 'on/off'
    NumberTitle
    %PAPERUNITS Property is of type 'mxArray'
    PaperUnits = [];
    %PAPERORIENTATION Property is of type 'mxArray'
    PaperOrientation = [];
    %PAPERPOSITION Property is of type 'mxArray'
    PaperPosition = [];
    %PAPERPOSITIONMODE Property is of type 'mxArray'
    PaperPositionMode = [];
    %PAPERSIZE Property is of type 'mxArray'
    PaperSize = [];
    %PAPERTYPE Property is of type 'mxArray'
    PaperType = [];
    %POINTER Property is of type 'mxArray'
    Pointer = [];
    %POINTERSHAPECDATA Property is of type 'mxArray'
    PointerShapeCData = [];
    %POINTERSHAPEHOTSPOT Property is of type 'mxArray'
    PointerShapeHotSpot = [];
    %POSITION Property is of type 'mxArray'
    Position = [];
    %RENDERER Property is of type 'mxArray'
    Renderer = [];
    %RENDERERMODE Property is of type 'mxArray'
    RendererMode = [];
    %RESIZE Property is of type 'on/off'
    Resize
    %RESIZEFCN Property is of type 'mxArray'
    ResizeFcn = [];
    %SELECTIONTYPE Property is of type 'mxArray'
    SelectionType = [];
    %TOOLBAR Property is of type 'mxArray'
    ToolBar = [];
    %TYPE Property is of type 'mxArray'
    Type = [];
    %UNITS Property is of type 'mxArray'
    Units = [];
    %WINDOWBUTTONDOWNFCN Property is of type 'mxArray'
    WindowButtonDownFcn = [];
    %WINDOWBUTTONMOTIONFCN Property is of type 'mxArray'
    WindowButtonMotionFcn = [];
    %WINDOWBUTTONUPFCN Property is of type 'mxArray'
    WindowButtonUpFcn = [];
    %WINDOWKEYPRESSFCN Property is of type 'mxArray'
    WindowKeyPressFcn = [];
    %WINDOWKEYRELEASEFCN Property is of type 'mxArray'
    WindowKeyReleaseFcn = [];
    %WINDOWSCROLLWHEELFCN Property is of type 'mxArray'
    WindowScrollWheelFcn = [];
    %WINDOWSTYLE Property is of type 'mxArray'
    WindowStyle = [];
    %BEINGDELETED Property is of type 'mxArray'
    BeingDeleted = [];
    %BUTTONDOWNFCN Property is of type 'mxArray'
    ButtonDownFcn = [];
    %CHILDREN Property is of type 'mxArray'
    Children = [];
    %CLIPPING Property is of type 'on/off'
    Clipping
    %CREATEFCN Property is of type 'mxArray'
    CreateFcn = [];
    %DELETEFCN Property is of type 'mxArray'
    DeleteFcn = [];
    %BUSYACTION Property is of type 'mxArray'
    BusyAction = [];
    %HANDLEVISIBILITY Property is of type 'mxArray'
    HandleVisibility = [];
    %HITTEST Property is of type 'on/off'
    HitTest
    %INTERRUPTIBLE Property is of type 'on/off'
    Interruptible
    %PARENT Property is of type 'mxArray'
    Parent = [];
    %SELECTED Property is of type 'on/off'
    Selected
    %SELECTIONHIGHLIGHT Property is of type 'on/off'
    SelectionHighlight
    %TAG Property is of type 'mxArray'
    Tag = [];
    %USERDATA Property is of type 'mxArray'
    UserData = [];
    %VISIBLE Property is of type 'on/off'
    Visible
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %HANDLES Property is of type 'MATLAB array' (hidden)
    Handles = [];
    %BACKINGSTORE Property is of type 'on/off' (hidden)
    BackingStore
    %DITHERMAP Property is of type 'mxArray' (hidden)
    DitherMap = [];
    %DITHERMAPMODE Property is of type 'mxArray' (hidden)
    DitherMapMode = [];
    %DOUBLEBUFFER Property is of type 'on/off' (hidden)
    DoubleBuffer
    %FIXEDCOLORS Property is of type 'mxArray' (hidden)
    FixedColors = [];
    %MINCOLORMAP Property is of type 'mxArray' (hidden)
    MinColormap = [];
    %UICONTEXTMENU Property is of type 'mxArray' (hidden)
    UIContextMenu = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %FIGUREHANDLE Property is of type 'mxArray'
    FigureHandle = [];
    %NOTIFICATIONLISTENER Property is of type 'handle.listener'
    NotificationListener = [];
    %OBJECTBEINGDESTROYEDLISTENER Property is of type 'handle.listener vector'
    ObjectBeingDestroyedListener = [];
    %SIGGUICOMPONENTS Property is of type 'MATLAB array'
    SigguiComponents = [];
  end
  
  
  events
    Notification
  end  % events
  
  methods
    function set.FigureHandle(obj,value)
      obj.FigureHandle = value;
    end
    
    function set.NotificationListener(obj,value)
      % DataType = 'handle.listener'
      validateattributes(value,{'event.listener'}, {'scalar'},'','NotificationListener')
      obj.NotificationListener = value;
    end
    
    function set.ObjectBeingDestroyedListener(obj,value)
      % DataType = 'handle.listener vector'
      validateattributes(value,{'event.listener'}, {'vector'},'','ObjectBeingDestroyedListener')
      obj.ObjectBeingDestroyedListener = value;
    end
    
    function value = get.Alphamap(obj)
      value = getproperty(obj,obj.Alphamap,'alphamap');
    end
    function set.Alphamap(obj,value)
      obj.Alphamap = setproperty(obj,value,'alphamap');
    end
    
    function value = get.BackingStore(obj)
      value = getproperty(obj,obj.BackingStore,'backingstore');
    end
    function set.BackingStore(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','BackingStore');
      obj.BackingStore = setproperty(obj,value,'backingstore');
    end
    
    function value = get.CloseRequestFcn(obj)
      value = getproperty(obj,obj.CloseRequestFcn,'closerequestfcn');
    end
    function set.CloseRequestFcn(obj,value)
      obj.CloseRequestFcn = setproperty(obj,value,'closerequestfcn');
    end
    
    function value = get.Color(obj)
      value = getproperty(obj,obj.Color,'color');
    end
    function set.Color(obj,value)
      obj.Color = setproperty(obj,value,'color');
    end
    
    function value = get.Colormap(obj)
      value = getproperty(obj,obj.Colormap,'colormap');
    end
    function set.Colormap(obj,value)
      obj.Colormap = setproperty(obj,value,'colormap');
    end
    
    function value = get.ContextMenu(obj)
      value = getproperty(obj,obj.ContextMenu,'contextmenu');
    end
    function set.ContextMenu(obj,value)
      obj.ContextMenu = setproperty(obj,value,'contextmenu');
    end
    
    function value = get.CurrentAxes(obj)
      value = getproperty(obj,obj.CurrentAxes,'currentaxes');
    end
    function set.CurrentAxes(obj,value)
      obj.CurrentAxes = setproperty(obj,value,'currentaxes');
    end
    
    function value = get.CurrentCharacter(obj)
      value = getproperty(obj,obj.CurrentCharacter,'currentcharacter');
    end
    function set.CurrentCharacter(obj,value)
      obj.CurrentCharacter = setproperty(obj,value,'currentcharacter');
    end
    
    function value = get.CurrentObject(obj)
      value = getproperty(obj,obj.CurrentObject,'currentobject');
    end
    function set.CurrentObject(obj,value)
      obj.CurrentObject = setproperty(obj,value,'currentobject');
    end
    
    function value = get.CurrentPoint(obj)
      value = getproperty(obj,obj.CurrentPoint,'currentpoint');
    end
    function set.CurrentPoint(obj,value)
      obj.CurrentPoint = setproperty(obj,value,'currentpoint');
    end
    
    function value = get.DitherMap(obj)
      value = getproperty(obj,obj.DitherMap,'dithermap');
    end
    function set.DitherMap(obj,value)
      obj.DitherMap = setproperty(obj,value,'dithermap');
    end
    
    function value = get.DitherMapMode(obj)
      value = getproperty(obj,obj.DitherMapMode,'dithermapmode');
    end
    function set.DitherMapMode(obj,value)
      obj.DitherMapMode = setproperty(obj,value,'dithermapmode');
    end
    
    function value = get.DockControls(obj)
      value = getproperty(obj,obj.DockControls,'dockcontrols');
    end
    function set.DockControls(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','DockControls');
      obj.DockControls = setproperty(obj,value,'dockcontrols');
    end
    
    function value = get.DoubleBuffer(obj)
      value = getproperty(obj,obj.DoubleBuffer,'doublebuffer');
    end
    function set.DoubleBuffer(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','DoubleBuffer');
      obj.DoubleBuffer = setproperty(obj,value,'doublebuffer');
    end
    
    function value = get.FileName(obj)
      value = getproperty(obj,obj.FileName,'filename');
    end
    function set.FileName(obj,value)
      obj.FileName = setproperty(obj,value,'filename');
    end
    
    function value = get.FixedColors(obj)
      value = getproperty(obj,obj.FixedColors,'fixedcolors');
    end
    function set.FixedColors(obj,value)
      obj.FixedColors = setproperty(obj,value,'fixedcolors');
    end
    
    function value = get.IntegerHandle(obj)
      value = getproperty(obj,obj.IntegerHandle,'integerhandle');
    end
    function set.IntegerHandle(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','IntegerHandle');
      obj.IntegerHandle = setintegerhandle(obj,value);
    end
    
    function value = get.InvertHardcopy(obj)
      value = getproperty(obj,obj.InvertHardcopy,'inverthardcopy');
    end
    function set.InvertHardcopy(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','InvertHardcopy');
      obj.InvertHardcopy = setproperty(obj,value,'inverthardcopy');
    end
    
    function value = get.KeyPressFcn(obj)
      value = getproperty(obj,obj.KeyPressFcn,'keypressfcn');
    end
    function set.KeyPressFcn(obj,value)
      obj.KeyPressFcn = setproperty(obj,value,'keypressfcn');
    end
    
    function value = get.KeyReleaseFcn(obj)
      value = getproperty(obj,obj.KeyReleaseFcn,'keyreleasefcn');
    end
    function set.KeyReleaseFcn(obj,value)
      obj.KeyReleaseFcn = setproperty(obj,value,'keyreleasefcn');
    end
    
    function value = get.MenuBar(obj)
      value = getproperty(obj,obj.MenuBar,'menubar');
    end
    function set.MenuBar(obj,value)
      obj.MenuBar = setproperty(obj,value,'menubar');
    end
    
    function value = get.MinColormap(obj)
      value = getproperty(obj,obj.MinColormap,'mincolormap');
    end
    function set.MinColormap(obj,value)
      obj.MinColormap = setproperty(obj,value,'mincolormap');
    end
    
    function value = get.Name(obj)
      value = getproperty(obj,obj.Name,'name');
    end
    function set.Name(obj,value)
      obj.Name = setproperty(obj,value,'name');
    end
    
    function value = get.NextPlot(obj)
      value = getproperty(obj,obj.NextPlot,'nextplot');
    end
    function set.NextPlot(obj,value)
      obj.NextPlot = setproperty(obj,value,'nextplot');
    end
    
    function value = get.NumberTitle(obj)
      value = getproperty(obj,obj.NumberTitle,'numbertitle');
    end
    function set.NumberTitle(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','NumberTitle');
      obj.NumberTitle = setproperty(obj,value,'numbertitle');
    end
    
    function value = get.PaperUnits(obj)
      value = getproperty(obj,obj.PaperUnits,'paperunits');
    end
    function set.PaperUnits(obj,value)
      obj.PaperUnits = setproperty(obj,value,'paperunits');
    end
    
    function value = get.PaperOrientation(obj)
      value = getproperty(obj,obj.PaperOrientation,'paperorientation');
    end
    function set.PaperOrientation(obj,value)
      obj.PaperOrientation = setproperty(obj,value,'paperorientation');
    end
    
    function value = get.PaperPosition(obj)
      value = getproperty(obj,obj.PaperPosition,'paperposition');
    end
    function set.PaperPosition(obj,value)
      obj.PaperPosition = setproperty(obj,value,'paperposition');
    end
    
    function value = get.PaperPositionMode(obj)
      value = getproperty(obj,obj.PaperPositionMode,'paperpositionmode');
    end
    function set.PaperPositionMode(obj,value)
      obj.PaperPositionMode = setproperty(obj,value,'paperpositionmode');
    end
    
    function value = get.PaperSize(obj)
      value = getproperty(obj,obj.PaperSize,'papersize');
    end
    function set.PaperSize(obj,value)
      obj.PaperSize = setproperty(obj,value,'papersize');
    end
    
    function value = get.PaperType(obj)
      value = getproperty(obj,obj.PaperType,'papertype');
    end
    function set.PaperType(obj,value)
      obj.PaperType = setproperty(obj,value,'papertype');
    end
    
    function value = get.Pointer(obj)
      value = getproperty(obj,obj.Pointer,'pointer');
    end
    function set.Pointer(obj,value)
      obj.Pointer = setproperty(obj,value,'pointer');
    end
    
    function value = get.PointerShapeCData(obj)
      value = getproperty(obj,obj.PointerShapeCData,'pointershapecdata');
    end
    function set.PointerShapeCData(obj,value)
      obj.PointerShapeCData = setproperty(obj,value,'pointershapecdata');
    end
    
    function value = get.PointerShapeHotSpot(obj)
      value = getproperty(obj,obj.PointerShapeHotSpot,'pointershapehotspot');
    end
    function set.PointerShapeHotSpot(obj,value)
      obj.PointerShapeHotSpot = setproperty(obj,value,'pointershapehotspot');
    end
    
    function value = get.Position(obj)
      value = getproperty(obj,obj.Position,'position');
    end
    function set.Position(obj,value)
      obj.Position = setproperty(obj,value,'position');
    end
    
    function value = get.Renderer(obj)
      value = getproperty(obj,obj.Renderer,'renderer');
    end
    function set.Renderer(obj,value)
      obj.Renderer = setproperty(obj,value,'renderer');
    end
    
    function value = get.RendererMode(obj)
      value = getproperty(obj,obj.RendererMode,'renderermode');
    end
    function set.RendererMode(obj,value)
      obj.RendererMode = setproperty(obj,value,'renderermode');
    end
    
    function value = get.Resize(obj)
      value = getproperty(obj,obj.Resize,'resize');
    end
    function set.Resize(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Resize');
      obj.Resize = setproperty(obj,value,'resize');
    end
    
    function value = get.ResizeFcn(obj)
      value = getproperty(obj,obj.ResizeFcn,'resizefcn');
    end
    function set.ResizeFcn(obj,value)
      obj.ResizeFcn = setproperty(obj,value,'resizefcn');
    end
    
    function value = get.SelectionType(obj)
      value = getproperty(obj,obj.SelectionType,'selectiontype');
    end
    function set.SelectionType(obj,value)
      obj.SelectionType = setproperty(obj,value,'selectiontype');
    end
    
    function value = get.ToolBar(obj)
      value = getproperty(obj,obj.ToolBar,'toolbar');
    end
    function set.ToolBar(obj,value)
      obj.ToolBar = setproperty(obj,value,'toolbar');
    end
    
    function value = get.Type(obj)
      value = getproperty(obj,obj.Type,'type');
    end
    function set.Type(obj,value)
      obj.Type = setproperty(obj,value,'type');
    end
    
    function value = get.Units(obj)
      value = getproperty(obj,obj.Units,'units');
    end
    function set.Units(obj,value)
      obj.Units = setproperty(obj,value,'units');
    end
    
    function value = get.WindowButtonDownFcn(obj)
      value = getproperty(obj,obj.WindowButtonDownFcn,'windowbuttondownfcn');
    end
    function set.WindowButtonDownFcn(obj,value)
      obj.WindowButtonDownFcn = setproperty(obj,value,'windowbuttondownfcn');
    end
    
    function value = get.WindowButtonMotionFcn(obj)
      value = getproperty(obj,obj.WindowButtonMotionFcn,'windowbuttonmotionfcn');
    end
    function set.WindowButtonMotionFcn(obj,value)
      obj.WindowButtonMotionFcn = setproperty(obj,value,'windowbuttonmotionfcn');
    end
    
    function value = get.WindowButtonUpFcn(obj)
      value = getproperty(obj,obj.WindowButtonUpFcn,'windowbuttonupfcn');
    end
    function set.WindowButtonUpFcn(obj,value)
      obj.WindowButtonUpFcn = setproperty(obj,value,'windowbuttonupfcn');
    end
    
    function value = get.WindowKeyPressFcn(obj)
      value = getproperty(obj,obj.WindowKeyPressFcn,'windowkeypressfcn');
    end
    function set.WindowKeyPressFcn(obj,value)
      obj.WindowKeyPressFcn = setproperty(obj,value,'windowkeypressfcn');
    end
    
    function value = get.WindowKeyReleaseFcn(obj)
      value = getproperty(obj,obj.WindowKeyReleaseFcn,'windowkeyreleasefcn');
    end
    function set.WindowKeyReleaseFcn(obj,value)
      obj.WindowKeyReleaseFcn = setproperty(obj,value,'windowkeyreleasefcn');
    end
    
    function value = get.WindowScrollWheelFcn(obj)
      value = getproperty(obj,obj.WindowScrollWheelFcn,'windowscrollwheelfcn');
    end
    function set.WindowScrollWheelFcn(obj,value)
      obj.WindowScrollWheelFcn = setproperty(obj,value,'windowscrollwheelfcn');
    end
    
    function value = get.WindowStyle(obj)
      value = getproperty(obj,obj.WindowStyle,'windowstyle');
    end
    function set.WindowStyle(obj,value)
      obj.WindowStyle = setproperty(obj,value,'windowstyle');
    end
    
    function value = get.BeingDeleted(obj)
      value = getproperty(obj,obj.BeingDeleted,'beingdeleted');
    end
    function set.BeingDeleted(obj,value)
      obj.BeingDeleted = setproperty(obj,value,'beingdeleted');
    end
    
    function value = get.ButtonDownFcn(obj)
      value = getproperty(obj,obj.ButtonDownFcn,'buttondownfcn');
    end
    function set.ButtonDownFcn(obj,value)
      obj.ButtonDownFcn = setproperty(obj,value,'buttondownfcn');
    end
    
    function value = get.Children(obj)
      value = getproperty(obj,obj.Children,'children');
    end
    function set.Children(obj,value)
      obj.Children = setproperty(obj,value,'children');
    end
    
    function value = get.Clipping(obj)
      value = getproperty(obj,obj.Clipping,'clipping');
    end
    function set.Clipping(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Clipping');
      obj.Clipping = setproperty(obj,value,'clipping');
    end
    
    function value = get.CreateFcn(obj)
      value = getproperty(obj,obj.CreateFcn,'createfcn');
    end
    function set.CreateFcn(obj,value)
      obj.CreateFcn = setproperty(obj,value,'createfcn');
    end
    
    function value = get.DeleteFcn(obj)
      value = getproperty(obj,obj.DeleteFcn,'deletefcn');
    end
    function set.DeleteFcn(obj,value)
      obj.DeleteFcn = setproperty(obj,value,'deletefcn');
    end
    
    function value = get.BusyAction(obj)
      value = getproperty(obj,obj.BusyAction,'busyaction');
    end
    function set.BusyAction(obj,value)
      obj.BusyAction = setproperty(obj,value,'busyaction');
    end
    
    function value = get.HandleVisibility(obj)
      value = getproperty(obj,obj.HandleVisibility,'handlevisibility');
    end
    function set.HandleVisibility(obj,value)
      obj.HandleVisibility = setproperty(obj,value,'handlevisibility');
    end
    
    function value = get.HitTest(obj)
      value = getproperty(obj,obj.HitTest,'hittest');
    end
    function set.HitTest(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','HitTest');
      obj.HitTest = setproperty(obj,value,'hittest');
    end
    
    function value = get.Interruptible(obj)
      value = getproperty(obj,obj.Interruptible,'interruptible');
    end
    function set.Interruptible(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Interruptible');
      obj.Interruptible = setproperty(obj,value,'interruptible');
    end
    
    function value = get.Parent(obj)
      value = getproperty(obj,obj.Parent,'parent');
    end
    function set.Parent(obj,value)
      obj.Parent = setproperty(obj,value,'parent');
    end
    
    function value = get.Selected(obj)
      value = getproperty(obj,obj.Selected,'selected');
    end
    function set.Selected(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Selected');
      obj.Selected = setproperty(obj,value,'selected');
    end
    
    function value = get.SelectionHighlight(obj)
      value = getproperty(obj,obj.SelectionHighlight,'selectionhighlight');
    end
    function set.SelectionHighlight(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','SelectionHighlight');
      obj.SelectionHighlight = setproperty(obj,value,'selectionhighlight');
    end
    
    function value = get.Tag(obj)
      value = getproperty(obj,obj.Tag,'tag');
    end
    function set.Tag(obj,value)
      obj.Tag = setproperty(obj,value,'tag');
    end
    
    function value = get.UIContextMenu(obj)
      value = getproperty(obj,obj.UIContextMenu,'uicontextmenu');
    end
    function set.UIContextMenu(obj,value)
      obj.UIContextMenu = setproperty(obj,value,'uicontextmenu');
    end
    
    function value = get.UserData(obj)
      value = getproperty(obj,obj.UserData,'userdata');
    end
    function set.UserData(obj,value)
      obj.UserData = setproperty(obj,value,'userdata');
    end
    
    function value = get.Visible(obj)
      value = getproperty(obj,obj.Visible,'visible');
    end
    function set.Visible(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Visible');
      obj.Visible = setproperty(obj,value,'visible');
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function addcomponent(hParent, hChildren)
      %ADDCOMPONENT Add a component to the container
      %   ADDCOMPONENT(hPARENT, hCHILDREN) Add the objects hCHILDREN to be
      %   children of the sigcontainer hPARENT.
      
      narginchk(2,2);
      
      hChildren = hChildren(:)';
      
      for hindx = hChildren
        if ~isa(hindx, 'siggui.sigguiMCOS')
          warning(message('signal:sigcontainer:ChildMustBeSiggui'));
        else
          hParent.SigguiComponents = [hParent.SigguiComponents, hChildren];
        end
      end
      
      % Call a separate method to add the listener to the notification event.
      % This will allow subclasses to overload this method.
      attachnotificationlistener(hParent);
      
    end
    
    
    function h = addmenu(hObj, varargin)
      %ADDMENU Add a menu to figure.
      
      h = addmenu(hObj.FigureHandle, varargin{:});
      
    end
    
    
    function h = allchild(hObj)
      %ALLCHILD Returns all the children of the figure
      
      h = getChildren(hObj.FigureHandle);
      
    end
    
    
    function close(hObj, varargin)
      %CLOSE Close the figure
      
      close(hObj.FigureHandle, varargin{:});
      
    end
    
    function disp(hObj)
      %DISP Display the figure handle
      
      disp(hObj.FigureHandle);
      
    end
    
    
    function hFig = double(this)
      %DOUBLE   Return the figure handle.
      
      hFig = this.FigureHandle;
      
    end
    
    
    function figure(hObj, varargin)
      %FIGURE Bring figure forward.
      
      figure(hObj.FigureHandle, varargin{:});
      
    end
    
    
    function h = findobj(hObj, varargin)
      %FINDOBJ Find objects with specified property values.
      
      h = findobj(hObj.FigureHandle, varargin{:});
      
    end
    
    
    function out = getappdata(hObj, varargin)
      %GETAPPDATA Returns the application data specified
      
      out = getappdata(hObj.FigureHandle, varargin{:});
      
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
        if ~rem(length(varargin),2)
          error(message('signal:sigtools:sigfig:getcomponent:SigErrNotEnoughInputs'))
        else
          varargin = {tag, varargin{:}};
        end
      elseif nargin > 1
        varargin = {'Tag', tag};
      end
      
      hChild = hParent.SigguiComponents;
      
      if ~isempty(hChild)
        hChild = findobj(hChild, '-depth', 1, varargin{:});
      end
      
      
    end
    
    
    function out = getprop(hObj, prop, out)
      %GETFCN Get the property from the contained figure
      
      hFig = hObj.FigureHandle;
      
      if ~isempty(hFig) && ishghandle(hFig, 'figure')
        out = get(hFig, prop);
      end
      
    end
    
    
    function b = isappdata(hObj, varargin)
      %ISAPPDATA Returns true if the application data exists
      
      b = isappdata(hObj.FigureHandle, varargin{:});
      
    end
    
    
    function print(hObj, varargin)
      %PRINT Print the contained figure
      
      print(hObj.FigureHandle, varargin{:});
      
    end
    
    
    function printdlg(hObj, varargin)
      %PRINTDLG  Print dialog box.
      
      printdlg(varargin{:}, hObj.FigureHandle);
      
    end
    
    
    function printpreview(hObj)
      %PRINTPREVIEW  Display preview of figure to be printed
      
      printpreview(hObj.FigureHandle);
      
    end
    
    
    function rmappdata(hObj, varargin)
      %RMAPPDATA Remove the application data
      
      rmappdata(hObj.FigureHandle, varargin{:});
      
    end
    
    
    function rmcomponent(hParent, hChild)
      %RMCOMPONENT Remove a component
      
      hAllChildren = hParent.SigguiComponents;
      
      hParent.SigguiComponents = setdiff(hAllChildren, hChild);
      
    end
    
    
    function setappdata(hObj, varargin)
      %SETAPPDATA Saves the application data specified
      
      setappdata(hObj.FigureHandle, varargin{:});
      
    end
    
    
    function out = setintegerhandle(hObj, out)
      %SETINTEGERHANDLE Set the integer handle of the contained figure
      
      hFig = get(hObj, 'FigureHandle');
      
      if ~isempty(hFig) && ishghandle(hFig,'figure')
        
        % Convert the figure to a handle so that when we change the
        % IntegerHandle to off we know we will not lose track of it.
        hFig = handle(hFig);
        set(hFig, 'IntegerHandle', out);
        hObj.FigureHandle = double(hFig);
      end
      
      
    end
    
    
    function out = setprop(hObj, prop, out)
      %SETFCN Set the property in the contained figure
      
      hFig = hObj.FigureHandle;
      
      if ~isempty(hFig) && ishghandle(hFig, 'figure')
        set(hFig, prop, out);
      end
      
    end
    
    
    function sigfig_construct(this, varargin)
      %SIGFIG_CONSTRUCT Create the contained figure
      
      hFig = figure(varargin{:});
      
      this.FigureHandle = hFig;
      
      addlistener(hFig, 'ObjectBeingDestroyed', @(h, ev) lclfbd_listener(this));
      this.ObjectBeingDestroyedListener = ...
        event.listener(this, 'ObjectBeingDestroyed', @(h, ev) lclobd_listener(hFig));
      
    end
    
    function varargout = set(obj,varargin)
      
      [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});
      
      
    end
    
    function values = getAllowedStringValues(~,prop)
      % This function gives the the valid string values for object properties.
      
      switch prop
        case 'Analysis'
          values = {'magnitude','phase','freq','grpdelay',...
            'phasedelay','impulse','step','polezero',...
            'coefficients','info','magestimate','noisepower'};
          
        case 'FrequencyRange'
          values = {'[0, pi)','[0, 2pi)','[-pi, pi)',...
            'Specify freq. vector'};
          
        case 'FrequencyScale'
          values = {'Linear','Log'};
          
        case 'MagnitudeDisplay'
          values = {'Magnitude','Magnitude (dB)',...
            'Magnitude squared','Zero-phase'};
          
        case 'PhaseUnits'
          values = {'Degrees','Radians'};
          
        case 'PhaseDisplay'
          values = {'Phase','Continuous Phase'};
          
        case 'GroupDelayUnits'
          values = {'Samples','Time'};
          
        case 'PlotType'
          values = {'Line with Marker','Stem','Line'};
          
        case 'SpecifyLength'
          values = {'Default','Specified'};
          
        case 'CoefficientDisplay'
          values = {'Decimal','Hexadecimal','Binary'};
          
        otherwise
          values = {};
      end
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function attachnotificationlistener(hParent)
      %ATTACHNOTIFICATIONLISTENER
      
      hAllChildren = hParent.SigguiComponents;
      
      % Add a listener to a local function.  Creating function handles for
      % external MATLAB files is very slow.  Local functions is much faster.
      hListener = event.listener(hAllChildren, 'Notification', @(s,e)lclnotification_listener(hParent,e));
      
      hParent.NotificationListener = hListener;
      
    end
    
    function cleanup(this) %#ok<MANU>
      %CLEANUP
      
      % NO OP
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function prop = setproperty(this, prop, propname)

setprop(this, propname, prop);
end  % setproperty


% -------------------------------------------------------------------
function prop = getproperty(this, prop, propname)

prop = getprop(this, propname, prop);
end  % getproperty

% -----------------------------------------------------------
function lclnotification_listener(hObj, eventData, varargin)

notification_listener(hObj, eventData, varargin{:});

end


%-------------------------------------------------------------------
function lclfbd_listener(this)
%Local Figure Being Deleted Listener

cleanup(this);
delete(this);

end

%-------------------------------------------------------------------
function lclobd_listener(hFig)
%Local Object Being Deleted Listener

delete(hFig);

end
