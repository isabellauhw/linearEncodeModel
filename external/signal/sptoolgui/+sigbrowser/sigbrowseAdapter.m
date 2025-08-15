function varargout = sigbrowseAdapter(varargin)
%

%   Copyright 2012-2019 The MathWorks, Inc.

if nargin<1 
    if isempty(findall(0,'tag','sptool'))
        disp(getString(message('signal:sptoolgui:TypesptoolToStartTheSignalGUI')))
    else
        disp(getString(message('signal:sptoolgui:ToUseTheSignalBrowserImportASignalIntoTheSPTool')))
    end
    return
end

if ~ischar(varargin{1})
  fprintf('%f\n',varargin{1});
  return
end

switch varargin{1}
  case 'selection'
    varargout{1} = doSelection(varargin{2:end});
    return
  case 'action'
    doAction()
  case 'setprefs'
    doPrefs(varargin{2:end})
    varargout{1} = '';
  case 'SPTclose'
    doClose()
  otherwise
    if ischar(varargin{1})
      warning(message('signal:sigbrowse:InvalidAction', varargin{1}));
    else
      warning(message('signal:sigbrowse:InvalidParam'));
    end
end

if strcmp(varargin{1},'selection')
end

function refreshSignalBrowser(createFlag)
hParent = findall(0,'tag','SignalBrowser');
if isempty(hParent)
  if ~createFlag
    return
  end
  h = sigbrowser.SignalBrowser;
  hApplication = h.Application;
else
  hApplication = get(hParent(1),'UserData');
end

% disable reporting visual changes.
setDisplayCallback(hApplication.ScopeCfg, []);

sptoolfig = findobj(0,'Tag','sptool');
if ~isempty(sptoolfig) && ishghandle(sptoolfig)
  sptoolSigs = sptool('Signals',0,sptoolfig);
else
  uiscopes.errorHandler( ...
    getString(message('signal:sptoolgui:TypesptoolToStartTheSignalGUI')), ...
    getString(message('signal:sptool:GUIErrSptoolNotOpen', 'SPTool')));
  return
end

% SPTool performs 'selection' 'view' 'value' on *every* client when any
% signal, filter, or spectra item is changed.  Exit if no changes happened
% to our signals

browserSigs = hApplication.DataSource.Signals;
if ~createFlag && ~isempty(browserSigs) && ...
   isequal({browserSigs.Name}, {sptoolSigs.label}) && ...
   isequal({browserSigs.Rate}, {sptoolSigs.Fs}) && ...
   isequal({browserSigs.Data}, {sptoolSigs.data})
  % nothing to show
  return
end

% reset each display to remove any previous lines
displays = getAxesContainers(hApplication.Visual);
for i=1:numel(displays)
  reset(displays{i});
  displays{i}.UserDefinedChannelNames = {};
end

% set the displays to the largest duration of each signal
t = max((cellfun(@(x) size(x,1), {sptoolSigs.data})) ./ ...
         cell2mat({sptoolSigs.Fs}));

if ~isempty(t)
  setPropertyValue(hApplication.Visual, 'TimeRangeSamples', num2str(t))
end

% install the signals
hApplication.DataSource.clearData;
for i=1:numel(sptoolSigs)
  hApplication.DataSource.addData(sptoolSigs(i).label, ...
                                  sptoolSigs(i).Fs, ...
                                  sptoolSigs(i).data);
end


installDataSource(hApplication, hApplication.DataSource);


% invoke autoscale to set upper/lower y limits of each display
hPlot = getExtInst(hApplication, 'Tools', 'Plot Navigation');
if numel(sptoolSigs) > 0
  performAutoscale(hPlot, false, true);
end

% turn on the legend if invoking for the first time.
if isempty(hParent)
  hApplication.Visual.SelectedDisplayLegend = true;
end

% copy over desired line styles
copySptoolStyleToBrowser(hApplication);

% inform the application that lines and colors have changed.
sendEvent(hApplication,'VisualChanged');

% configure to report back to sptool when visual changes.
setDisplayCallback(hApplication.ScopeCfg, ...
  @(src, evt) displayCallback(hApplication));

% turn on the visual
visible(hApplication,'on');

%------------------------------------------------------------------------
% enable = sigbrowse('selection',action,msg,SPTfig)
%  respond to selection change in SPTool
% possible actions are
%    'view'
%  msg - either 'value', 'label', 'Fs', 'dup', or 'clear'
%         'value' - only the listbox value has changed
%         'label' - one of the selected objects has changed it's name
%         'Fs' - one of the selected objects's .Fs field has changed
%         'dup' - a selected object was duplicated
%         'clear' - a selected object was cleared
%  Button is enabled when there is at least one signal selected

function enable = doSelection(~,~,SPTfig)
[~,ind] = sptool('Signals',1,SPTfig);
if isempty(ind)
  enable = 'off';
else
  enable = 'on';
end
refreshSignalBrowser(false);

%------------------------------------------------------------------------
% enable = sigbrowse('action',action,selection)
%  respond to button push in SPTool
% possible actions are
%    'view'

function doAction()
refreshSignalBrowser(true);

%------------------------------------------------------------------------
% errstr = sigbrowse('setprefs',panelName,p)
% Set preferences for the panel with name panelName
% Inputs:
%   panelName - string; must be either 'ruler','color', or 'sigbrowse'
%              (see sptprefreg for definitions)
%   p - preference structure for this panel

function doPrefs(panelName, p)
if strcmp(panelName,'sigbrowse') && p.legacyBrowserEnable
  doClose();
end

%------------------------------------------------------------------------
% sigbrowse('SPTclose',action)
% Signal Browser close request function
%   This function is called when a browser window is closed.
%  action will be:  'view'

function doClose()
hParent = findall(0,'tag','SignalBrowser');
if ~isempty(hParent)
  if ishghandle(hParent)
    close(hParent);
  end
  if ishghandle(hParent) 
    delete(hParent);
  end
end

%----------------------- local callbacks --------------------------------

function dpy = getVisibleAxesContainers(hVisual)
% GETVISIBLEAXESCONTAINERS
%    get the visible containers that can receive content
dpy = getAxesContainers(hVisual);
if ~isempty(dpy) && isprop(dpy{1},'ShowContent')
  visible = cellfun(@(x) x.ShowContent, dpy);
  dpy = dpy(visible);
end

function setSigSession(sig)
% SETSIGSESSION
%   Assign colors/signal names back to sptool

% extract sptool's user data
hSPT = findall(0,'tag','sptool');
ud = get(hSPT,'UserData');
ud.session{1} = sig;

% rebuild signal list of sptool
listStr = get(ud.list(1),'String');
for i=1:numel(sig)
  lab = listStr{i};
  bracket = strfind(lab,'[');
  lab1 = deblank(sig(i).label);
  lab2 = lab(bracket-1:end);
  listStr{i} = [lab1 lab2];
end
set(ud.list(1),'String',listStr);

% assign data back to sptool
set(hSPT,'UserData',ud);

function histogram = getColorHistogram(sig, colorList)
% GETCOLORHISTOGRAM
%   Returns a histogram that contains a count of each color
%   in the color list.  

histogram = zeros(size(colorList,1),1);
for iSig=1:numel(sig)
  if ~isempty(sig(iSig).lineinfo)
    for j=1:numel(histogram)
      if isfield(sig(iSig).lineinfo,'color') ...
          && isequal(colorList(j,:),sig(iSig).lineinfo.color)
        histogram(j) = histogram(j) + 1;
      end
      if isfield(sig(iSig).lineinfo,'color2') ...
          && isequal(colorList(j,:),sig(iSig).lineinfo.color2)
        histogram(j) = histogram(j) + 1;
      end
    end
  end
end

function sig = assignMissingColors(sig, colorList, histogram)
% ASSIGNMISSINGCOLORS
%   Search the signals structure for missing colors, re-arranging
%   the color order to avoid duplicate colors

% go in the order of least-to-greatest occurrences of color order.
[~, idxOrder] = sort(histogram);

% assign any signals with missing lineinfo fields
iColor = 1;
for iSig=1:numel(sig)
  if isempty(sig(iSig).lineinfo)
    sig(iSig).lineinfo.color = colorList(idxOrder(iColor),:);
    iColor = mod(iColor, numel(histogram)) + 1;
  end
  if ~isfield(sig(iSig).lineinfo,'color2')
    sig(iSig).lineinfo.color2 = colorList(idxOrder(iColor),:);
    iColor = mod(iColor, numel(histogram)) + 1;
  end
end  

function sig = assignDefaultValues(sig)
% ASSIGNDEFAULTVALUES
%   Search the signals and assign default values for the
%   markers/styles for each signal.  Store the result in SPTool

% make a list of fields and default values
fieldDefaults = {'linestyle'  '-'
                 'linestyle2' '-'
                 'marker'     'none'
                 'marker2'    'none'};

% extract the line info from each signal and assign any missing fields
for iSig=1:numel(sig)
  li = sig(iSig).lineinfo;
  for i=1:size(fieldDefaults,1)
    if ~isfield(li, fieldDefaults{i,1})
      li.(fieldDefaults{i,1}) = fieldDefaults{i,2};
    end
  end
  sig(iSig).lineinfo = li;
end  

function sig = assignMissingFields(sig)
% ASSIGNMISSINGFIELDS
%   When workspace signals are first imported into SPTool, they
%   do not have any line color/style information.  These must be 
%   assigned by the browser.  

% We will use the default axes color order to get the list of active colors
co = get(0,'defaultaxescolororder');

% If colors have been previously assigned to other signals,
% we should skip them instead of simply going through the
% default color order and looking for the first available.
histogram = getColorHistogram(sig, co);

% now assign any missing colors to the signal list
sig = assignMissingColors(sig, co, histogram);

% now assign defaults to any missing lineinfo fields
sig = assignDefaultValues(sig);

% inform SPTool of our changes
setSigSession(sig);

function setLinePropsOnDisplay(hDisplay, tp, lineIndices)
% SETLINEPROPSONDISPLAY
%   convert style to line properties information and assign to the visual
lp = struct;
for k = lineIndices
  lp.Color     = tp.LineColors{k};
  lp.LineStyle = tp.LineStyles{k};
  lp.LineWidth = tp.LineWidths{k};
  lp.Marker    = tp.MarkerStyles{k};
  lp.Visible   = tp.LineVisible{k};
  hDisplay.setLineProperties(k,lp);
end

function [iActive, nLines] = advanceActiveIndex(iActive, nLines, sig, active)
% ADVANCEACTIVEINDEX 
%   Advance the index into the active signal list when the number
%   of remaining lines to process is zero
if nLines == 0
  if iActive < numel(active)
    iActive = iActive+1;
    nLines = size(sig(active(iActive)),1);
  end
end
nLines = nLines - 1;

function copySptoolStyleToBrowser(hApplication)
% COPYSPTOOLSTYLETOBROWSER Inform the browser of the signal styles
%    This function will copy over all properties associated with
%    a signal (name, color, line style, marker style) over to the
%    TimeDomainVisual.  
%
%    It will assign default values to SPTool if the respective property
%    is not found

% Get all active sptool signals
[sig, active] = sptool('Signals',1);

% ensure all signals have valid colors
sig = assignMissingFields(sig);

dpy = getVisibleAxesContainers(hApplication.Visual);
[iActive, nLines] = advanceActiveIndex(0, 0, sig, active);
if iActive == 0
  return
end

for i=1:numel(dpy)
  style = dpy{i}.getStyle;
  n = numel(style.LineColors);
  if dpy{i}.IsComplex
    % Twice as many lines as signal names in a complex plot
    % copy over the color and linestyle for each signal
    for j=1:(n/2)
      li = sig(active(iActive)).lineinfo;
      style.LineColors{j}       = li.color;
      style.LineStyles{j}       = li.linestyle;
      style.MarkerStyles{j}     = li.marker;
      style.LineColors{n/2+j}   = li.color2;
      style.LineStyles{n/2+j}   = li.linestyle2;
      style.MarkerStyles{n/2+j} = li.marker2;
      [iActive, nLines] = advanceActiveIndex(iActive, nLines, sig, active);
    end
  else
    % copy over the color/linestyle for each signal
    for j=1:n
      li = sig(active(iActive)).lineinfo;
      style.LineColors{j}   = li.color;
      style.LineStyles{j}   = li.linestyle;
      style.MarkerStyles{j} = li.marker;
      [iActive, nLines] = advanceActiveIndex(iActive, nLines, sig, active);
    end
  end
  setLinePropsOnDisplay(dpy{i}, style, 1:n);
end

function displayCallback(hApplication)
% ensure we have all our line styles set appropriately.
copyBrowserStyleToSPTool(hApplication);

% ensure legend toggle button is in a meaningful state.
updateLegendToggle(hApplication);

function updateLegendToggle(hApplication)
dpy = getVisibleAxesContainers(hApplication.Visual);

if numel(dpy)>0
  % see if all visible legends are 'on' or 'off'
  allOn  = true;
  allOff = true;
  for i=1:numel(dpy)
    allOn = allOn & strcmpi(dpy{i}.LegendVisibility,'on');
    allOff = allOff & strcmpi(dpy{i}.LegendVisibility,'off');
  end

  
  if allOn || allOff
    % grab the menu state
    g = getGUI(hApplication);
    if isempty(g)        
        menu = findobj(hApplication.Handles.viewMenu,'Tag','uimgr.spctogglemenu_ToggleLegend');
    end
    % set/unset if needed.
    if strcmp(menu.Checked,'on') && allOff
        set(menu,'Checked', 'off');
    elseif strcmp(menu.Checked,'off') && allOn
        set(menu,'Checked', 'on');
    end
  end
end

function copyBrowserStyleToSPTool(hApplication)
% COPYBROWSERSTYLETOSPTOOL Save the browsers signal information
%   This function should be called in response to a DisplayUpdated
%   event thrown by the TimeDomainVisual.  It will copy over all
%   colors, line and marker styles, and legend names over to SPTool.

% Get all active sptool signals
[sig, active] = sptool('Signals',1);

% get the visible containers
dpy = getVisibleAxesContainers(hApplication.Visual);

[iActive, nLines] = advanceActiveIndex(0, 0, sig, active);

for i=1:numel(dpy)
  style = dpy{i}.getStyle;
  n = numel(style.LineColors);
  
  % copy over the colors to sptool session info
  isComplexPlot = dpy{i}.PlotMagPhase || dpy{i}.IsComplex;
  if isComplexPlot
    % Twice as many lines as signal names in a complex plot
    % copy over the style for each signal
    for j=1:(n/2)
      li = sig(active(iActive)).lineinfo;
      li.color      = style.LineColors{j};
      li.linestyle  = style.LineStyles{j};
      li.marker     = style.MarkerStyles{j};
      if dpy{i}.PlotMagPhase
        % copy over directly (no name decoration is performed).
        signalName  = style.LineNames{j};
      else
        % extract name from 'real(name)'
        signalName    = extractArg(style.LineNames{j});
        li.color2     = style.LineColors{n/2+j};
        li.linestyle2 = style.LineStyles{n/2+j};
        li.marker2    = style.MarkerStyles{n/2+j};
      end       
      sig(active(iActive)).label = signalName;
      sig(active(iActive)).lineinfo = li;
      [iActive, nLines] = advanceActiveIndex(iActive, nLines, sig, active);
    end
  else
    % copy over the color/linestyle for each signal
    for j=1:n
      li = sig(active(iActive)).lineinfo;
      li.color      = style.LineColors{j};
      li.linestyle  = style.LineStyles{j};
      li.marker     = style.MarkerStyles{j};
      sig(active(iActive)).lineinfo = li;
      sig(active(iActive)).label = style.LineNames{j};
      [iActive, nLines] = advanceActiveIndex(iActive, nLines, sig, active);
    end
  end
end
% assign signal session back to sptool
setSigSession(sig)

function str = extractArg(str)
% EXTRACTARG Extract everything between the parentheses
%   'str' is expected to be a string of the form 'funcName(argName)'
%   This function should extract the argName if the parenthesis are
%   detected; otherwise, if parenthesis are missing, it will instead
%   return the entire string.
txt = textscan(str,'%*[^(]%*[(]%[^)]');
if ~isempty(txt) && ~isempty(txt{1})
  str = txt{1}{1};
end
