classdef SignalBrowserCfg < matlabshared.scopes.ScopeSpecification
  %

  %   Copyright 2012-2019 The MathWorks, Inc.
  
  properties
    Application = [];
    ToggleLegendButton
    PlayAudioButton
    ToggleLegendMenu
    PlayAudioMenu
  end
  
  properties (Access = private)
    AudioPlayer = [];
    DisplayListener = [];
  end
  
  methods
    
    function this = SignalBrowserCfg(varargin)
      this@matlabshared.scopes.ScopeSpecification(varargin{:});
    end
    
    % -----------------------------------------------------------------
    function [success, errMessage] = checkMeasurementLicense(~, ~)
        [success, errMessage] = license('checkout','Signal_Toolbox');
    end
    
    % -----------------------------------------------------------------
    function b = showKeyboardCommand(~)
        b = false;
    end
    
    % -----------------------------------------------------------------
    function b = showBringAllForward(~)
        b = false;
    end
    
    % -----------------------------------------------------------------
    function b = showCloseAll(~)
        b = false;
    end
    
    % -----------------------------------------------------------------
    function b = shouldShowStatusBar(~)
        b = false;
    end
    
    % -----------------------------------------------------------------
    function b = shouldShowPlaybackToolbar(~)
        b = false;
    end
    
    % -----------------------------------------------------------------
    function b = showNewAction(~)
        b = false;
    end
    
    % -----------------------------------------------------------------
    function b = showConfiguration(~)
      b = false;
    end
    
    % -----------------------------------------------------------------
    function b = showRecentSources(~)
      b = false;
    end
    
    % -----------------------------------------------------------------
    function b = showPlaybackCommandModes(~)
      b = false;
    end
    
    % -----------------------------------------------------------------
    function appName = getScopeTag(~)
        appName = 'Signal Browser';
    end
    
    % -----------------------------------------------------------------
    function appName = getScopeName(~)
      appName = getString(message('signal:sptoolgui:SignalBrowser'));
    end
    
    % -----------------------------------------------------------------    
    function scopeTitle = getScopeTitle(~, hScope)
    %getScopeTitle Returns the full string for the title of the scope.
      scopeTitle = getAppName(hScope);
    end               
    
    % -----------------------------------------------------------------
    function show = getInstanceNumberTitle(~)
      show = false;
    end
    
    % -----------------------------------------------------------------
    function crFcn = getCloseRequestFcn(~, hScope)
        crFcn = @(h, ev) closeBrowser(hScope);
    end
    
    % -----------------------------------------------------------------
    function cfgFile = getConfigurationFile(~)
      cfgFile = fullfile(matlabroot, 'toolbox','signal', ...
        'sptoolgui', '+sigbrowser','SignalBrowser.cfg');
    end
    
    % -----------------------------------------------------------------
    function helpArgs = getHelpArgs(~, ~)
      helpArgs = {};
    end
    
    % -----------------------------------------------------------------
    function hiddenExts = getHiddenExtensions(~)
      hiddenExts = {};
    end
    
    % -----------------------------------------------------------------
    function measurementTags = getSupportedMeasurements(~)
      measurementTags = {'tcursors','signalstats','peaks','bilevel'};
    end
    
    % -----------------------------------------------------------------
    function show = getShowWaitbar(~)
      show = false;
    end
        
    %-----------------------------------------------------------------
    function flag = isSerializable(~)
      flag = false;
    end
    
    function flag = isVisibleAtLaunch(~)
      flag = false;
    end
         
    function ica = getIgnoreCloseAll(~)
      ica = 1;
    end
    
    %-----------------------------------------------------------------
    function hInstall = createGUI(this, ~)      
      % When called, the menu that governs the status bar
      % should appear in the correct order.

      bToggleLegend = uimgr.uitoggletool('ToggleLegend');
      bToggleLegend.IconAppData = 'toggle_legend';
      bToggleLegend.setWidgetPropertyDefault(...
        'TooltipString', getString(message('signal:sigbrowse:TTToggleLegend')), ...
        'State', 'on', ...
        'ClickedCallback', @(hcbo,~) toggleLegendsCallback(this, hcbo));
      
      mToggleLegend = uimgr.spctogglemenu('ToggleLegend', 1, ...
        getString(message('signal:sigbrowse:MIToggleLegend')));
        mToggleLegend.setWidgetPropertyDefault(...
          'Callback', @(hcbo,~) toggleLegendsCallback(this, hcbo));
      
      mToggleLegend.Placement = -10;
      sync2way(bToggleLegend, mToggleLegend);
                  
      bPlayAudio = uimgr.uitoggletool('PlayAudio');
      bPlayAudio.IconAppData = lower('PlayAudio');
      bPlayAudio.setWidgetPropertyDefault(...
        'TooltipString', getString(message('signal:sigbrowse:TTPlayAudio')), ...
        'ClickedCallback', @(hcbo, ~) audioPlayerCallback(this, hcbo));
      mPlayAudio = uimgr.spctogglemenu('PlayAudio', ...
        getString(message('signal:sigbrowse:MIPlayAudio')));
        mPlayAudio.setWidgetPropertyDefault(...
          'Callback', @(hcbo,~) audioPlayerCallback(this, hcbo));

      sync2way(bPlayAudio, mPlayAudio);
      
      hSigbrowseBtnGroup = uimgr.uibuttongroup( ...
        'SigbrowseGroup', 300, bPlayAudio, bToggleLegend);
      
      % Create installer
      plan = {mToggleLegend,      'Base/Menus/View'
              mPlayAudio,         'Base/Menus/Tools'
              hSigbrowseBtnGroup, 'Base/Toolbars/Main'};

      hInstall = uimgr.Installer(plan);
    end
    
    function renderMenus(this,unifiedScope)
        this.ToggleLegendMenu = spcwidgets.ToggleMenu(unifiedScope.Handles.viewMenu,...
            'Tag','uimgr.spctogglemenu_ToggleLegend',...
            'Label',getString(message('signal:sigbrowse:MIToggleLegend')),...
            'Enable', this.ToggleLegendButton.Enable,...
            'Checked', this.ToggleLegendButton.State, ...            
            'Callback', @(hcbo,~) toggleLegendsCallback(this, hcbo));        
        this.PlayAudioMenu = spcwidgets.ToggleMenu(unifiedScope.Handles.toolsMenu,...
            'Tag','uimgr.spctogglemenu_PlayAudio',...
            'Label',getString(message('signal:sigbrowse:MIPlayAudio')),...
            'Enable', this.PlayAudioButton.Enable,...
            'Checked', this.PlayAudioButton.State, ...
            'Callback', @(hcbo,~) audioPlayerCallback(this, hcbo));
    end
    
    function renderToolbars(this,unifiedScope)
        %RENDERTOOLBARS Render the toolbars and toolbar buttons
        
        %   Copyright 2019 The MathWorks, Inc.        
        hToolbar = unifiedScope.Handles.mainToolbar;
        
        this.ToggleLegendButton = uitoggletool(hToolbar,...
            'Tag','uimgr.uitoggletool_ToggleLegend',...
            'CData',getIcon(unifiedScope,'toggle_legend'),...
            'TooltipString', getString(message('signal:sigbrowse:TTToggleLegend')), ...
            'State', 'on', ...
            'Separator', 'on', ...
            'ClickedCallback', @(hcbo,~) toggleLegendsCallback(this, hcbo));
        this.PlayAudioButton = uitoggletool(hToolbar,...
            'Tag','uimgr.uitoggletool_PlayAudio',...
            'CData',getIcon(unifiedScope,lower('PlayAudio')),...
            'TooltipString', getString(message('signal:sigbrowse:TTPlayAudio')), ...            
            'ClickedCallback', @(hcbo,~) audioPlayerCallback(this, hcbo));
    end
        
    function [mApp, mExample, mAbout] = createHelpMenuItems(~, mHelp)
      mapFileLocation = fullfile(docroot,'toolbox','signal','signal.map');
      
      mApp(1) = uimenu(mHelp, ...
        'Tag', 'uimgr.uimenu_SigBrowserHelp', ...
        'Label', getString(message('signal:sptoolgui:SignalBrowserHelp')), ...
        'Callback', @(hco,ev) helpview(mapFileLocation,'signalbrowser'));
      
      mApp(2) = uimenu(mHelp, ...
        'Tag', 'uimgr.uimenu_SPToolboxHelp', ...
        'Label', getString(message('signal:sptoolgui:SignalProcessingToolboxHelp')), ...
        'Callback', @(hco,ev) eval('doc signal'));
        
      mExample = uimenu(mHelp, ...
        'Tag', 'uimgr.uimenu_HelpDemos', ...
        'Label', getString(message('signal:sptoolgui:Examples')), ...
        'Callback', @(hco,ev) eval('demo toolbox signal'));

      mAbout = uimenu(mHelp, ...
        'Tag', 'uimgr.uimenu_AboutSPT', ...
        'Label', getString(message('signal:sptoolgui:AboutSignalProcessingToolbox')), ...
        'Callback', @(hco,ev) aboutsignaltbx);
  end
    %-----------------------------------------------------------------
    function setDisplayCallback(this, callback)
      if ~isempty(callback)
        this.DisplayListener = uiservices.addlistener( ...
          this.Application.Visual, 'DisplayUpdated', callback);
      else
        l = this.DisplayListener;
        delete(l(ishandle(l)));
        this.DisplayListener = [];
      end
    end
  end
  methods (Hidden)
    function b = useMCOSExtMgr(~)
        b = true;
    end
  end
end

%---------------------------------------------------------------------
function toggleLegendsCallback(this, hcbo)
% Callback for toggling legend
  state = get(hcbo,getHcboProp(hcbo));
  
  hVisual = this.Application.Visual;
  
  % make sure the properties dialog can be properly updated.
  oldUpdateEnabled = hVisual.SelectedDisplayUpdateEnabled; 
  hVisual.SelectedDisplayUpdateEnabled = false; 
  hVisual.SelectedDisplayLegend = strcmp(state,'on'); 
  hVisual.SelectedDisplayUpdateEnabled = oldUpdateEnabled; 

  % now set each display manually  
  Displays = getAxesContainers(hVisual);
  for i = 1:numel(Displays)
    Displays{i}.LegendVisibility = state;
  end
end

function audioPlayerCallback(this, hcbo)
  prop = getHcboProp(hcbo);
  if strcmp(get(hcbo,prop),'off')
    if ~isempty(this.AudioPlayer)
      stop(this.AudioPlayer);
      this.AudioPlayer = [];
      turnOffProp(hcbo, prop);
    end
    return
  end

  mExt = this.Application.getExtInst('Tools', 'Measurements');
  [xData, yData] = getSelectedTraceVisibleData(mExt);

  if ~isempty(xData) && ~isempty(yData)
    Fs = 1 / mean(diff(xData));
    if numel(yData)>2
      try
        this.AudioPlayer = audioplayer(yData, Fs);
        playblocking(this.AudioPlayer);
        this.AudioPlayer = [];
        turnOffProp(hcbo, prop);
      catch ex
        uiscopes.errorHandler(ex.message, ...
          getString(message('signal:sigbrowse:PlaybackError')));
        turnOffProp(hcbo, prop);
      end        
    else
      turnOffProp(hcbo, prop);
    end
  end
end

function hcboProp = getHcboProp(hcbo)
  if isa(hcbo, 'spcwidgets.ToggleMenu')
    hcboProp = 'Checked';
  else
    hcboProp = 'State';
  end
end

function turnOffProp(hcbo, prop)
  if ishandle(hcbo) || isa(hcbo, 'spcwidgets.ToggleMenu') && isvalid(hcbo) && ishandle(hcbo.hmenu)
    set(hcbo,prop,'off')
  end
end

function closeBrowser(hScope)
  % stop any audio in-progress
  if ~isempty(hScope.ScopeCfg.AudioPlayer)
    stop(hScope.ScopeCfg.AudioPlayer);
    hScope.ScopeCfg.AudioPlayer = [];
  end
  
  % destroy any listeners
  l = hScope.ScopeCfg.DisplayListener;
  delete(l(ishandle(l)));
  hScope.ScopeCfg.DisplayListener = [];
  
  % close the scope
  close(hScope);
  
  % delete the parent first, then its framework.
  hParent = findall(0,'tag','SignalBrowser');
  if ~isempty(hParent) && ishghandle(hParent)
    hFramework = get(hParent,'UserData');
    delete(hParent(ishghandle(hParent)));
    delete(hFramework(isvalid(hFramework)));
  end
end

% [EOF]
