classdef exportMCOS < siggui.actionclosedlgMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigio.export class
  %   sigio.export extends siggui.actionclosedlg.
  %
  %    sigio.export properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Data - Property is of type 'mxArray'
  %       DefaultLabels - Property is of type 'string vector'
  %       ExcludeItem - Property is of type 'string'
  %       CurrentDestination - Property is of type 'string'
  %       Destination - Property is of type 'sigio.abstractxpdestination' (read only)
  %       Toolbox - Property is of type 'string'
  %       CSHelpTag - Property is of type 'string'
  %
  %    sigio.export methods:
  %       action - Perform the action of the export dialog
  %       callbacks - Callbacks for the Export Dialog
  %       cancel - Perform the cancel operation for the dialog.
  %       currentDestination_listener - Listener to 'currentDestination'
  %       disp - Display a window object
  %       export_gui_sizes - GUI sizes and spaces for the export dialog
  %       getactionlabel -   Get the actionlabel.
  %       getavailconstr - GetFunction for AvailableConstructors property.
  %       getavaildes - GetFunction for AvailableDestinations property.
  %       getdata - GetFunction for Data property.
  %       getstate - Get the state of the object.
  %       hashelp -   Returns true if there is a CSHelpTag.
  %       help -   Bring up the help.
  %       newheight_cb - New Frame Height Callback
  %       render_controls - Render the controls for the export dialog
  %       resetoperations - Reset the operations
  %       resize - Resize the export dialog
  %       setavailconstr - SetFunction for AvailableConstructors property.
  %       setavaildes - SetFunction for AvailableDestinations property.
  %       setcurrentdest - SetFunction for CurrentDestination property.
  %       setdata - SetFunction for Data property.
  %       setdestination -   Pre-set function for the Destination Property.
  %       setdestobj - Utility function to create a destination object.
  %       setup_figure - Setup the figure for the Export Dialog
  %       setupdestinations - Setup the destination information.
  %       siggui_setstate - Set the state of the object
  %       update_popup - Update the Export Popup

%   Copyright 2014-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %DATA Property is of type 'mxArray'
    Data = [];
    %DEFAULTLABELS Property is of type 'string vector'
    DefaultLabels = {};
    %EXCLUDEITEM Property is of type 'string'
    ExcludeItem = '';
    %CURRENTDESTINATION Property is of type 'string'
    CurrentDestination = '';
    %TOOLBOX Property is of type 'string'
    Toolbox = 'signal';
    %CSHELPTAG Property is of type 'string'
    CSHelpTag = '';
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable, Hidden)
    %PRIVDATA Property is of type 'sigutils.vector'
    privData = [];
    %PREVIOUSSTATE Property is of type 'mxArray'
    PreviousState = [];
    %PRIVAVAILABLEDESTINATIONS Property is of type 'mxArray'
    privAvailableDestinations = [];
    %PRIVAVAILABLECONSTRUCTORS Property is of type 'mxArray'
    privAvailableConstructors = [];
    %VECTORCHANGEDLISTENER Property is of type 'handle.listener'
    VectorChangedListener = [];
    %AVAILABLECONSTRUCTORS Property is of type 'MATLAB array'
    AvailableConstructors = [];
  end
  
  properties (Access=protected, SetObservable, GetObservable,Hidden)
    %AVAILABLEDESTINATIONS Property is of type 'MATLAB array'
    AvailableDestinations = [];
  end
  
  properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
    %DESTINATION Property is of type 'sigio.abstractxpdestination' (read only)
    Destination = [];
  end
  
  
  methods  % constructor block
    function hXP = exportMCOS(data)
      %EXPORT Create an Export Object.
            
      narginchk(1,1);
      
      % hXP = sigio.export;
      
      hXP.Data = data;
      
      set(hXP, 'Version', 1.0);
      
      settag(hXP);
      
      
    end  % export
    

    function value = get.Data(obj)
      value = getdata(obj,obj.Data);
    end
    function set.Data(obj,value)
      obj.Data = lclsetdata(obj,value);
    end
    
    function set.privData(obj,value)
      % DataType = 'sigutils.vector'
      validateattributes(value,{'sigutils.vectorMCOS'}, {'scalar'},'','privData')
      obj.privData = setprivdata(obj,value);
    end
    
    function set.DefaultLabels(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.DefaultLabels = setdefaultlabels(obj,value);
    end
    
    function value = get.AvailableDestinations(obj)
      value = getavaildes(obj,obj.AvailableDestinations);
    end
    function set.AvailableDestinations(obj,value)
      obj.AvailableDestinations = setavaildes(obj,value);
    end
    
    function set.ExcludeItem(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','ExcludeItem')
      obj.ExcludeItem = value;
    end
    
    function set.PreviousState(obj,value)
      obj.PreviousState = value;
    end
    
    function set.privAvailableDestinations(obj,value)
      obj.privAvailableDestinations = value;
    end
    
    function set.privAvailableConstructors(obj,value)
      obj.privAvailableConstructors = value;
    end
    
    function set.VectorChangedListener(obj,value)
      % DataType = 'handle.listener'
      validateattributes(value,{'event.listener'}, {'scalar'},'','VectorChangedListener')
      obj.VectorChangedListener = value;
    end
    
    function value = get.AvailableConstructors(obj)
      value = getavailconstr(obj,obj.AvailableConstructors);
    end
    function set.AvailableConstructors(obj,value)
      obj.AvailableConstructors = setavailconstr(obj,value);
    end
    
    function set.CurrentDestination(obj,value)
      % DataType = 'string'
      obj.CurrentDestination = setcurrentdest(obj,value);
    end
    
    function set.Destination(obj,value)
      % DataType = 'sigio.abstractxpdestination'
      
      destination_listener(obj,value);
      
      validateattributes(value,{'sigio.abstractxpdestinationMCOS'}, {'scalar'},'','Destination')
      obj.Destination = setdestination(obj,value);
    end
    
    function set.Toolbox(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Toolbox')
      obj.Toolbox = value;
    end
    
    function set.CSHelpTag(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','CSHelpTag')
      obj.CSHelpTag = value;
    end

    
    function aClose = action(this)
      %ACTION Perform the action of the export dialog
      
      hCD = get(this,'Destination');
      aClose = action(hCD);
      
      if isrendered(this)
        set(this, 'Visible', 'Off');
      end
      
      
    end
    
    function cbs = callbacks(hXP)
      %CALLBACKS Callbacks for the Export Dialog
      
      cbs.popup    = @popup_cb;
      
    end
    
    function cancel(this)
      %CANCEL Perform the cancel operation for the dialog.
      
      if isrendered(this), set(this, 'Visible', 'Off'); end
      
      setstate(this, get(this, 'PreviousState'));
      
      notify(this, 'DialogCancelled');
      
    end
    
    function currentDestination_listener(this)
      %CURRENTDESTINATION_LISTENER Listener to 'currentDestination'
            
      % Set the popup string to match the current destination.
      h = get(this, 'Handles');
      idx = find(strcmp(this.CurrentDestination, this.AvailableDestinations));
      if isempty(idx), idx = 1; end
      
      set(h.xp2popup, 'Value', idx);
      
    end
    
    function disp(hXP)
      %DISP Display a window object

      disp(get(hXP));
      
    end
    
    
    function sz = export_gui_sizes(this,newWidth,newHeight)
      %EXPORT_GUI_SIZES GUI sizes and spaces for the export dialog
            
      sz = dialog_gui_sizes(this);
      
      % Get the height of the destination specific options frame (variable
      % height)
      if nargin < 3
        [newWidth, newHeight] = destinationSize(this.Destination);
      end
      
      % Determine the export dialog size
      xp2frHght = sz.vfus*4+sz.uh; % "Export To" frame height
      figHght = sz.button(2)+sz.button(4)+sz.vfus+newHeight+sz.vffs+xp2frHght+sz.vffs;
      
      % Give an extra 20 pixels to linux, unix, mac because of font problems.
      width = newWidth+sz.hfus*2;
      
      if ~ispc
        width = width+30*sz.pixf;
      end
      
      % Make sure that the buttons fit with 5 pixel spacing and 10 pixels on the
      % side of each label.
      minwidth = largestuiwidth({getString(message('signal:sigtools:sigio:Export')), ...
        getString(message('signal:sigtools:sigio:Help')), ...
        getString(message('signal:sigtools:sigio:Cancel'))})*3 + ...
        5*2*sz.pixf+10*2*3*sz.pixf;
      
      width = max(width, minwidth);
      
      sz.fig = [500*sz.pixf 500*sz.pixf width figHght];
      
      framewidth = sz.fig(3)-sz.hfus*2;
      
      % Export To frame and popup
      xp2frYpos = sz.fig(4)-(sz.vffs+xp2frHght);
      sz.xp2fr = [sz.hfus xp2frYpos framewidth xp2frHght];
      popupwidth = framewidth-sz.hfus*2;
      sz.xp2popup = [sz.xp2fr(1)+sz.hfus sz.xp2fr(2)+sz.vfus*2 popupwidth sz.uh];
      
      % Destination options frame(s)
      frY = sz.button(2) + sz.button(4) + sz.vfus;
      sz.xpdestopts = [sz.hfus frY framewidth newHeight];
      
    end
    
    function actionlabel = getactionlabel(this)
      %GETACTIONLABEL   Get the actionlabel.
      
      actionlabel = getString(message('signal:sigtools:sigio:Export'));
      
    end
    
    
    function out = getavailconstr(h,out)
      %GETAVAILCONSTR GetFunction for AvailableConstructors property.
      
      out = get(h,'privAvailableConstructors');
      
    end
    
    function out = getavaildes(h,out)
      %GETAVAILDES GetFunction for AvailableDestinations property.
      
      out = get(h,'privAvailableDestinations');
      
    end
    
    function out = getdata(h,out)
      %GETDATA GetFunction for Data property.
      
      out = h.privData;
      
    end
    
    function s = getstate(this)
      %GETSTATE Get the state of the object.
      
      s = sigcontainer_getstate(this);
      s = rmfield(s, 'Data');
      s = rmfield(s, 'Destination');
      
    end
    
    function b = hashelp(this)
      %HASHELP   Returns true if there is a CSHelpTag.
      
      % We only have help if a tag was provided.
      b = ~isempty(this.CSHelpTag);
      
    end
    
    function help(this)
      %HELP   Bring up the help.
      
      launchfv(this.FigureHandle, this.CSHelpTag, 'fdatool');
      
    end
    
    function newheight_cb(h,eventData)
      %NEWHEIGHT_CB New Frame Height Callback
      
      resize(h);
      
    end
    
    function render_controls(this)
      %RENDER_CONTROLS Render the controls for the export dialog
            
      h    = get(this,'Handles');
      hFig = get(this,'FigureHandle');
      sz   = export_gui_sizes(this);
      cbs  = callbacks(this);
      
      % Render the popup frame
      h.xp2Fr = framewlabel(hFig, sz.xp2fr, getString(message('signal:sigtools:sigio:ExportTo')), 'exportto', get(hFig, 'Color'));
      
      items = get(this,'AvailableDestinations');
      % jsun - remove the item from the list. e.g. remove "SPTool" if launched by SPTool
      if ~isempty(this.ExcludeItem)
        item_index = find(strcmpi(items, this.ExcludeItem));
        if ~isempty(item_index)
          items(item_index) = [];
        end
      end
      % Render the popup.  Make sure the callback is not interruptible since
      % we'll be creating objects which is time consuming.
      strsT = getTranslatedStringcell('signal:sigtools:sigio', items);
      h.xp2popup = uicontrol(hFig, ...
        'Style','Popup', ...
        'Interruptible', 'Off', ...
        'Position', sz.xp2popup, ...
        'Tag', 'export_popup', ...
        'Callback', {cbs.popup, this}, ...
        'String', strsT);
      % Save untranslated strings in the app data for use in the callback
      setappdata(h.xp2popup, 'PopupStrings', items);
      
      % Use setenableprop to gray out the background if necessary
      setenableprop(h.xp2popup, this.Enable);
      
      set(this,'Handles',h);
      
      % Render the contained destination object
      render(this.Destination,hFig,sz.xpdestopts);
      set(this.Destination,'Visible','On');
      
      % Update the "Export To" popupmenu
      update_popup(this);
      
      % destination_listener removed as it was preset, removed and added to the set method 'Destination'
      listeners(1) = event.proplistener(this, this.findprop('CurrentDestination'),'PostSet', @(h, ed)currentDestination_listener(this));
      listeners(2) = event.proplistener(this, this.findprop('AvailableDestinations'),'PostSet', @(s,e)availabledestinations_listener(this));
      listeners(3) = event.listener(this.Destination, 'NewFrameHeight', @(s,e)this.newheight_cb(this));
      listeners(4) = event.listener(this.Destination, 'UserModifiedSpecs', @(s,e)this.usermodifiedspecs_cb(this));
      listeners(5) = event.listener(this.Destination, 'ForceResize', @(~,~)this.resize(this));
      
      this.WhenRenderedListeners = listeners;
      
      cshelpcontextmenu(this,this.CSHelpTag);
      cshelpcontextmenu(this.Destination,this.CSHelpTag);
      
    end
    
    function resetoperations(this)
      %RESETOPERATIONS Reset the operations
      
      s = getstate(this);
      c = allchild(this);
      
      for indx = 1:length(c)
        
        ClassName = regexp(class(c(indx)),'\.','split');
        ClassName = ClassName{end};
        
        if strcmpi(ClassName(end-3:end),'MCOS')
          ClassName = ClassName(1:end-4);
        end
        
        n{indx} = ClassName;
      end
      
      this.PreviousState = rmfield(s, n);
      
      
    end
    
    function resize(this, varargin)
      %RESIZE Resize the export dialog
      
      % This should be a private method
      
      hFig  = get(this,'FigureHandle');
      figPos = get(hFig,'Position');
      
      sz = export_gui_sizes(this, varargin{:});
      
      % New figure position.
      set(hFig,'Position', [figPos(1:2) sz.fig(3:4)]);
      
      h = get(this, 'Handles');
      
      % set(h.xp2Fr(1), 'Units', 'Pixels', 'Position', sz.xp2fr)
      framewlabel(h.xp2Fr, sz.xp2fr);
      
      set(h.xp2popup, 'Units', 'Pixels', 'Position', sz.xp2popup)
      
      hd = get(this, 'DialogHandles');
      
      delete([hd.action hd.close]);
      
      if isfield(hd, 'help')
        delete(hd.help);
      end
      
      render_buttons(this);
      
    end
    
    function out = setavailconstr(h,out)
      %SETAVAILCONSTR SetFunction for AvailableConstructors property.
      
      if isempty(out)
        return;
      else
        h.privAvailableConstructors = out;
      end
      
      out = [];
      
    end
    
    
    function out = setavaildes(h,out)
      %SETAVAILDES SetFunction for AvailableDestinations property.
            
      ac = get(h,'AvailableConstructors');
      
      if  any([isempty(out) isempty(ac)])
        return;
      else
        h.privAvailableDestinations = out;
        
        % Get current destination
        cdes = h.CurrentDestination;
        if isempty(cdes)
          idx = 1;
        else
          idx = strmatch(lower(cdes),lower(out));
          if isempty(idx), idx = 1; end
        end
        
        h.CurrentDestination = out{idx};
      end
      
      % If the object is already set don't do anything
      if ~strcmpi(class(h.Destination), ac{idx})
        
        % Set the appropriate destination object
        setdestobj(h, ac{idx});
      end
      
      out = [];
      
    end
    
    
    function out = setcurrentdest(this, out)
      %SETCURRENTDEST SetFunction for CurrentDestination property.
            
      ad = get(this,'AvailableDestinations');
      ac = get(this,'AvailableConstructors');
      
      if  any([isempty(ad) isempty(ac)])
        return;
      else
        % Try to find the destination string
        idx = strmatch(lower(out),lower(ad));
        if isempty(idx)
          idx = 1;
          warning(message('signal:sigio:Export:setcurrentdest:destinationNotAvail', out));
        end
        out = ad{idx};
      end
      
      % Set the appropriate destination object
      setdestobj(this, ac{idx});
      
      this.isApplied = false;
      
      
    end
    
    function out = setdata(this,out)
      %SETDATA SetFunction for Data property.
      
      if isa(out, 'sigutils.vectorMCOS') && ~strcmpi(class(elementat(out, 1)),'double')
        this.privData = out;
      else
        datamodel = this.privData;
        if isempty(datamodel)
          datamodel = sigutils.vectorMCOS;
          this.privData = datamodel;
        else
          datamodel.clear;
        end
        if ~iscell(out), out = {out}; end
        for indx = 1:length(out)
          if strcmpi(class(out{indx}),'double')
            out{indx} = sigutils.vectorMCOS(50, out{indx});
          end
          
          datamodel.addelement(out{indx});
        end
      end
      
      setupdestinations(this);
      
      this.isApplied = 0;
      
      out = [];
      
    end
    
    function destobj = setdestination(this, destobj)
      %SETDESTINATION   Pre-set function for the Destination Property.
            
      olddestobj = get(this, 'Destination');
      
      if isa(olddestobj, 'sigio.abstractxpdestwvarsMCOS')
        allvardest = getcomponent(this, '-isa', 'sigio.abstractxpdestwvarsMCOS', ...
          '-not', '-class', class(olddestobj));
        olddb     = getnamedatabase(olddestobj);
        for indx = 1:length(allvardest)
          
          setnamedatabase(allvardest(indx), olddb);
        end
        
      elseif isa(destobj, 'sigio.abstractxpdestwvarsMCOS')
        allvardest = getcomponent(this, '-isa', 'sigio.abstractxpdestwvarsMCOS', ...
          '-not', '-class', class(destobj));
        if ~isempty(allvardest)
          olddb     = getnamedatabase(allvardest(1));
          setnamedatabase(destobj, olddb);
        end
      end
      
      
    end
    
    function setdestobj(this, construct)
      %SETDESTOBJ Utility function to create a destination object.
            
      hD = getcomponent(this, '-class', construct);
      
      if isempty(hD)
        hD = feval(construct,this.Data);
        set(hD, 'Toolbox', this.Toolbox);
        addcomponent(this, hD);
        if isa(hD, 'sigio.abstractxpdestwvarsMCOS')
          set(hD, 'DefaultLabels', this.DefaultLabels);
        end
      else
        hD.Data = this.Data;
      end
      
      this.Destination = hD;
      
      
    end
    
    
    function setup_figure(hXP)
      %SETUP_FIGURE Setup the figure for the Export Dialog
      
      sz   = export_gui_sizes(hXP);
      cbs  = dialog_cbs(hXP);
      hFig = figure('Position', sz.fig, ...
        'IntegerHandle','Off', ...
        'NumberTitle', 'Off', ...
        'Name', getString(message('signal:sigtools:sigio:Export')), ...
        'MenuBar', 'None', ...
        'HandleVisibility', 'Callback', ...
        'CloseRequestFcn', cbs.cancel, ...
        'Resize', 'Off', ...
        'Color',get(0,'DefaultUicontrolBackgroundColor'), ...
        'Visible', hXP.Visible);
      
      set(hXP, 'FigureHandle', hFig);
      
    end
    
    function setupdestinations(this)
      %SETUPDESTINATIONS Setup the destination information.

      % out is a sigutils.vector object which contains data of homogenous
      % type, i.e., arrays or object handles
      this.AvailableConstructors = getconstructors(this);
      this.AvailableDestinations = getdestinations(this);
      
    end
    
    function siggui_setstate(hObj,s)
      %SIGGUI_SETSTATE Set the state of the object
      
      narginchk(2,2);
      
      if isfield(s, 'Tag'),  s = rmfield(s, 'Tag'); end
      if isfield(s, 'Version'),  s = rmfield(s, 'Version'); end
      if isfield(s, 'xp2wksp'), s = rmfield(s,'xp2wksp'); end
      
      if ~isempty(s)
        set(hObj, s);
      end
      
    end
    
    
    function update_popup(hXP)
      %UPDATE_POPUP Update the Export Popup
      
      hndls = get(hXP,'Handles');
      avDest = get(hXP,'AvailableDestinations');
      currDest = get(hXP,'CurrentDestination');
      indx = strmatch(currDest, avDest);
      
      set(hndls.xp2popup, 'Value', indx);
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    
    function destination_listener(this,eventData)
      %DESTINATION_LISTENER
      
      if ~isempty(this.Destination)
        
        [oldWidth, oldHeight] = destinationSize(this.Destination);
        hnewd = eventData;
        [newWidth, newHeight] = destinationSize(hnewd);
        
        % Un-render the old destination object
        unrender(this.Destination);
        
        if oldHeight ~= newHeight || oldWidth ~= newWidth
          resize(this, newWidth, newHeight);
        end
        
        % Render the new contained object
        sz = export_gui_sizes(this, newWidth, newHeight);
        % frPos = [sz.xpdestopts(1) sz.xpdestopts(2) sz.xpdestopts(3) newHght];
        render(hnewd,this.FigureHandle,sz.xpdestopts);
        set(hnewd,'Visible','On');
        
        % Add contextsensitive help
        cshelpcontextmenu(hnewd, this.CSHelpTag);
        
        mobj = metaclass(hnewd);
        
        wrl = get(this, 'WhenRenderedListeners');
        wrl(end-2) = event.listener(hnewd, 'NewFrameHeight', @(s,e)this.newheight_cb(this));
        wrl(end-1) = event.listener(hnewd, 'UserModifiedSpecs', @(s,e)this.usermodifiedspecs_cb(this));
        
        % MCOS only allows adding listeners to objects which contain that event.
        if any(strcmpi({mobj.EventList(:).Name},'ForceResize'))
          wrl(end)   = event.listener(hnewd, 'ForceResize', @(s,e)resize(this));
        else
          % If object does not contain event, then repeat the
          % NewFrameHeight so that we have a place holder on the last
          % vector position. We don't want to leave the previous wrl(end)
          % listener as it might cause undesired events to fire - so
          % replace it with the same NewFrameHeight listener.
          wrl(end) = event.listener(hnewd, 'NewFrameHeight', @(s,e)this.newheight_cb(this));
        end
        
        this.WhenRenderedListeners = wrl;
        
      end
      
    end
    
    function deflabels = setdefaultlabels(this, deflabels)
      %SETDEFAULTLABELS
            
      objs = findobj(this, '-isa', 'sigio.abstractxpdestwvarsMCOS');      
      for idx = 1:length(objs)
        set(objs(idx), 'DefaultLabels', deflabels);
      end
      
    end
    
    function datamodel = setprivdata(this, datamodel)
      %SETPRIVDATA
            
      l = event.listener(datamodel, 'VectorChanged', @(s,e)lclvectorchanged_listener(this,e));
      
      this.VectorChangedListener = l;
      
    end
    
    function usermodifiedspecs_cb(this, eventdata)
      %USERMODIFIEDSPECS_CB
            
      this.isApplied = false;
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = lclsetdata(this, out)

% xxx this is to support qfilts.  Will be pulled when we use fixed point
% dfilts or when this udd bug is fixed.
out = this.setdata(out);
end  % lclsetdata

% --------------------------------------------------------------------
function popup_cb(hcbo, eventStruct, hXP)

strs = getappdata(hcbo,'PopupStrings'); % get untranslated strings
idx = get(hcbo,'Value'); % get popup index

set(hXP, 'CurrentDestination', strs{idx});

end

% -------------------------------------------------------------------------
function availabledestinations_listener(this, eventData)

h = get(this, 'Handles');

ad = get(this, 'AvailableDestinations');
cd = get(this, 'CurrentDestination');

set(h.xp2popup, ...
  'String', ad, ...
  'Value',  find(strcmpi(ad, cd)));

end

% -------------------------------------------------------------------------
function lclvectorchanged_listener(this, eventData)

if ~isempty(eventData.Source)
  setupdestinations(this);
end

end


% -------------------------------------------------------------------------
function constructor = getconstructors(this)
% Get the destinations to export the data

% Default destination object constructors
constructor = {'sigio.xp2wkspMCOS','sigio.xp2txtfileMCOS','sigio.xp2matfileMCOS'};

% Check if structure contains data specific constructors
info = exportinfo(this.Data);

if isfield(info,'constructors')
  newconstructors = info.constructors;
  
  % Index of the data requested default destination object constructors
  idx = find(cellfun('isempty',info.constructors));
  
  newconstructors(idx) = constructor(idx);
  constructor = newconstructors;
  
  % This following condition needs to be removed after converting sigwin
  % package to MCOS
  if strcmpi(constructor(2),'sigio.xp2winfile')
    constructor(2) = strcat(constructor(2),'MCOS');
  end
  
  
end

end


% -------------------------------------------------------------------------
function des = getdestinations(this)
% Get the destinations to export the data

% Default Destinations
des = {'Workspace','Text-File','MAT-File'};

% Get the info structure
info = exportinfo(this.Data);

% Check if structure contains data specific destinations
if isfield(info,'destinations')
  des = info.destinations;
end

end

% [EOF]
