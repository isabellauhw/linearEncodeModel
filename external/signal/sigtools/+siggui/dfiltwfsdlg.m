classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) dfiltwfsdlg < siggui.helpdialogMCOS & hgsetget
  %siggui.dfiltwfsdlg class
  %   siggui.dfiltwfsdlg extends siggui.helpdialog.
  %
  %    siggui.dfiltwfsdlg properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Filters - Property is of type 'dfilt.dfiltwfs vector'
  %       Index - Property is of type 'double'
  %       BackupFs - Property is of type 'MATLAB array'
  %       PopupListener - Property is of type 'mxArray'
  %
  %    siggui.dfiltwfsdlg methods:
  %       action - Action for the dfiltwfsdlg
  %       backupfs_listener - Listener to the backupfs property
  %       backupnames_listener - Listener to the backupnames property
  %       dfiltwfsdlg_gui_sizes - GUI Sizes and spacing for the DFILTWFSDLG
  %       filter_listener - Listener to the filter property
  %       fs_listener - Listener to the fsspecifier
  %       help - Help for the dfiltwfs dialog
  %       index_listener - Listener to the index property
  %       popup_listener - Listener to the filter name popup
  %       render_controls - Render the controls for the dialog
  %       restore - Restore the original default fs
  %       setname - Set the backup name at the specified index
  %       setup_figure - Setup the figure for the dfiltwfs dialog
  %       setup_fsspecifier - Setup the fsspecifier

%   Copyright 2015-2017 The MathWorks, Inc.
  
  properties (SetObservable, GetObservable)
    %FILTERS Property is of type 'dfilt.dfiltwfs vector'
    Filters = [];
    %POPUPLISTENER Property is of type 'mxArray'
    PopupListener = [];    
  end
  properties (AbortSet, SetObservable, GetObservable)
    %INDEX Property is of type 'double'
    Index = 0;
    %BACKUPFS Property is of type 'MATLAB array'
    BackupFs = [];
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %BACKUPNAMES Property is of type 'string vector' (hidden)
    BackupNames
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %FILTERLISTENER Property is of type 'handle.listener'
    FilterListener = [];
  end
  
  
  methods  % constructor block
    function h = dfiltwfsdlg(filtobjs)
      %DFILTWFSDLG Create the object
 
      narginchk(1,1);
      
      % h = siggui.dfiltwfsdlg;
      
      addcomponent(h, siggui.fsspecifierMCOS);
      
      attachlisteners(h);
      
      set(h, 'Filters', filtobjs);
      set(h, 'isApplied', 1);
    end  % dfiltwfsdlg

  end  % constructor block
  
  methods
    function set.Filters(obj,value)
      % DataType = 'dfilt.dfiltwfs vector'
      if ~isempty(value)
        validateattributes(value,{'dfilt.dfiltwfs'}, {'vector'},'','Filters')
      end
      obj.Filters = value;
    end
    
    function set.Index(obj,value)
      % DataType = 'double'
      validateattributes(value,{'double'}, {'scalar'},'','Index')
      obj.Index = setindx(obj,value);
    end
    
    function set.PopupListener(obj,value)
      obj.PopupListener = value;
    end
    
    function set.BackupNames(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.BackupNames = value;
    end
    
    function set.FilterListener(obj,value)
      % DataType = 'handle.listener'
      if ~isempty(value)
        validateattributes(value,{'event.proplistener'}, {'scalar'},'','FilterListener')
      end
      obj.FilterListener = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function aClose = action(hObj)
      %ACTION Action for the dfiltwfsdlg
  
      aClose = true;
      
      names = get(hObj, 'BackupNames');
      bfs   = get(hObj, 'BackupFs');
      
      filtobjs = get(hObj, 'Filters');
      
      hfs = getcomponent(hObj, '-class', 'siggui.fsspecifierMCOS');
      if get(hObj, 'Index')
        
        for indx = 1:length(bfs)
          if strncmpi(bfs(indx).Units, 'normalized', 10)
            v = [];
          else
            v = evaluatevars(bfs(indx).Value);
          end
          bfs(indx).Value = v;
        end
        
        % Do this in two separate loops incase evaluatevars errors out.  If
        % evaluatevars errors out then we do not want to set any of the filts.
        for indx = 1:length(filtobjs)
          fs{indx} = getfsvalue(hfs, bfs(indx));
          set(filtobjs(indx), 'Name', names{indx});
        end
        setfs(filtobjs, fs);
      else
        fs = getfsvalue(hfs);
        
        for indx = 1:length(filtobjs)
          set(filtobjs(indx), 'Name', names{indx});
        end
        setfs(filtobjs, fs);
        
        % Update all the backup Fs's to match their new sampling frequency
        % (since they were applied to all).
        fs_listener(hObj);
        set(hObj, 'isApplied', 1);
        
      end
      
    end
    
    
    function backupfs_listener(hObj, eventData)
      %BACKUPFS_LISTENER Listener to the backupfs property

      % Sync the FsSpecifier with the fs from the filterobjs
      setup_fsspecifier(hObj);
      
    end
    
    
    function backupnames_listener(hObj, eventData)
      %BACKUPNAMES_LISTENER Listener to the backupnames property

      h    = get(hObj, 'Handles');
      
      strs = get(hObj, 'BackupNames');
      if length(strs) > 1
      end
      
      if length(strs) == 1
        set(h.editbox, ...
          'String', strs{1}, ...
          'Visible', 'On');
        set(h.combo, 'Visible', 'Off');
      else
        strs = {'Apply to All', strs{:}};
        set(h.combo, ...
          'String', strs, ...
          'Visible', 'On');
        set(h.editbox, 'Visible', 'Off');
      end
      
    end
    
    
    function sz = dfiltwfsdlg_gui_sizes(hObj)
      %DFILTWFSDLG_GUI_SIZES GUI Sizes and spacing for the DFILTWFSDLG

      sz = gui_sizes(hObj);
      
      w = 250;
      
      % Default width needs to be updated if the controls in the GUI need more
      % width
      % The following strings correspond to buttons in the GUI
      ctrlStrs = {getString(message('signal:sigtools:siggui:Apply')),getString(message('signal:sigtools:siggui:Cancel')),getString(message('signal:sigtools:siggui:OK')), getString(message('signal:sigtools:siggui:Help'))};
      nbtns = 4;
      width = largestuiwidth(ctrlStrs, 'pushbutton')+sz.pixf;
      spacings = (nbtns+2)*sz.uuhs;
      if (nbtns*width + spacings) > w
        w = nbtns*width + spacings;
      end
      
      sz.fig = [300 500 w 200] * sz.pixf;
      if isunix, sz.fig(3) = 300 * sz.pixf; end
      
      height = sz.uh+sz.vfus*3.5;
      fwidth = sz.fig(3)-2*sz.ffs;
      sz.mframe = [sz.ffs sz.fig(4)-height-sz.vffs fwidth height];
      sz.popup  = [sz.mframe(1)+sz.mframe(3)/3 sz.mframe(2)+2*sz.vfus sz.mframe(3)*2/3-sz.hfus sz.uh];
      sz.mlabel = [sz.mframe(1)+sz.hfus sz.popup(2)-sz.lblTweak 0 sz.uh];
      
      height = sz.uh*4 + sz.vfus*2 + sz.uuvs;
      sz.sframe = [sz.ffs sz.mframe(2)-height-sz.vffs fwidth height];
      sz.fsspec = [sz.sframe(1)+sz.hfus*3 sz.sframe(2)+sz.vfus+sz.bh ...
        sz.sframe(3)-5*sz.hfus sz.sframe(4)-2*sz.vfus-sz.bh/2];
      sz.button = [sz.sframe(1)+sz.hfus sz.sframe(2)+sz.vfus];
      
      
    end
    
    
    function filter_listener(h, eventData)
      %FILTER_LISTENER Listener to the filter property

      names = getbackupnames(h);
      sfs   = getbackupfs(h);
      
      % Make sure that the old index does not exceed the number of new filters.
      if length(names) < get(h, 'Index')
        set(h, 'Index', length(names));
      end
      
      set(h, 'BackupNames', names);
      set(h, 'BackupFs', sfs);
      
      % We do not want cancel to undo these changes
      resetoperations(h);
      
    end
    
    
    function fs_listener(hObj, eventData)
      %FS_LISTENER Listener to the fsspecifier

      indx = get(hObj, 'Index');
      
      hfs = getcomponent(hObj, '-class', 'siggui.fsspecifierMCOS');
      
      fs.Value = get(hfs, 'Value');
      fs.Units = get(hfs, 'Units');
      
      bfs = get(hObj, 'BackupFs');
      
      if indx
        bfs(indx) = fs;
      else
        bfs = repmat(fs, 1, length(bfs));
      end
      set(hObj, 'BackupFs', bfs);
      
      set(hObj, 'isApplied', 0);
      
    end
    
    
    function help(hObj)
      %HELP Help for the dfiltwfs dialog

      helpview(fullfile(docroot,'/toolbox/signal/','signal.map'),'fdatool_fsdlg');
      
    end
    
    
    function index_listener(hObj, inputIdx)
      %INDEX_LISTENER Listener to the index property

      if nargin == 2
        indx  = inputIdx;
        oindx = get(hObj, 'Index');
      else
        indx  = get(hObj, 'Index');
        oindx = 1;
      end
      
      % Because this is a preset listener the setfunction check does not work.
      % We must check the length of filters vs the indx ourselves.
      if indx > length(get(hObj, 'Filters'))
        return;
      end
      
      % Set the applied flag.  If we are going to or from 'Apply to All' we want
      % to enable the Apply Button.
      if ~indx && oindx
        set(hObj, 'isApplied', 0);
      end
      
      % Set the combo to be a popup (read only) if we are going to an index of 0
      h     = get(hObj, 'Handles');
      findx = indx;
      if length(hObj.BackupNames) > 1
        m     = indx;
        indx  = indx + 1;
      elseif indx == 0
        indx = 1;
        m = 1;
      else
        m = 1;
      end
      set(h.combo, 'Max', m, 'Value', indx);
      
      % Set up the fsspecifier
      setup_fsspecifier(hObj, findx);
      
    end
    
    
    function popup_listener(hObj, eventData)
      %POPUP_LISTENER Listener to the filter name popup

      h = get(hObj, 'Handles');
      
      strs = get(h.combo, 'String');
      if length(strs) > 1
        strs = strs(2:end);
      end
      set(hObj, 'BackupNames', strs);
      
      set(hObj, 'isApplied', 0);
      
      
    end
    
    
    function render_controls(this)
      %RENDER_CONTROLS Render the controls for the dialog

      render_settings(this);
      render_management(this);
      attachlcllisteners(this);
      index_listener(this);
      backupnames_listener(this);
      
    end
    
    
    function restore(hObj)
      %RESTORE Restore the original default fs

      setpref('SignalProcessingToolbox', 'DefaultFs', 1);
      oldBU = get(hObj, 'BackupFs');
      newBU.Units = 'Hz';
      newBU.Value = '1';
      set(hObj, 'BackupFs', repmat(newBU, length(oldBU), 1));
      set(hObj, 'isApplied', 0);
      
    end
    
    function setname(hObj, name, indx)
      %SETNAME Set the backup name at the specified index

      narginchk(2,3);
      
      if nargin < 3
        indx = get(hObj, 'Value');
      end
      
      names = get(hObj, 'BackupNames');
      
      if indx > length(names)
        error(message('signal:siggui:dfiltwfsdlg:setname:InternalError'));
      end
      
      names{indx} = name;
      
      set(hObj, 'BackupNames', names);
      
    end
    
    function setup_figure(hObj)
      %SETUP_FIGURE Setup the figure for the dfiltwfs dialog

      sz   = dfiltwfsdlg_gui_sizes(hObj);
      cbs  = dialog_cbs(hObj);
      hFig = figure('Visible', 'Off', ...
        'NumberTitle',      'Off', ...
        'CloseRequestFcn',  cbs.cancel, ...
        'IntegerHandle',    'Off', ...
        'Name',             getString(message('signal:sigtools:siggui:SamplingFrequency')), ...
        'Resize',           'Off', ...
        'MenuBar',          'None', ...
        'HandleVisibility', 'Off', ...
        'Color', get(0, 'DefaultUicontrolBackgroundColor'), ...
        'Position', sz.fig);
      
      set(hObj, 'FigureHandle', hFig);
      
    end
    
    function setup_fsspecifier(hObj, indx)
      %SETUP_FSSPECIFIER Setup the fsspecifier

      if nargin < 2, indx = get(hObj, 'Index'); end
      
      % Set up the fsspecifier
      hfs = getcomponent(hObj, '-class', 'siggui.fsspecifierMCOS');
      bfs = get(hObj, 'BackupFs');
      
      if indx
        set(hfs, bfs(indx));
      else
        
        backUpFs = bfs(1);
        flds = fields(backUpFs);
        for i = 1:length(flds)
          hfs.(flds{i}) = backUpFs.(flds{i});
        end

      end
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function resetoperations(hObj)
      %RESETOPERATIONS

      % We do not want to listen to any changes to Filters, since filters changes
      % cannot be undone/cancelled.
      dialog_resetoperations(hObj, 'Filters');
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function indx = setindx(hObj, indx)

% Do some pre-set steps
index_listener(hObj, indx);

if indx > length(get(hObj, 'Filters'))
  indx = length(get(hObj, 'Filters'));
elseif indx < 0
  indx = 0;
end
end  % setindx


% [EOF]
function attachlisteners(h)

l = event.proplistener(h, h.findprop('Filters'), 'PostSet', @(s,e)lclfilter_listener(h,e));

set(h, 'FilterListener', l);
end  % attachlisteners


% ---------------------------------------------------------------
function lclfilter_listener(h, eventData)

filter_listener(h, eventData);
end  % lclfilter_listener



% -------------------------------------------------------------------
function names = getbackupnames(h)

filtobjs = get(h, 'Filters');
names    = get(filtobjs, 'Name');

if ~iscell(names), names = {names}; end

for indx = 1:length(names)
  if isempty(names{indx})
    names{indx} = getString(message('signal:sigtools:sigresp:Filter0numberinteger', indx));
  end
end

end

% -------------------------------------------------------------------
function sfs   = getbackupfs(h)

filtobjs = get(h, 'Filters');
fs       = get(filtobjs, 'Fs'); if ~iscell(fs), fs = {fs}; end

for indx = 1:length(fs)
  if isempty(fs{indx})
    sfs(indx).Value = 'Fs';
    sfs(indx).Units = 'Normalized';
  else
    [sfs(indx).Value, sfs(indx).Units] = convert2engstrs(fs{indx});
    toosmall = {'a','f','p','\mu','m'};
    toolarge = {'T','P','E'};
    switch sfs(indx).Units
      case toosmall
        v = str2num(sfs(indx).Value);
        v = convertfrequnits(v, sfs(indx).Units, 'm', toosmall)/1000;
        sfs(indx).Value = num2str(v);
        sfs(indx).Units = '';
      case toolarge
        v = str2num(sfs(indx).Value);
        v = convertfrequnits(v, sfs(indx).Units, 'T', toolarge)*1000;
        sfs(indx).Value = num2str(v);
        sfs(indx).Units = 'G';
    end
    sfs(indx).Units = [sfs(indx).Units 'Hz'];
  end
end

end


% ---------------------------------------------------------------------
function render_management(this)

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');
sz   = dfiltwfsdlg_gui_sizes(this);

lbl = getString(message('signal:sigtools:siggui:FilterName'));
sz.mlabel(3) = largestuiwidth({lbl});

h.mframe = uicontrol(hFig, 'Style', 'frame', 'Position', sz.mframe);
h.combo  = sigcombobox('Parent', hFig, ...
  'Position', sz.popup, ...
  'String', {'Test'}, ...
  'Max', 0, ...
  'Callback', {@popup_cb, this});
h.editbox = uicontrol(hFig, ...
  'Style', 'edit', ...
  'Position', sz.popup - [0 3*sz.pixf sz.rbwTweak -3*sz.pixf], ...
  'String', 'Test', ...
  'HorizontalAlignment', 'Left', ...
  'Max', 0, ...
  'Callback', {@edit_cb, this});
h.poplbl = uicontrol(hFig, ...
  'Style', 'text', ...
  'HorizontalAlignment', 'Left', ...
  'Position', sz.mlabel, ...
  'String', lbl);

setenableprop(h.editbox, 'On');

set(this, 'Handles', h);

end

% ---------------------------------------------------------------------
function render_settings(this)

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');
sz   = dfiltwfsdlg_gui_sizes(this);

h.sframe = uicontrol(hFig, 'Style', 'Frame', 'Position', sz.sframe);

hfs = getcomponent(this, '-class', 'siggui.fsspecifierMCOS');
render(hfs, hFig, sz.fsspec);
set(hfs, 'Visible', 'On');
delete(hfs.Handles.fstitle);

lbls = {getString(message('signal:sigtools:siggui:SaveAsDefault')), getString(message('signal:sigtools:siggui:RestoreOriginalDefaults'))};

width(1) = largestuiwidth(lbls(1), 'pushbutton')+sz.pixf;
width(2) = largestuiwidth(lbls(2), 'pushbutton')+sz.pixf;

b1pos = [sz.button width(1) sz.bh];
b2pos = [sz.button+[width(1)+sz.hfus 0] width(2) sz.bh];

h.button = uicontrol(hFig, ...
  'Style', 'PushButton', ...
  'Position', b1pos, ...
  'String', lbls{1}, ...
  'Callback', {@saveas_cb, this});

h.button(2) = uicontrol(hFig, ...
  'Style', 'PushButton', ...
  'Position', b2pos, ...
  'String', lbls{2}, ...
  'Callback', {@restore_cb, this});

set(this, 'Handles', h);
end

% ---------------------------------------------------------------------
function attachlcllisteners(this)

h = get(this, 'Handles');

hfs  = getcomponent(this, '-class', 'siggui.fsspecifierMCOS');

l(1) = event.proplistener(this, this.findprop('BackupFs'), 'PostSet', @(s,e)lclbfs_listener(this,e));
l(2) = event.proplistener(this, this.findprop('BackupNames'), 'PostSet', @(s,e)lclbnames_listener(this,e));
l(3) = event.proplistener(this, this.findprop('Index'), 'PreSet', @(s,e)lclindex_listener(this,e));
l(4) = event.listener(hfs, 'UserModifiedSpecs', @(s,e)lclfs_listener(this,e));

this.PopupListener = event.proplistener(h.combo, h.combo.findprop('String'), 'PostSet', ...
  @(h, ev) popup_listener(this, ev));

set(this, 'WhenRenderedListeners', l);

end

% ---------------------------------------------------------------------
%   Callbacks
% ---------------------------------------------------------------------

% ---------------------------------------------------------------------
function edit_cb(hcbo, eventStruct, this)

setname(this, get(hcbo, 'String'), 1);

end

% ---------------------------------------------------------------------
function popup_cb(hcbo, eventStruct, this)

val = get(hcbo, 'Value') - 1;

set(this, 'Index', val);

end

% ---------------------------------------------------------------------
function saveas_cb(hcbo, eventStruct, this)

hfs = getcomponent(this, '-class', 'siggui.fsspecifierMCOS');
fs  = getfs(hfs);
if isempty(fs.value)
  fs = [];
else
  fs  = convertfrequnits(fs.value, fs.units, 'Hz');
end

setpref('SignalProcessingToolbox', 'DefaultFs', fs);

end

% ---------------------------------------------------------------------
function restore_cb(hcbo, eventStruct, this)

restore(this);

end

% ---------------------------------------------------------------------
%   Listeners
% ---------------------------------------------------------------------

% ---------------------------------------------------------------------
function lclindex_listener(this, eventData)

% No op

end

% ---------------------------------------------------------------------
function lclfs_listener(this, eventData)

fs_listener(this, eventData);

end

% ---------------------------------------------------------------------
function lclbfs_listener(this, eventData)

backupfs_listener(this, eventData);
end

% ---------------------------------------------------------------------
function lclbnames_listener(this, eventData)

backupnames_listener(this, eventData);


end
