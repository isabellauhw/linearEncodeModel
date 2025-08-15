classdef dialogMCOS < siggui.sigcontainerMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.dialog class
  %   siggui.dialog extends siggui.sigcontainer.
  %
  %    siggui.dialog properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %
  %    siggui.dialog methods:
  %       action - The action for the dialog
  %       apply - The apply action for the dialog
  %       cancel - The cancel action of the Dialog
  %       centerdlgonfig - Center Dialog on top of figure.
  %       close - Close the dialog figure
  %       deletewarnings - Delete warnings for the dialog
  %       destroy - Delete the dialog object
  %       dialog_cbs - Callbacks for the dialog buttons
  %       dialog_enable_listener - Listener to the Enable property
  %       dialog_gui_sizes - Sizes and spacing for dialogs
  %       dialog_resetoperations - RESETOPERATIONS Create a transaction incase of a cancel.
  %       enable_listener - Listener to the Enable property
  %       installdialoglisteners - Installs the listener on the isApplied property
  %       isapplied_listener - Listener to the isApplied property
  %       ok - The OK action for the Dialog
  %       render_buttons - Render the Dialog buttons (OK/Cancel/Apply)
  %       render_controls - Renders the Subclass specifc controls
  %       resetoperations - Create a transaction incase of a cancel.
  %       setup_figure - Setup a default dialog.  This method must be overloaded.
  %       thisrender - RENDER The Render method for the Dialog
  %       thisunrender - Unrender the dialog
  %       visible_listener - Listener to the Visible property
  %       warning - Manager for dialog warnings
  
  
  properties (Access=protected, AbortSet)
    %OPERATIONS Property is of type 'handle vector'
    Operations = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %DIALOGHANDLES Property is of type 'MATLAB array'
    DialogHandles = [];
    %ISAPPLIED Property is of type 'bool'
    isApplied
    %WINDOWSTYLE Property is of type 'sigguiDialogWindowStyle enumeration: {'Normal','Modal'}'
    WindowStyle = 'Normal';
  end
  
  
  events
    DialogBeingApplied
    DialogApplied
    DialogCancelled
  end  % events
  
  methods  % constructor block
    function hDlg = dialogMCOS(hFig)
      %DIALOG Constructor for the dialog object
      
      %   Author(s): J. Schickler
      
      if nargin < 1, hFig = -1; end
      
    end  % dialog
    
    function set.isApplied(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'numeric','logical'}, {'scalar'},'','isApplied')
      obj.isApplied = value;
    end
    
    function set.Operations(obj,value)
      % DataType = 'handle vector'
      if ~isempty(value)
        validateattributes(value,{'handle'}, {'vector'},'','Operations')
      end
      obj.Operations = value;
    end
    
    function set.WindowStyle(obj,value)
      % Enumerated DataType = 'sigguiDialogWindowStyle enumeration: {'Normal','Modal'}'
      value = validatestring(value,{'Normal','Modal'},'','WindowStyle');
      obj.WindowStyle = value;
    end
    
    function success = action(hDlg)
      %ACTION The action for the dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      success = true;
      
    end
    
    
    function varargout = apply(hDlg)
      %APPLY The apply action for the dialog
      
      %   Copyright 1988-2012 The MathWorks, Inc.
      
      notify(hDlg, 'DialogBeingApplied');
      
      % Perform the action specified by the Sub-class
      try
        
        success = action(hDlg);
      catch ME
        
        % If the action failed don't close the dialog.  Clean up the message to
        % work around udd/mexception issue.
        
        throwAsCaller(MException(ME.identifier, cleanerrormsg(ME.message)));
      end
      
      if isrendered(hDlg) && strcmpi(hDlg.Visible, 'on')
        figure(hDlg.FigureHandle);
      end
      
      % Set the isApplied flag to 1, if AutoClose is 1.  If autoClose is 0 the figure
      % will not close because of an error so we do not want the applied flag to be 1.
      if success
        hDlg.isApplied = 1;
        resetoperations(hDlg);
        notify(hDlg, 'DialogApplied');
      end
      
      if nargout
        varargout = {success};
      end
      
    end
    
    
    function cancel(this)
      %CANCEL The cancel action of the Dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % Hide the dialog, but not through the object.  This avoids the transaction
      % finding the change, but we do not see the "cancel" operation
      if isrendered(this), set(this,'Visible','Off'); end
      
      % If the Dialog controls have not been applied, reset them
      if ~this.isApplied
        
        %     setstate(this, getappdata(this.FigureHandle, 'PreviousState'));
        
        % Undo all the transactions
        cancel(this.Operations);
      end
      
      % Create a new transaction for the next time the dialog is opened
      resetoperations(this);
      
      notify(this, 'DialogCancelled');
      
    end
    
    
    function centerdlgonfig(hDlg, h)
      % CENTERDLGONFIG Center Dialog on top of figure.
      %
      % Inputs:
      %   hFig - Handle to the Filter Design GUI figure.
      %   hmsg - Handle to the figure to be centered on hFig.
      
      %   Author(s): P. Costa & J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      if ~isrendered(hDlg), return; end
      
      if isa(h,'siggui.siggui') || isa(h,'siggui.sigguiMCOS')
        if isrendered(h)
          h = get(h,'FigureHandle');
        else
          movegui(hDlg.FigureHandle, 'center');
          return;
        end
      end
      
      hFig = get(hDlg,'FigureHandle');
      
      % If the parent window is docked, we need to get the position of the MDI
      % not the figure.
      if strcmpi(get(h, 'WindowStyle'), 'docked')
        
        % Suppress the JavaFrame warning.
        [lastWarnMsg, lastWarnId] = lastwarn;
        oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        
        MDIName = getGroupName(matlab.ui.internal.JavaMigrationTools.suppressedJavaFrame(h));
        
        import com.mathworks.mlservices.*;
        
        % Get the handle to the parent MDI.
        hMDI = MatlabDesktopServices.getDesktop.getGroupContainer(MDIName);
        
        % Get the x and y position.
        xy = hMDI.getLocationOnScreen;
        
        % Get the height
        h      = hMDI.getHeight;
        screen = get(0, 'ScreenSize');
        
        % Restore the JavaFrame warning and lastwarn states.
        warning(oldstate);
        lastwarn(lastWarnMsg, lastWarnId);
        
        % Convert java Y to MATLAB Y position.  Java is from the top and
        % MATLAB is from the bottom.
        y = screen(4)-h-xy.y;
        
        figPos = [xy.x y hMDI.getWidth h];
        
      else
        set(h,'Units','pix');
        figPos = get(h,'Position');
        set(hFig,'Units','pix');
      end
      
      figCtr = [figPos(1)+figPos(3)/2 figPos(2)+figPos(4)/2];
      
      set(hFig,'Units','pix');
      msgPos = get(hFig,'Position');
      msgCtr = [msgPos(1)+msgPos(3)/2 msgPos(2)+msgPos(4)/2];
      
      movePos = figCtr - msgCtr;
      
      new_msgPos = msgPos;
      new_msgPos(1:2) = msgPos(1:2) + movePos;
      set(hFig,'Position',new_msgPos);
      
    end
    
    
    function close(hDlg)
      %CLOSE Close the dialog figure
      %   CLOSE(hDLG) Close the dialog figure.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      if isrendered(hDlg)
        
        hFig = get(hDlg, 'FigureHandle');
        
        if ishghandle(hFig)
          
          % Delete the transaction.
          delete(hDlg.Operations);
          
          hDlg.Operations = [];
          
          delete(hFig);
        end
      end
      
    end
    
    
    function deletewarnings(hDlg)
      %DELETEWARNINGS Delete warnings for the dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      % This should be a private method
      
      h = hDlg.DialogHandles;
      if isfield(h, 'warn')
        delete(h.warn(ishghandle(h.warn)));
      end
      h.warn = [];
      hDlg.DialogHandles = h;
      
    end
    
    
    function destroy(hDlg)
      %DESTROY Delete the dialog object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Close the GUI.  This sets off 'unrender'.
      close(hDlg);
      
      % Destroy the reset transaction & the dialog listeners
      delete(hDlg.Operations);
      
      % In R13, replace with:
      % super::destroy(hDlg);
      
      delete(hDlg);
      
    end
    
    
    
    function cbs = dialog_cbs(hDlg)
      %DIALOG_CBS Callbacks for the dialog buttons
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      cbs        = siggui_cbs(hDlg);
      cbs.ok     = {cbs.method, hDlg, 'ok'};
      cbs.cancel = {cbs.method, hDlg, 'cancel'};
      cbs.apply  = {cbs.method, hDlg, 'apply'};
      
    end
    
    
    function dialog_enable_listener(hDlg, varargin)
      %DIALOG_ENABLE_LISTENER Listener to the Enable property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      sigcontainer_enable_listener(hDlg, varargin{:});
      
      % Cancel is never disabled.
      % Apply is taken care of by isapplied_listener
      h = rmfield(hDlg.DialogHandles, {'cancel', 'apply'});
      
      setenableprop(convert2vector(h), hDlg.Enable);
      isapplied_listener(hDlg, varargin{:});
      
    end
    
    
    function sz = dialog_gui_sizes(this)
      %DIALOG_GUI_SIZES Sizes and spacing for dialogs
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      % In R13 replace with:
      % super::gui_sizes(this);
      
      sz = gui_sizes(this);
      
      sz.minwidth  = 205*sz.pixf;
      sz.minheight = 50 *sz.pixf;
      sz.button    = [0 2*sz.vfus 0 sz.bh];
      sz.spaceforbutton = sz.bh+4*sz.vfus;
      
      if isrendered(this) && ishghandle(this.FigureHandle)
        y = sz.button(2)+sz.button(4)+sz.vfus;
        figpos = figuresize(this);
        sz.controls = [sz.hfus y figpos(1)-2*sz.hfus figpos(2)-y-sz.vfus];
      else
        sz.controls = [];
      end
      
    end
    
    
    function dialog_resetoperations(hDlg, varargin)
      %RESETOPERATIONS Create a transaction incase of a cancel.
      %   RESETOPERATIONS(hDLG) Create a transaction incase of a cancel.  This
      %   transaction will track all changes to the object and undo them if the
      %   cancel button is selected.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % This can be private
      
      % setappdata(hDlg.FigureHandle, 'PreviousState', getstate(hDlg));
      
      % Delete the old transactions
      delete(hDlg.Operations);
      
      % Create the transaction, ignore the isApplied property
      hT(1) = sigdatatypes.transactionMCOS(hDlg, ...
        'isApplied', 'Enable', 'Visible', 'DialogHandles', varargin{:});
      
      hChildren = allchild(hDlg);
      
      for indx = 1:length(hChildren)
        hT(1+indx) = sigdatatypes.transactionMCOS(hChildren(indx));
      end
      
      hDlg.Operations = hT;
      
    end
    
    
    function enable_listener(hDlg, varargin)
      %ENABLE_LISTENER Listener to the Enable property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      dialog_enable_listener(hDlg, varargin{:});
      
    end
    
    
    function installdialoglisteners(hDlg)
      %INSTALLDIALOGLISTENERS Installs the listener on the isApplied property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      isApp = hDlg.findprop('isApplied');
      
      % Install the default listeners
      hListen = event.proplistener(hDlg, isApp, 'PostSet', @(s,e)isapplied_listener(hDlg));
      
      hDlg.DialogListeners = hListen;
      
    end
    
    
    function isapplied_listener(hDlg, eventData)
      %ISAPPLIED_LISTENER Listener to the isApplied property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      isApplied = hDlg.isApplied;
      h         = hDlg.DialogHandles;
      enabState = hDlg.Enable;
      
      % If the dialog has just been applied, reset the transaction and disable.
      % the Apply button
      if isApplied
        enabState = 'off';
      end
      
      set(h.apply,'Enable',enabState);
      
    end
    
    
    function ok(hDlg)
      %OK The OK action for the Dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % If the dialog is not applied, apply it.
      if (hDlg.isApplied)
        success = true;
      else
        success = apply(hDlg);
      end
      
      if success
        set(hDlg, 'Visible', 'Off');
      end
      
    end
    
    
    function render_buttons(hDlg)
      %RENDER_BUTTONS Render the Dialog buttons (OK/Cancel/Apply)
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % This can be a private method
      
      hFig = get(hDlg,'FigureHandle');
      sz   = dialog_gui_sizes(hDlg);
      
      fsz  = figuresize(hDlg);
      bgc  = get(0,'DefaultUicontrolBackgroundColor');
      
      enabState = get(hDlg, 'Enable');
      
      ctrlStrs = {getString(message('signal:sigtools:siggui:Apply')),getString(message('signal:sigtools:siggui:Cancel')),getString(message('signal:sigtools:siggui:OK'))};
      numbtns = 3;
      uiWidth = largestuiwidth(ctrlStrs,'Pushbutton')+10*sz.pixf;
      
      spacing = sz.uuhs*2;
      
      okXPos     = fsz(1)/2-uiWidth*numbtns/2 - spacing*(numbtns-1)/2;
      cancelXPos = okXPos + uiWidth + spacing;
      applyXPos  = cancelXPos + uiWidth + spacing;
      
      buttonPos = sz.button;
      
      buttonPos([1,3]) = [okXPos uiWidth];
      
      % NOTE: The converttdlg_cbs function updates the figure's userdata
      cbs = dialog_cbs(hDlg);
      
      % Render the "OK" pushbutton
      h.ok = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position',buttonPos,...
        'Visible','On',...
        'Enable',enabState, ...
        'String',ctrlStrs{3}, ...
        'Tag','dialog_ok', ...
        'Callback',cbs.ok);
      
      buttonPos(1) = cancelXPos;
      
      % Render the "Cancel" pushbutton
      h.cancel = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position',buttonPos,...
        'Visible','On',...
        'Enable',enabState,...
        'String',ctrlStrs{2},...
        'Tag','dialog_cancel',...
        'Callback',cbs.cancel);
      
      buttonPos(1) = applyXPos;
      
      % Render the "Apply" pushbutton
      h.apply = uicontrol(hFig,...
        'Style','Push',...
        'BackgroundColor',bgc,...
        'Position',buttonPos,...
        'Visible','On',...
        'Enable',enabState,...
        'String',ctrlStrs{1},...
        'Tag','dialog_apply',...
        'Callback',cbs.apply);
      
      h.warn = [];
      
      hDlg.DialogHandles = h;
      
    end
    
    
    function render_controls(hDlg)
      %RENDER_CONTROLS Renders the Subclass specifc controls
      %   RENDER_CONTROLS(hDLG) Renders the Subclass specific controls.  This
      %   function must be overloaded by the subclass.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % This can be a private method
      
      disp('The RENDER_CONTROLS method must be overloaded!');
      
    end
    
    
    function resetoperations(hDlg)
      %RESETOPERATIONS Create a transaction in case of a cancel.
      %   RESETOPERATIONS(hDLG) Create a transaction incase of a cancel.  This
      %   transaction will track all changes to the object and undo them if the
      %   cancel button is selected.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % This can be private
      
      dialog_resetoperations(hDlg);
      
    end
    
    
    function setup_figure(hDlg)
      %SETUP_FIGURE Setup a default dialog.  This method must be overloaded.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % This can be a private method
      
      disp('The SETUP_FIGURE method must be overloaded!');
      
      visState = get(hDlg, 'Visible');
      cbs      = dialog_cbs(hDlg);
      
      % Set up a default figure so that the RENDER method won't error,
      % but still tell the developer to create his own setup_figure
      hFig = figure('Position',[500 500 205 200], ...
        'MenuBar','None', ...
        'Resize','Off', ...
        'Visible',visState, ...
        'NumberTitle','Off', ...
        'Name','Dialog', ...
        'IntegerHandle','Off', ...
        'HandleVisibility', 'Off', ...
        'CloseRequestFcn',cbs.cancel);
      
      set(hDlg, 'FigureHandle', hFig);
      
    end
    
    function thisrender(this)
      %RENDER The Render method for the Dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      setup_figure(this);
      
      % Make sure that hFig falls within our minimum size limits
      checkfigure(this);
      
      render_buttons(this);
      
      % RENDER_CONTROLS must be overloaded
      render_controls(this);
      
      % Create the reset transaction
      resetoperations(this);
      
      attachlisteners(this);
      
    end
    
    
    
    function thisunrender(hDlg)
      %THISUNRENDER Unrender the dialog
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2008 The MathWorks, Inc.
      
      deletewarnings(hDlg);
      
      hFig = get(hDlg, 'FigureHandle');
      if ~isempty(hFig) && ishghandle(hFig)
        delete(hFig);
      end
      
    end
    
    function visible_listener(hDlg, eventStruct)
      %VISIBLE_LISTENER Listener to the Visible property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      visState = get(hDlg,'Visible');
      hFig     = get(hDlg,'FigureHandle');
      
      if strcmpi(visState, 'off')
        
        % If the dialog is becoming invisible, destroy the warnings
        deletewarnings(hDlg);
      end
      
      set(hFig,'Visible',visState);
      
      
    end
    
    
    function warning(hDlg, Title)
      %WARNING Manager for dialog warnings
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      if nargin == 1
        Title = 'Warning';
      end
      
      % Create a warning and save its handle to be deleted later
      h = get(hDlg, 'DialogHandles');
      h.warn(end+1) = warndlg(lastwarn, Title);
      hDlg.DialogHandles = h;
      
      
    end
    
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    
    function attachlisteners(this)
      %ATTACHLISTENERS
      
      % Install the default listeners
      l = [ ...
        this.WhenRenderedListeners(:); ...
        event.proplistener(this, this.findprop('isApplied'), ...
        'PostSet', @(s,e)isapplied_listener(this)); ...
        ];
      
      this.WhenRenderedListeners = l;
      
      isapplied_listener(this);
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef


function checkfigure(this)
%CHECKFIGURE Verify that the figure is acceptable for a dialog

hFig = get(this,'FigureHandle');

% Make sure that the figure matches the UDD object settings
set(hFig,'WindowStyle', this.WindowStyle);

sz = dialog_gui_sizes(this);

% Set the minimum limits
minWidth  = sz.minwidth;
minHeight = sz.minheight;

% Cache the old units and set them to pixels
origUnits = get(hFig,'Units');
set(hFig,'Units','Pixels');

% Get the old position
pos = get(hFig,'Position');

% Check if any of the positions are too small
if pos(3) < minWidth,  pos(3) = minWidth; end
if pos(4) < minHeight, pos(4) = minHeight; end

% Create the new position
set(hFig,'Position',pos);

% Restore the old units
set(hFig,'Units',origUnits);

end

