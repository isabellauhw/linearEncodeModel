classdef actionclosedlgMCOS < siggui.helpdialogMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.actionclosedlg class
  %   siggui.actionclosedlg extends siggui.helpdialog.
  %
  %    siggui.actionclosedlg properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %
  %    siggui.actionclosedlg methods:
  %       cancel -   Close down the dialog with no unwind.
  %       dialog_gui_sizes -   Special case the minwidth.
  %       enable_listener -   Listener to 'enable'.
  %       getactionlabel -   Get the actionlabel.
  %       hashelp -   Returns true.
  %       isapplied_listener -   Listener to 'isapplied'.
  
  
  
  methods  %% public methods
    function cancel(this)
      %CANCEL   Close down the dialog with no unwind.
      
      % Hide the dialog, but not through the object.  This avoids the transaction
      % finding the change, but we do not see the "cancel" operation
      if isrendered(this), set(this,'Visible','Off'); end
      
      notify(this, 'DialogCancelled');
      
    end
    
    %----------------------------------------------------------------------
    function sz = dialog_gui_sizes(this)
      %DIALOG_GUI_SIZES   Special case the minwidth.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      sz = gui_sizes(this);
      
      if hashelp(this)
        sz.minwidth = 200*sz.pixf;
      else
        sz.minwidth = 160*sz.pixf;
      end
      sz.minheight = 50 *sz.pixf;
      sz.button    = [0 2*sz.vfus 0 sz.bh];
      
      if isrendered(this) && ishghandle(this.FigureHandle)
        y = sz.button(2)+sz.button(4)+sz.vfus;
        figpos = figuresize(this);
        sz.controls = [sz.hfus y figpos(1)-2*sz.hfus figpos(2)-y-sz.vfus];
      else
        sz.controls = [];
      end
      
    end
    
    %----------------------------------------------------------------------
    function enable_listener(this, varargin)
      %ENABLE_LISTENER   Listener to 'enable'.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      sigcontainer_enable_listener(this, varargin{:})
      
      hd = convert2vector(rmfield(this.DialogHandles, 'close'));
      
      set(hd, 'Enable', this.Enable);
      
    end
    
    
    function actionlabel = getactionlabel(this)
      %GETACTIONLABEL   Get the actionlabel.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      actionlabel = getString(message('signal:sigtools:siggui:Generate'));
      
    end
    
    %----------------------------------------------------------------------
    function b = hashelp(this)
      %HASHELP   Returns true.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      b = true;
    end
    
    %----------------------------------------------------------------------
    function isapplied_listener(this, eventData)
      %ISAPPLIED_LISTENER   Listener to 'isapplied'.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      % NO OP
    end
    
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function render_buttons(this)
      %RENDER_BUTTONS
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      hFig = get(this,'FigureHandle');
      sz   = dialog_gui_sizes(this);
      
      fsz  = figuresize(this);
      bgc  = get(0,'DefaultUicontrolBackgroundColor');
      
      enabState = get(this, 'Enable');
      
      ctrlStrs = {sprintf(getactionlabel(this)),getString(message('signal:sigtools:siggui:Close'))};
      if hashelp(this)
        ctrlStrs{end+1} = getString(message('signal:sigtools:siggui:Help'));
      end
      numbtns = length(ctrlStrs);
      uiWidth = largestuiwidth(ctrlStrs,'Pushbutton')+10*sz.pixf;
      
      spacing = sz.uuhs*2;
      
      helpx   = fsz(1)-10*sz.pixf-uiWidth;
      if hashelp(this)
        closex = helpx -10*sz.pixf-uiWidth;
      else
        closex = helpx;
      end
      actionx = closex-10*sz.pixf-uiWidth;
      
      buttonPos = sz.button;
      
      buttonPos([1,3]) = [actionx uiWidth];
      
      % NOTE: The converttdlg_cbs function updates the figure's userdata
      cbs = helpdialog_cbs(this);
      
      % Render the "OK" pushbutton
      h.action = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position',buttonPos,...
        'Visible','On',...
        'Enable',enabState, ...
        'String',ctrlStrs{1}, ...
        'Tag','dialog_ok', ...
        'Callback',cbs.apply);
      
      buttonPos(1) = closex;
      
      % Render the "Cancel" pushbutton
      h.close = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position',buttonPos,...
        'Visible','On',...
        'Enable',enabState,...
        'String',ctrlStrs{2},...
        'Tag','dialog_cancel',...
        'Callback',cbs.cancel);
      
      if hashelp(this)
        
        buttonPos(1) = helpx;
        
        % Render the "Apply" pushbutton
        h.help = uicontrol(hFig,...
          'Style','Push',...
          'BackgroundColor',bgc,...
          'Position',buttonPos,...
          'Visible','On',...
          'Enable',enabState,...
          'String',ctrlStrs{3},...
          'Tag','dialog_apply',...
          'Callback',cbs.help);
      end
      
      h.warn = [];
      
      this.DialogHandles = h;
      
    end
    
    
    %----------------------------------------------------------------------
    function resetoperations(this)
      %RESETOPERATIONS
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      % NO OP.  This dialog does not have a cancel.
    end
    
    
  end  %% possibly private or hidden
  
end  % classdef

