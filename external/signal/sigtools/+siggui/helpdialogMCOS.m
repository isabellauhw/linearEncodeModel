classdef helpdialogMCOS < siggui.dialogMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.helpdialog class
  %   siggui.helpdialog extends siggui.dialog.
  %
  %    siggui.helpdialog properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %
  %    siggui.helpdialog methods:
  %       dialog_gui_sizes - GUI Sizes and Spaces for the Help Dialog
  %       help - Perform the action of the Help Push Button
  %       helpdialog_cbs - DIALOG_CBS Callbacks for the dialog buttons
  %       render_buttons - Render the Dialog buttons (OK/Cancel/Apply)
  
  
  
  methods  % constructor block
    function hDlg = helpdialogMCOS
      %HELPDIALOG Construct a help dialog
      
      %   Author(s): J. Schickler
      
    end  % helpdialog
    
    function sz = dialog_gui_sizes(this)
      %DIALOG_GUI_SIZES GUI Sizes and Spaces for the Help Dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      % In R13 replace with:
      % super::gui_sizes(this);
      
      sz = gui_sizes(this);
      
      sz.minwidth  = 240*sz.pixf;
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
    
    
    function help(hDlg)
      %HELP Perform the action of the Help Push Button
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      warning(message('signal:siggui:helpdialog:help:GUIWarn'));
      helpdesk;      
      
    end
    
    
    function cbs = helpdialog_cbs(hDlg)
      %DIALOG_CBS Callbacks for the dialog buttons
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % This can be a private method
      
      % In R13 this function can be renamed dialog_cbs and replaced with:
      % cbs      = super::dialog_cbs(hDlg);
      % cbs.help = @help_cb;
      
      cbs      = dialog_cbs(hDlg);
      cbs.help = {cbs.method, hDlg, @help};
      
    end
    
    
    function render_buttons(hDlg)
      %RENDER_BUTTONS Render the Dialog buttons (OK/Cancel/Apply)
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % This can be a private method
      
      hFig = get(hDlg,'FigureHandle');
      sz   = gui_sizes(hDlg);
      h    = get(hDlg,'Handles');
      
      fsz = figuresize(hDlg);
      
      enabState = get(hDlg, 'Enable');
      
      bgc   = get(0,'DefaultUicontrolBackgroundColor');
      
      ctrlStrs = {getString(message('signal:sigtools:siggui:Apply')),getString(message('signal:sigtools:siggui:Cancel')),getString(message('signal:sigtools:siggui:OK')), getString(message('signal:sigtools:siggui:Help'))};
      numbtns = 4;
      uiWidth = largestuiwidth(ctrlStrs,'Pushbutton')+10*sz.pixf;
      
      spacing = sz.uuhs;
      
      okXPos     = fsz(1)/2-uiWidth*numbtns/2 - spacing*(numbtns-1)/2;
      cancelXPos = okXPos + uiWidth + spacing;
      helpXPos   = cancelXPos + uiWidth + spacing;
      applyXPos  = helpXPos + uiWidth + spacing;
      
      applyPbPos = [applyXPos 2*sz.vfus uiWidth sz.bh];
      cancelPbPos = [cancelXPos 2*sz.vfus uiWidth sz.bh];
      helpPos = [helpXPos 2*sz.vfus uiWidth sz.bh];
      
      % OK button Position
      okPbPos = [okXPos 2*sz.vfus uiWidth sz.bh];
      
      cbs = helpdialog_cbs(hDlg);
      
      % Render the "OK" pushbutton
      h.ok = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position',okPbPos,...
        'Visible','On',...
        'Enable',enabState,...
        'String',ctrlStrs{3},...
        'Tag','dialog_ok',...
        'Callback',cbs.ok);
      
      % Render the "Cancel" pushbutton
      h.cancel = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position',cancelPbPos,...
        'Visible','On',...
        'Enable',enabState,...
        'String',ctrlStrs{2},...
        'Tag','dialog_cancel',...
        'Callback',cbs.cancel);
      
      h.help = uicontrol(hFig, ...
        'Style','Push', ...
        'BackgroundColor', bgc, ...
        'Position', helpPos, ...
        'Visible', 'On', ...
        'Enable', enabState, ...
        'String', ctrlStrs{4}, ...
        'Tag','dialog_help', ...
        'Callback', cbs.help);
      
      % Render the "Apply" pushbutton
      h.apply = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position',applyPbPos,...
        'Visible','On',...
        'Enable',enabState,...
        'String',ctrlStrs{1},...
        'Tag','dialog_apply',...
        'Interruptible','off',...
        'Callback',cbs.apply);
      
      h.warn = [];
      
      hDlg.DialogHandles = h;
      
    end
    
  end  %% public methods
  
end  % classdef

