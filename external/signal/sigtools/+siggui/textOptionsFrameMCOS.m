classdef textOptionsFrameMCOS < siggui.abstractoptionsframeMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.textOptionsFrame class
  %   siggui.textOptionsFrame extends siggui.abstractoptionsframe.
  %
  %    siggui.textOptionsFrame properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Name - Property is of type 'string'
  %       Text - Property is of type 'string vector'
  %
  %    siggui.textOptionsFrame methods:
  %       construct_tOF -  handle inputs and defaults for the textOptionsFrame here
  %       text_listener -  Listen to the text property of the object and update the UI as necessary
  %       thisrender -  Renders the text frame with the default values.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %TEXT Property is of type 'string vector'
    Text = { '', getString( message( 'signal:sigtools:siggui:NoOptionalParameter' ) ) };
  end
  
  
  methods  % constructor block
    function h = textOptionsFrameMCOS(varargin)
      %TESTOPTIONSFRAME  constructor for the TEXTOPTIONSFRAME
      %   H = TEXTOPTIONSFRAME(TEXT, NAME)
      %   TEXT    -   The text to set as a default
      %   NAME    -   The name for the
      
      %   Author(s): Z. Mecklai
      
      % Since the construcotr needs to be callable from sub-classes, actual constructor code is in another methods
      % however builtin constructor is called here
      % h = siggui.textOptionsFrame;
      
      % Inputs handled in duplicated constructor
      construct_tOF(h, varargin{:});
      
      
    end  % textOptionsFrame
    
    function set.Text(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.Text = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    
    function construct_tOF(h, varargin)
      %CONSTRUCT_TOF  handle inputs and defaults for the textOptionsFrame here
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      if nargin > 1
        h.Text = varargin{1};
      end % Set the Text property
      
      if nargin > 2
        h.Name = varargin{2};
      end % Set the Name property
      
      % Set the tag using the siggui inherited method
      settag(h);
      
    end
    
    function text_listener(h, eventData)
      %TEXT_LISTENER  Listen to the text property of the object and update the UI as necessary
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % Get the text to be set and set it to the ui
      Text = get(h, 'Text');
      handles = get(h, 'Handles');
      set(handles.text,'String',Text);
      
    end
    
    function thisrender(this, varargin)
      %THISRENDER  Renders the text frame with the default values.
      %   THISRENDER(H, HFIG, POS)
      %   H       -   Handle to object
      %   HFIG    -   Handle to parent figure
      %   POS     -   Position of frame
      %   Since the textOptionsFrame may be a superclass, it's render method
      %   must be callable from subclasses hence all the code necessary to
      %   actually render the frame is moved to another method
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % Render the container frame and return values needed for every render method
      renderabstractframe(this, varargin{:});
      
      h    = get(this, 'Handles');
      hFig = get(this, 'FigureHandle');
      sz   = gui_sizes(this);
      
      framePos = get(h.framewlabel(1), 'Position');
      
      % Calculate the position of the text.
      pos(1) = framePos(1) + sz.hfus;
      pos(2) = framePos(2) + sz.vfus;
      pos(3) = framePos(1) + framePos(3) - pos(1) - sz.hfus;
      pos(4) = framePos(2) + framePos(4) - 2*sz.vfus - pos(2);
      
      h.text = uicontrol('Style','Text',...
        'HorizontalAlignment','left',...
        'String',get(this,'Text'),...
        'BackgroundColor',get(0,'DefaultUicontrolBackgroundColor'),...
        'Enable','on',...
        'Visible','off',...
        'Units','pixels',...
        'Position',pos,...
        'Parent',hFig);
      
      % Install text listener
      listener(1) = event.proplistener(this, this.findprop('Text'),...
        'PostSet',@(s,e)text_listener(this));
      
      % Store the listener
      set(this, 'WhenRenderedListeners',listener);
      set(this, 'Handles', h);
      
    end
    
  end  %% public methods
  
end  % classdef

