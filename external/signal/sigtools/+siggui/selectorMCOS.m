classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) selectorMCOS < siggui.sigcontainerMCOS & hgsetget
  %siggui.selector class
  %   siggui.selector extends siggui.sigcontainer.
  %
  %    siggui.selector properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Name - Property is of type 'string' (read only)
  %       Selection - Property is of type 'string'
  %       SubSelection - Property is of type 'string'
  %       Identifiers - Property is of type 'MATLAB array'
  %       Strings - Property is of type 'MATLAB array'
  %       CSHTags - Property is of type 'string vector'
  %
  %    siggui.selector methods:
  %       callbacks - Callbacks for the Selector object
  %       difference - Returns the difference between the # of tags and the # of strings.
  %       disableselection - Disable a selection
  %       enable_listener - Listener to the enable property of the Selector
  %       enableselection - Enable a selection
  %       getallselections - Returns all available selections
  %       getenabledselections - Returns the selections which are not disabled
  %       getstring - Returns the string at the tag
  %       getsubselections - Returns all subselections for a given selection
  %       getsubstrings - Returns the labels for the subselection
  %       listeners - Listeners to the properties of the selector
  %       selector_render - Render the Selector
  %       setgroup - Change a group in the selector
  %       setstate - Set the state of the selector object
  %       tag2string - Map a tag to a string
  %       thisrender - Render the Selector
  %       update - Update the selector
  %       visible_listener -   Listener to the Visible property.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %IDENTIFIERS Property is of type 'MATLAB array'
    Identifiers = [];
    %STRINGS Property is of type 'MATLAB array'
    Strings = [];
    %CSHTAGS Property is of type 'string vector'
    CSHTags
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %DISABLEDSELECTIONS Property is of type 'string vector'
    DisabledSelections
    %PRIVSELECTION Property is of type 'string'
    privSelection = '';
    %PRIVSUBSELECTION Property is of type 'string'
    privSubSelection = '';
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %SELECTIONLISTENER Property is of type 'handle.listener'
    SelectionListener = [];
  end
  
  properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
    %NAME Property is of type 'string' (read only)
    Name = '';
  end
  
  properties (SetObservable, GetObservable)
    %SELECTION Property is of type 'string'
    Selection = '';
    %SUBSELECTION Property is of type 'string'
    SubSelection = '';
  end
  
  
  events
    NewSelection
    NewSubSelection
  end  % events
  
  methods  % constructor block
    function this = selectorMCOS(name, tags, labels, selection, subselection)
      %SELECTOR Constructor for the generic Selector
      %   H = SIGGUI.SELECTOR(NAME, TAGS, LABELS) Create a selector object whose name
      %   is NAME.  TAGS is a cell array of strings which are used to identify
      %   selections made.  LABELS is a cell array of strings which are used to label
      %   the radio buttons which are created by the RENDER method.  TAGS and LABELS
      %   must be the same size.
      %
      %   TAGS and LABELS can be nested cell array.  If this format is used the second
      %   layer inside the cell array is used to identify the SubSelection.  When
      %   rendered popup menus will be used to show the subselections available.
      %
      %    H = SIGGUI.SELECTOR(NAME, TAGS, LABELS, DEFAULT) Create a selector object
      %   which has DEFAULT selected.
      %
      %   EXAMPLES:
      %
      %   % #1 Create a selector to choose your favorite ice cream
      %   tags    = {'vanilla', 'chocolate', 'strawberry'};
      %   strings = {'Vanilla', 'Chocolate', 'Strawberry'};
      %   name    = 'What is your favorite Ice Cream?';
      %   h       = siggui.selector(name, tags, strings);
      %   hFig    = figure('position',[200 200 212 180], ...
      %      'Menubar', 'None');
      %
      %   % Execute these lines one at a time.
      %   render(h, hFig, [10 10 192 160]);
      %   set(h, 'Visible', 'On');
      %   disableselection(h, 'strawberry', 'vanilla')
      %
      %   % #2 Create a more complicated ice cream selector
      %   tags    = {'vanilla', 'chocolate', 'strawberry', ...
      %             {'withcandy', 'butterfinger', 'reesespieces', 'm&m'}};
      %   strings = {'Vanilla', 'Chocolate', 'Strawberry', ...
      %             {'With Candy', 'ButterFinger', 'Reese''s Pieces', 'M&M''s'}};
      %   name    = 'What is your favorite Ice Cream?';
      %   h       = siggui.selector(name, tags, strings,tags{2});
      %   hFig    = figure('position',[200 200 222 180], ...
      %      'Menubar', 'None');
      %
      %   % Execute these lines one at a time.
      %   render(h, hFig, [10 10 202 160]);
      %   set(h, 'Visible', 'On');
      %   disableselection(h, 'strawberry', 'vanilla')
      %   setgroup(h, 'withcandy', {'butterfinger', 'reesespieces'}, {'ButterFinger', 'Reese''''s Pieces'});
      %
      %   See Also DISABLESELECTION, ENABLESELECTION, SETGROUP, RENDER.
      
      %   Author(s): J. Schickler
      
      narginchk(3,5);
      
      validate_inputs(tags, labels);
      
      % Instantiate the object
      % this = siggui.selector;
      
      % Set up the object
      set(this, 'Identifiers', tags);
      set(this, 'Strings', labels);
      set(this, 'Version', 1.0);
      set(this, 'Name', name);
      
      if nargin < 5
        subselections = getsubselections(this);
        subselection  = subselections{1};
        if nargin < 4
          selections = getallselections(this);
          selection  = selections{1};
        end
      end
      
      % Set the objects original selection
      set(this, 'Selection', selection);
      
      if ~isempty(subselection)
        set(this, 'SubSelection', subselection);
      end
    end  % selector
    
    
    % -------------------------------------------------------------
    
  end  % constructor block
  
  methods
    function set.Name(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Name')
      obj.Name = value;
    end
    
    function value = get.Selection(obj)
      value = getselection2(obj,obj.Selection);
    end
    function set.Selection(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Selection')
      obj.Selection = setselection2(obj,value);
    end
    
    function value = get.SubSelection(obj)
      value = getsubselection2(obj,obj.SubSelection);
    end
    function set.SubSelection(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','SubSelection')
      obj.SubSelection = setsubselection2(obj,value);
    end
    
    function set.Identifiers(obj,value)
      obj.Identifiers = setids(obj,value);
    end
    
    function set.Strings(obj,value)
      obj.Strings = setstrs(obj,value);
    end
    
    function set.CSHTags(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.CSHTags = value;
    end
    
    function set.DisabledSelections(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.DisabledSelections = value;
    end
    
    function set.privSelection(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','privSelection')
      obj.privSelection = value;
    end
    
    function set.privSubSelection(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','privSubSelection')
      obj.privSubSelection = value;
    end
    
    function set.SelectionListener(obj,value)
      % DataType = 'handle.listener'
      if ~isempty(value)
        validateattributes(value,{'handle.listener'}, {'scalar'},'','SelectionListener')
      end
      obj.SelectionListener = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function cbs = callbacks(hSct)
      %CALLBACKS Callbacks for the Selector object

      cbs.radio = @radio_cb;
      cbs.popup = @popup_cb;
      
    end
    
    function factor = difference(hSct, indx)
      %DIFFERENCE Returns the difference between the # of tags and the # of strings.
 
      lbls = get(hSct, 'Strings');
      tags = get(hSct, 'Identifiers');
      
      factor = length(tags{indx}) - length(lbls{indx});
      
    end
    
    
    function disableselection(hObj, varargin)
      %DISABLESELECTION Disable a selection
      %   DISABLESELECTION(hObj, TAG) Disable the top level selection associated
      %   with the string TAG.  This will disable the radio button, and the popup
      %   if applicable.  This will also prevent the selection from being set at
      %   the command line.
      %
      %   DISABLESELECTION(hObj, TAG1, TAG2, etc) Disable multiple top level
      %   selections.
      %
      %   If SubSelections must be disabled use SETGROUP to remove them from the popup.
      %
      %   See also ENABLESELECTION, SETGROUP.

      narginchk(2, inf);
      
      % Get the indexes to disable
      indx = find_disabled_indexes(hObj, varargin{:});
      
      if ~isempty(indx)
        
        % Get the enabled selections (which indx refers to)
        eSelects = getenabledselections(hObj);
        
        % Add the new disabled selections to the list
        dSelects = get(hObj, 'DisabledSelections');
        dSelects = {dSelects{:}, eSelects{indx}};
        
        % Set the disabled selections
        set(hObj, 'DisabledSelections', dSelects);
        
        % Verify that the current selection is still available
        check_selection(hObj, eSelects{indx});
        
        if isrendered(hObj)
          update(hObj, 'update_popup');
        end
      end
      
    end
    
    function enable_listener(hSct, eventData)
      %ENABLE_LISTENER Listener to the enable property of the Selector
 
      update(hSct, 'update_enablestates');
      
    end
    
    function enableselection(hObj, varargin)
      %ENABLESELECTION Enable a selection
      %   ENABLESELECTION(hObj, TAG) Enable the disabled selection associated with TAG.
      %
      %   ENABLESELECTION(hObj, TAG1, TAG2, etc) Enable the disabled selections.
      %
      %   ENABLESELECTION(hObj) Enable all disabled selections.
      %
      %   See also DISABLESELECTION, SETGROUP.

      narginchk(1, inf);
      
      if nargin == 1
        dSelects = {};
        set(hObj, 'DisabledSelections', dSelects);
        
        % Verify that a selection is made
        check_selection2(hObj);
        if isrendered(hObj)
          update(hObj, 'update_popup');
        end
      else
        
        % Get the indexes to enable.
        indx = find_enabled_indexes(hObj, varargin{:});
        
        % Update the disabledselections
        dSelects = get(hObj, 'DisabledSelections');
        
        if ~isempty(indx)
          dSelects(indx) = [];
          
          set(hObj, 'DisabledSelections', dSelects);
          
          % Verify that a selection is made
          check_selection2(hObj);
          if isrendered(hObj)
            update(hObj, 'update_popup');
          end
        end
      end
      
    end
    
    function selections = getallselections(hSct)
      %GETALLSELECTIONS Returns all available selections
 
      identifiers = get(hSct, 'Identifiers');
      selections  = {};
      
      % Loop over the identifiers and get only the first element
      for i = 1:length(identifiers)
        if iscell(identifiers{i})
          selections{i} = identifiers{i}{1};
        else
          selections{i} = identifiers{i};
        end
      end
      
    end
    
    
    function eSelects = getenabledselections(hSct)
      %GETENABLEDSELECTIONS Returns the selections which are not disabled

      selects  = getallselections(hSct);
      dSelects = get(hSct, 'DisabledSelections');
      
      eSelects = {};
      
      % Loop over the selections and find those which are enabled
      for i = 1:length(selects)
        if isempty(strmatch(selects{i}, dSelects))
          eSelects{end+1} = selects{i};
        end
      end
      
    end
    
    
    function str = getstring(h, tag)
      %GETSTRING Returns the string at the tag

      ids = get(h, 'Identifiers');
      
      idx = find(strcmpi(tag, ids));
      
      if isempty(idx)
        str = '';
      else
        strs = get(h, 'Strings');
        str  = strs{idx};
      end
      
    end
    
    
    function subselects = getsubselections(hSct, tag)
      %GETSUBSELECTIONS Returns all subselections for a given selection
      %   GETSUBSELECTIONS(hSCT) Returns all subselections for the current selection
      %
      %   GETSUBSELECTIONS(hSCT, TAG) Returns all subselections for the selection
      %   specified by the string TAG.

      narginchk(1,2);
      
      identifiers = get(hSct, 'Identifiers');
      selections  = getallselections(hSct);
      
      if nargin == 1
        tag = get(hSct,'Selection');
      end
      
      if isempty(tag)
        subselects = {''};
        return
      end
      
      % Find the referenced selection
      indx = strmatch(tag, selections);
      
      switch length(indx)
        case 0
          error(message('signal:siggui:selector:getsubselections:SelectionNotFound'))
        case 1
          if iscell(identifiers{indx})
            subselects = {identifiers{indx}{2:end}};
          else
            subselects = {};
          end
        otherwise
          matches = [];
          for i = 1:length(indx)
            matches = [matches char(9) '''' selections{indx(i)} '''']; %#ok<AGROW>
          end
          error(message('signal:siggui:selector:getsubselections:SelectionNotSpecific', matches))
      end
      
    end
    
    function strs = getsubstrings(hSct, tag)
      %GETSUBSTRINGS Returns the labels for the subselection

      narginchk(1,2);
      
      if nargin == 1, tag = get(hSct,'Selection'); end
      
      if isempty(tag)
        strs = {''};
        return
      end
      
      strings    = get(hSct, 'Strings');
      selections = getallselections(hSct);
      
      % Find the referenced selection, use strmatch for partial string completion
      indx = strmatch(tag, selections);
      
      switch length(indx)
        case 0
          error(message('signal:siggui:selector:getsubstrings:SelectionNotFound'))
        case 1
          selections = get(hSct, 'Identifiers');
          
          % There are only substrings if the strings at indx are a cell
          if iscell(strings{indx})
            strs = strings{indx}(1:end);
            
            % If the length of the strings and tags are the same the first
            % string is the radio label, do no return it.
            if ~difference(hSct, indx)
              strs = strs(2:end);
            end
          else
            strs = {};
          end
        otherwise
          matches = [];
          for i = 1:length(indx)
            matches = [matches char(9) '''' selections{indx(i)} '''']; %#ok<AGROW>
          end
          error(message('signal:siggui:selector:getsubstrings:SelectionNotSpecific', matches));
      end
      
    end
    
    
    function listeners(this, eventData, fcn, varargin)
      %LISTENERS Listeners to the properties of the selector

      feval(fcn, this, eventData, varargin{:});
      
    end
    
    function selector_render(this, varargin)
      %SELECTOR_RENDER Render the Selector
      %   SELECTOR_RENDER(H, hFig, POS) Render the Selector to the figure hFig
      %   with the position POS.
      %
      %   SELECTOR_RENDER(H, hFig, POS, CTRLPOS) Render the Selector.  CTRLPOS
      %   will be used to determine the position of the radiobuttons and popups,
      %   instead of POS, which will be used to render the frame and label.  If
      %   CTRLPOS is not used POS will determine the position of the controls.
      %
      %   SELECTOR_RENDER(H, POS) Render the selector to the position POS.  When
      %   hFig is not specified, the value stored in the object is used.

      [framePos, controlPos] = parse_inputs(this, varargin{:});
      
      % Render the frame and controls
      hFig  = get(this, 'FigureHandle');
      frLbl = get(this, 'Name');
      
      if isempty(framePos)
        h.frame = [];
      else
        h.frame = framewlabel(hFig, framePos, getTranslatedString('signal:sigtools:siggui',frLbl), 'selectorframe', ...
          get(0,'DefaultUicontrolBackgroundColor'), this.Visible);
      end
      
      cbs     = callbacks(this);
      strings = get(this, 'Strings');
      tags    = get(this, 'Identifiers');
      sz      = gui_sizes(this);
      skip    = (controlPos(4) - length(tags)*sz.uh)/(length(tags)+1);
      y       = controlPos(2)+controlPos(4);
      
      strings = getTranslatedStringcell('signal:sigtools:siggui',  strings);
      
      % Set up the spacing for the radios and popups
      erbtweak = gettweak(this);
      popwidth = getpopupwidth(strings);
      
      % Find the width of all the UIcontrols on the frame
      % The Space, the radiobutton, the radiobutton label and the popupmenu
      twidth = sz.hfus+erbtweak+sz.rbwTweak+popwidth;
      
      % Make sure that the popup does not go outside the frame
      if twidth > controlPos(3)-sz.hfus
        popwidth = popwidth - twidth+controlPos(3)-sz.hfus;
      end
      
      radwidth = controlPos(3)-2*sz.hfus;
      twidth = sz.hfus+radwidth;
      
      if twidth > controlPos(3)-sz.hfus
        radwidth = radwidth - twidth+controlPos(3)-sz.hfus;
      end
      
      % Set up the controlPositions of the radios and popups
      radPos = [controlPos(1)+sz.hfus y radwidth sz.uh];
      popPos = [controlPos(1)+sz.hfus+erbtweak+sz.rbwTweak y popwidth sz.uh];
      
      enabState = get(this, 'Enable');
      visState = get(this, 'Visible');
      
      for i = 1:length(tags)
        y = y-skip-sz.uh;
        radPos(2) = y;
        popPos(2) = y;
        
        % Render the radio button
        h.radio(i) = uicontrol(hFig, ...
          'Style', 'radio', ...
          'Enable', enabState, ...
          'Visible', visState, ...
          'Callback', {cbs.radio, this}, ...
          'Interruptible', 'off', ...
          'Position', radPos);
        
        % If the index into the tags is a cell, render a popup
        if iscell(tags{i})
          tag = tags{i}{1};
          
          % If the tags and strings are the same length, the popup has a label
          if ~difference(this, i)
            str = strings{i}{1};
            strs = {strings{i}{2:end}};
          else
            str = '';
            strs = strings{i};
          end
          ptags = {tags{i}{2:end}};
        else
          tag = tags{i};
          str = strings{i};
          strs = {''};
          ptags = {''};
        end
        
        % Render the popup
        h.popup(i) = uicontrol(hFig, ...
          'Style', 'popupmenu', ...
          'Position', popPos, ...
          'String', strs, ...
          'Tag', tag, ...
          'Interruptible', 'Off', ...
          'Enable', enabState, ...
          'Visible', visState, ...
          'HorizontalAlignment', 'Left', ...
          'Callback', {cbs.popup, this}, ...
          'UserData', ptags);
        
        set(h.radio(i),'Tag',tag,'String',str);
      end
      
      set(this, 'Handles', h);
      
      % Update the radio buttons
      update(this);
      
      
      l(1) = event.listener(this, 'NewSelection', @(h,evt) listeners(this,evt,'selection_listener'));
      l(2) = event.listener(this, 'NewSubSelection', @(h,evt) listeners(this,evt,'subselection_listener'));
      l(3) = event.proplistener(this, this.findprop('DisabledSelections'), 'PostSet', @(h,evt) listeners(this,evt,'disabledselections_listener'));
      l(4) = event.proplistener(this, this.findprop('Identifiers'), 'PostSet', @(h,evt) listeners(this,evt,'identifiers_listener'));
      l(5) = event.proplistener(this, this.findprop('Strings'), 'PostSet', @(h,evt) listeners(this,evt,'strings_listener'));
      l(6) = event.proplistener(this, this.findprop('CSHTags'), 'PostSet', @(h,evt) listeners(this,evt,'cshtags_listener'));
      
      set(this,'WhenRenderedListeners',l);
      
    end
    
    
    function setgroup(hSct, varargin)
      %SETGROUP Change a group in the selector
      %   SETGROUP(hSCT, TAG, NEWTAGS, NEWSTRS) Change a popupmenu group in the selector
      %   which is identified by TAG.  NEWTAGS stores the new identifiers for the selections
      %   within the popup and NEWSTRS stores the new strings for the selections within the
      %   popup.  Only subselections can be changed through this method.

      % Parse and validate the inputs
      [tag, tags, strings] = parse_inputs2(hSct, varargin{:});
      
      selections = getallselections(hSct);
      indx       = strmatch(tag, selections);
      
      switch length(indx)
        case 0
          error(message('signal:siggui:selector:setgroup:SelectionNotAvailable'));
        case 1
          alltags    = get(hSct, 'Identifiers');
          allstrings = get(hSct, 'Strings');
          
          if iscell(alltags{indx})
            indx2   = find(strcmpi(hSct.SubSelection, alltags{indx}(2:end)))-difference(hSct, indx)+1;
            if isempty(indx2)
              cstring = '';
            else
              cstring = allstrings{indx}{indx2};
            end
            
          else
            cstring = '';
          end
          % Make sure that the radio button label is not being changed
          
          % If the tags and indexes are of the same size, then we want to retain
          % the first string (the label to the radio button)
          if ~difference(hSct, indx)
            if iscell(allstrings{indx})
              newstr = [allstrings{indx}(1) strings];
            else
              newstr = [{allstrings{indx}} strings];
            end
          else
            newstr = strings;
          end
          
          if iscell(alltags{indx})
            alltags{indx} = [alltags{indx}(1) tags];
          else
            if length(tags) == length(strings)
              alltags{indx} = [{alltags{indx}} tags];
            else
              alltags{indx} = tags;
            end
          end
          
          allstrings{indx} = newstr;
        otherwise
          matches = [];
          for i = 1:length(indx)
            matches = [matches '  ''' selections{indx(i)} '''']; %#ok<AGROW>
          end
          error(message('signal:siggui:selector:setgroup:SelectionNotSpecific', matches));
          
      end
      
      set(hSct, 'Identifiers', alltags);
      set(hSct, 'Strings', allstrings);
      
      % Make sure that the subselection is still valid.
      if strcmpi(hSct.Selection, tag)
        subselect = get(hSct, 'SubSelection');
        if isempty(find(strcmpi(subselect, tags), 1))
          
          % Make sure the string is unavailable too.
          cindx = find(strcmpi(cstring, allstrings{indx}));
          if isempty(cindx)
            set(hSct, 'SubSelection', tags{1});
          else
            
            % If the string is still available use it.
            set(hSct, 'SubSelection', alltags{indx}{cindx});
          end
        end
      end
      
      if isrendered(hSct)
        update(hSct, 'update_popup');
      end
      
    end
    
    function setstate(h, s)
      %SETSTATE Set the state of the selector object
 
      set(h, 'Selection', s.Selection);
      set(h, 'SubSelection', s.SubSelection);
      
    end
    
    
    function string = tag2string(hObj, tag)
      %TAG2STRING Map a tag to a string

      tags = get(hObj, 'Identifiers');
      strs = get(hObj, 'String');
      
      string = '';
      
      for i = 1:length(tags)
        if ischar(tags{i})
          if strcmpi(tag, tags{i})
            string = strs{i};
            return;
          end
        else
          indx = find(strcmpi(tag, tags{i}));
          switch length(indx)
            case 0
              % NO OP
            case 1
              string = strs{i}{indx-difference(hObj,i)};
            case 2
              if indx(1) == 1
                string = strs{i}{indx(2-difference(hObj, i))};
              else
                error(message('signal:siggui:selector:tag2string:GUIErr'));
              end
            otherwise
              error(message('signal:siggui:selector:tag2string:GUIErr'));
          end
        end
      end
      
    end
    
    function thisrender(this, varargin)
      %THISRENDER Render the Selector
      %   THISRENDER(hSct, hFig, POS) Render the Selector to the figure hFig with the
      %   position POS.
      %
      %   THISRENDER(hSct, hFig, POS, CTRLPOS) Render the Selector.  CTRLPOS will be used
      %   to determine the position of the radiobuttons and popups, instead of POS, which
      %   will be used to render the frame and label.  If CTRLPOS is not used POS will
      %   determine the position of the controls.
      %
      %   THISRENDER(hSct, POS) Render the selector to the position POS.  When hFig is
      %   not specified, the value stored in the object is used.

      selector_render(this, varargin{:});
      
    end
    
    
    function update(this, fcn, varargin)
      %UPDATE Update the selector
 
      if nargin == 1, fcn = 'update_all'; end
      
      feval(fcn, this, varargin{:});
      
    end
    
    function visible_listener(hObj, varargin)
      %VISIBLE_LISTENER   Listener to the Visible property.

      sigcontainer_visible_listener(hObj, varargin{:});
      
      h = get(hObj, 'Handles');
      strs = get(hObj, 'Strings');
      
      for indx = 1:length(strs)
        if iscell(strs{indx})
          set(h.popup(indx), 'Visible', hObj.Visible);
        else
          set(h.popup(indx), 'Visible', 'Off');
        end
      end
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function out = getnset(h, fcn, out)
      %GETNSET

      out = feval(fcn, h, out);
      
    end
    
    function setstring(h, tag, newstr)
      %SETSTRINGS

      ids = get(h, 'Identifiers');
      
      idx = find(strcmpi(tag, ids));
      
      if ~isempty(idx)
        strs = get(h, 'Strings');
        strs{idx} = newstr;
        set(h, 'Strings', strs);
      end
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = setids(hObj, out)

if isrendered(hObj) && length(out) ~= length(hObj.Strings)
  error(message('signal:siggui:selector:schema:GUIErr'));
end
end  % setids


% -------------------------------------------------------------------------
function out = setstrs(hObj, out)

if isrendered(hObj) && length(out) ~= length(hObj.Identifiers)
  error(message('signal:siggui:selector:schema:GUIErr'));
end
end  % setstrs


% -------------------------------------------------------------------------
function out = setselection2(hObj, out)

out = getnset(hObj, 'setselection', out);
end  % setselection


% -------------------------------------------------------------------------
function out = getselection2(hObj, out)

out = getnset(hObj, 'getselection', out);
end  % getselection


% -------------------------------------------------------------------------
function out = setsubselection2(hObj, out)

out = getnset(hObj, 'setsubselection', out);
end  % setsubselection


% -------------------------------------------------------------------------
function out = getsubselection2(hObj, out)

out = getnset(hObj, 'getsubselection', out);
end  % getsubselection


function validate_inputs(tags, labels)

i = 1;

if length(labels) ~= length(tags)
  error(message('signal:siggui:selector:selector:InvalidStringIdentLength'))
end

while i <= length(labels)
  if iscell(labels{i})
    diff = length(tags{i}) - length(labels{i});
    if ~iscell(tags{i})
      error(message('signal:siggui:selector:selector:InvalidTagLength'))
    elseif diff > 1 | diff < 0
      error(message('signal:siggui:selector:selector:InvalidTagLength'))
    end
  elseif iscell(tags{i})
    diff = length(tags{i}) - length(labels{i});
    if ~iscell(labels{i})
      error(message('signal:siggui:selector:selector:InvalidTagLength'))
    elseif diff > 1 | diff < 0
      error(message('signal:siggui:selector:selector:InvalidTagLength'))
    end
  elseif ~ischar(labels{i}) | ~ischar(tags{i})
    error(message('signal:siggui:selector:selector:InvalidInput'))
  end
  i = i + 1;
end
end  % validate_inputs



% ---------------------------------------------------------
function radio_cb(hcbo, eventStruct, hSct)

h = get(hSct, 'Handles');

set(setdiff(h.radio, hcbo), 'Value', 0);
set(hcbo, 'Value', 1);

tag  = get(hcbo, 'Tag');

% Set the selection to the tag of the radio button
set(hSct, 'Selection', tag);

end

% ---------------------------------------------------------
function popup_cb(hcbo, eventStruct, hSct)

tag  = get(hcbo, 'Tag');
tags = get(hcbo, 'UserData');
indx = get(hcbo, 'Value');

h = get(hSct, 'Handles');

hon = findobj(h.radio, 'tag', tag);
set(setdiff(h.radio, hon), 'Value', 0);
set(hon, 'Value', 1);

% Set the selection to the tag of the popup
set(hSct, 'Selection', tag);

% Set the subselection to the indexed userdata tags
set(hSct, 'SubSelection', tags{indx});

end


% ----------------------------------------------------------------------------
function indx = find_disabled_indexes(hObj, varargin)

options = getenabledselections(hObj);
indx    = [];

for i = 1:length(varargin)
  tag  = varargin{i};
  tempindx = strmatch(tag, options);
  
  switch length(tempindx)
    case 0
      selections = getallselections(hObj);
      if isempty(strmatch(tag, selections))
        error(message('signal:siggui:selector:disableselection:SelectionNotAvailable'))
      end
    case 1
      % NO OP
    otherwise
      % Input is too vague
      matches = [];
      for ii = 1:length(tempindx)
        matches = [matches '  ''' options{tempindx(ii)} ''''];
      end
      error(message('signal:siggui:selector:disableselection:SelectionNotSpecific', matches))
  end
  
  if ~isempty(tempindx)
    indx(end+1) = tempindx;
  end
end

end

% ------------------------------------------------------------
function check_selection(hObj, varargin)

selection = get(hObj, 'Selection');

% If the input selection is the current selection, choose a new selection
if ~isempty(strmatch(selection, varargin))
  eSelects = getenabledselections(hObj);
  
  if isempty(eSelects)
    eSelects = {''};
  end
  
  set(hObj, 'Selection', eSelects{1});
end

end

% -------------------------------------------------------------------
function indx = find_enabled_indexes(hObj, varargin)

% Get the currently disabled selections.
dSelects = get(hObj, 'DisabledSelections');
indx     = [];

for i = 1:length(varargin)
  
  % Verify that the input is a disabled selection
  tag      = varargin{i};
  tempindx = strmatch(tag, dSelects);
  
  switch length(tempindx)
    case 0
      selections = getallselections(hObj);
      
      % Check against all the selections to create a good message.
      if isempty(strmatch(tag, selections))
        error(message('signal:siggui:selector:enableselection:SelectionNotAvailable'))
      else
        tempindx = [];
      end
    case 1
      % NO OP
    otherwise
      
      % Input is too vague
      matches = [];
      for ii = 1:length(tempindx)
        matches = [matches '  ''' dSelects{tempindx(ii)} '''']; %#ok<AGROW>
      end
      error(message('signal:siggui:selector:enableselection:SelectionNotSpecific', matches))
  end
  
  if ~isempty(tempindx)
    indx(end+1) = tempindx;
  end
end

end

% ---------------------------------------------------------------------------
function check_selection2(hObj)

% If there is no selection (because they were all disabled), select the first
if isempty(hObj.Selection)
  eSelects = getenabledselections(hObj);
  set(hObj, 'Selection', eSelects{1});
end

end



% -------------------------------------------------------------------------
function selection = setselection(hObj, selection)

options = getenabledselections(hObj);

% If no new selection is given, return the available selections
if nargin == 1
  out = options;
  return;
elseif isempty(selection)
  if isempty(options)
    selection = '';
  else
    error(message('signal:siggui:selector:getnset:SelectionSetToEmpty'))
  end
else
  
  indx = strmatch(selection, options);
  
  switch length(indx)
    case 0
      if isempty(strmatch(selection, getallselections(hObj)))
        error(message('signal:siggui:selector:getnset:SelectionNotAvailable'))
      else
        error(message('signal:siggui:selector:getnset:SelectionDisabled'))
      end
    case 1
      selection = options{indx};
    otherwise
      % See if we have an exact match, i.e. iirlpnorm and iirlpnormc
      if isempty(find(strcmpi(selection, options), 1))
        matches = [];
        for i = 1:length(indx)
          matches = [matches '  ''' options{indx(i)} '''']; %#ok<AGROW>
        end
        error(message('signal:siggui:selector:getnset:SelectionNotSpecific', matches))
      end
  end
end

% Get the correct subselection
if isrendered(hObj)
  
  h = get(hObj, 'Handles');
  
  hPop = findobj(h.popup, 'Tag', selection);
  
  if ~isempty(hPop)
    indx = get(hPop,'Value');
    subs = get(hPop,'UserData');
    if indx > length(subs), indx = 1; end
    subselect = subs{indx};
  else
    subselect = '';
  end
else
  subselects = getsubselections(hObj);
  if isempty(subselects)
    subselect = '';
  else
    subselect = subselects{1};
  end
end

% Only set the new selection if it doesn't match the old.
% When these methods become the overloaded sets we should no longer need this.
if ~strcmpi(subselect, hObj.SubSelection)
  set(hObj, 'privSubSelection', subselect);
end

set(hObj, 'privSelection', selection);

notify(hObj, 'NewSelection', ...
  sigdatatypes.sigeventdataMCOS(hObj, 'NewSelection', selection));

end

% -------------------------------------------------------------------------
function subselect = setsubselection(hObj, subselect)

options = getsubselections(hObj);

% If there is only one input argument return the options
if nargin == 1
  out = options;
  return;
end

% If Subselection is empty set it, but only if there are no options
if isempty(subselect)
  if isempty([options{:}])
    subselect = '';
  else
    error(message('signal:siggui:selector:getnset:SubselectionSetToEmpty'))
  end
else
  indx = strmatch(subselect,options);
  switch length(indx)
    case 0
      error(message('signal:siggui:selector:getnset:SubselectionNotAvailable'));
    case 1
      subselect = options{indx};
    otherwise
      
      % See if we have an exact match, i.e. iirlpnorm and iirlpnormc
      if isempty(find(strcmpi(subselect, options), 1))
        matches = [];
        for i = 1:length(indx)
          matches = [matches '  ''' options{indx(i)} ''''];
        end
        error(message('signal:siggui:selector:getnset:SubselectionNotSpecific', matches));
      end
  end
end

set(hObj, 'privSubSelection', subselect);

% Send the NewSubSelection event
send(hObj, 'NewSubSelection', ...
  sigdatatypes.sigeventdata(hObj, 'NewSubSelection', subselect));

end

% -------------------------------------------------------------------------
function out = getselection(h, out)

out = get(h, 'privSelection');

end

% -------------------------------------------------------------------------
function out = getsubselection(h, out)

out = get(h, 'privSubSelection');

end


%------------------------------------------------------------------
function cshtags_listener(this, eventData)
%CSHTAGS_LISTENER Listener to the disabled selections property

update(this, 'update_cshtags');

end

%------------------------------------------------------------------
function disabledselections_listener(this, eventData)
%DISABLEDSELECTIONS_LISTENER Listener to the disabled selections property

update(this, 'update_enablestates');

end

%------------------------------------------------------------------
function identifiers_listener(this, eventData)
%IDENTIFIERS_LISTENER Listener to the identifiers property

tags = get(this, 'Identifiers');
h    = get(this, 'Handles');

% Loop through the tags because we don't know which one changed.
for i = 1:length(tags)
  
  if iscell(tags{i})
    set(h.radio(i), 'Tag', tags{i}{1});
    
    % The 1st tag is used for the Selection as the tag of the radio and popup
    set(h.popup(i), 'Tag', tags{i}{1}, 'UserData', {tags{i}{2:end}});
  else
    set(h.radio(i), 'Tag', tags{i});
  end
end

% If the current subselection doesn't match
subs = getsubselections(this);
if ~any(strcmpi(this.SubSelection, subs))
  if isempty(subs)
    set(this, 'privSubSelection', '');
  else
    set(this, 'privSubSelection', subs{1});
  end
end
% strings_listener(this);

end

%------------------------------------------------------------------
function selection_listener(this, eventData)
%SELECTION_LISTENER Listener to the Selection property

update(this, 'update_radiobtns');

end


%------------------------------------------------------------------
function subselection_listener(this, eventData)
%SUBSELECTION_LISTENER Listener to the subselection property

update(this, 'update_popup');

end

%------------------------------------------------------------------
function strings_listener(this, eventData)
%STRINGS_LISTENER Listener to the strings property

strs = getTranslatedStringcell('signal:sigtools:siggui',get(this, 'Strings'));
tags = get(this, 'Identifiers');
h    = get(this, 'Handles');

% Loop through the strings, since we don't know which one changed
for i = 1:length(strs)
  if iscell(strs{i})
    if difference(this, i)
      set(h.radio(i), 'String', '');
      popstr = strs{i};
    else
      set(h.radio(i), 'String', strs{i}{1});
      popstr = strs{i}(2:end);
    end
    visState = this.Visible;
  else
    set(h.radio(i), 'String', strs{i});
    visState = 'Off';
    popstr   = {''};
  end
  
  % Make sure that the value is still in the range.
  if get(h.popup(i), 'Value') > length(popstr)
    set(h.popup(i), 'Value', 1);
  end
  
  set(h.popup(i), 'String', popstr, 'Visible', visState);
end

resize_all_popup(this);
update(this, 'update_popup');

end

% ---------------------------------------------------------------------------
%
%                      Utility Functions
%
% ---------------------------------------------------------------------------

% ---------------------------------------------------------------------------
function resize_all_popup(this)

h     = get(this, 'Handles');

% If the frame is not rendered then we have nothing to base the resize on.
if isempty(h.frame), return; end

sz    = gui_sizes(this);

% Get the new largest uiwidth.
strings  = getstrings(h.popup);
newwidth = largestuiwidth(strings) + sz.rbwTweak;

origUnits = get(h.frame(1), 'Units'); set(h.frame(1), 'Units', 'Pixels');
framePos  = get(h.frame(1), 'Position'); set(h.frame(1), 'Units', origUnits);
origUnits = get(h.popup(1), 'Units'); set(h.popup(1), 'Units', 'Pixels');
popPos    = get(h.popup(1), 'Position'); set(h.popup(1), 'Units', origUnits);

% Make sure that the new largest width is inside the frame
if popPos(1) + newwidth > framePos(1) + framePos(3) - sz.hfus
  newwidth = framePos(3) + framePos(1) - popPos(1) - sz.hfus;
end

if newwidth > popPos(3)
  
  h = get(this, 'Handles');
  
  % Loop over the popups and set all their widths
  for indx = 1:length(h.popup)
    origUnits = get(h.popup(indx), 'Units'); set(h.popup(indx), 'Units', 'Pixels');
    pos = get(h.popup(indx), 'Position');
    pos(3) = newwidth;
    set(h.popup(indx), 'Position', pos, 'Units', origUnits);
  end
end

end

% ---------------------------------------------------------------------------
function strs = getstrings(hpop)

strs = get(hpop, 'String');

if ~iscell(strs), strs = {strs}; end

if ~iscellstr(strs)
  for i = 1:length(strs)
    strs{i} = strs{i}';
  end
  strs = [strs{:}];
  strs = strs(:);
end

end


% ----------------------------------------------------------------
function [frPos, ctrlPos] = parse_inputs(this, varargin)

hFig    = -1;
frPos   = {};
ctrlPos = {};
narginchk(1,4);

% Parse the inputs
for i = 1:length(varargin)
  if all(ishghandle(varargin{i})) && length(varargin{i}) == 1
    hFig = varargin{i};
  elseif isnumeric(varargin{i}) & iscell(frPos)
    frPos = varargin{i};
  elseif isnumeric(varargin{i})
    ctrlPos = varargin{i};
  else
    error(message('signal:siggui:selector:selector_render:InvalidInput', varargin{ i }))
  end
end

% Verify that the position vector is valid.
if iscell(frPos)
  frPos = [10 10 202 160];
elseif length(frPos) ~= 4 && ~isempty(frPos)
  error(message('signal:siggui:selector:selector_render:InvalidPositionVector', num2str( frPos )));
end

if isempty(ctrlPos)
  ctrlPos = frPos;
elseif length(ctrlPos) ~= 4 | any(ctrlPos <= 0)
  error(message('signal:siggui:selector:selector_render:InvalidPositionVector', num2str( ctrlPos )));
end

% If hFig is still -1 we need to get it from the object.
if ~ishghandle(hFig)
  hFig = get(this,'FigureHandle');
  if ~ishghandle(hFig), hFig = gcf;end
end

% If hFig is not -1, it must have been an input.  Save it in the object
set(this,'FigureHandle', hFig);

end

% --------------------------------------------------------
function width = getpopupwidth(strings)

string = {};

for i = 1:length(strings)
  if iscell(strings{i})
    string = {string{:}, strings{i}{:}};
  end
end

width = largestuiwidth(string,'popup');

end


% --------------------------------------------------------
function width = getradiowidth(this)

strings = get(this, 'Strings');

string = {};

for i = 1:length(strings)
  if iscell(strings{i})
    
    % If the length of the strings and the tags are the same, use it
    if ~difference(this, i)
      string = {string{:}, strings{i}{1}};
    end
  else
    string = {string{:}, strings{i}};
  end
end

width = largestuiwidth(string);

end

% --------------------------------------------------------
function rbtweak = gettweak(this)

% returns the extra rbtweak necessary to render the popups without covering
% radio button's label

strings = get(this, 'Strings');
string = {};

for i = 1:length(strings)
  
  if iscell(strings{i}) & ~difference(this, i)
    string{end+1} = strings{i}{1};
  end
end

if isempty(string)
  rbtweak = 0;
else
  rbtweak = largestuiwidth(string);
end

end


% ---------------------------------------------------------------------
function [tag, tags, strs] = parse_inputs2(hSct, varargin)

narginchk(4,4);

tag  = varargin{1};
tags = varargin{2};
strs = varargin{3};

validate_inputs2(tags, strs);

end

% --------------------------------------------------------------------
function validate_inputs2(tags, strs)

if ~any(length(tags)-length(strs) == [0 1])
  error(message('signal:siggui:selector:setgroup:SigErr'));
end

end


% ---------------------------------------------------------------
function update_all(this)

update_enablestates(this);
update_popup(this);
update_radiobtns(this);
update_cshtags(this);

end

% ---------------------------------------------------------------
function update_enablestates(this)
%UPDATE_ENABLESTATES Update the enable states of the selector

enabState = get(this, 'Enable');
h         = get(this, 'Handles');

% If the enable state of the property is off, then the whole frame is off.
if strcmpi(enabState, 'off')
  setenableprop(h.popup, enabState, false);
  setenableprop(h.radio, enabState, false);
else
  dSelects = get(this,'DisabledSelections');
  
  % Loop over all the radio buttons and compare the tags to the dSelects string
  % vector to determine enable state
  for i = 1:length(h.radio)
    tag = get(h.radio(i),'Tag');
    if ~isempty(strmatch(tag,dSelects))
      enabState = 'Off';
    else
      enabState = 'On';
    end
    setenableprop(h.popup(i), enabState, false);
    setenableprop(h.radio(i), enabState, false);
  end
end

end

% ---------------------------------------------------------------
function update_popup(this)
%UPDATE_POPUP Update the currently selected popup of the selector

selection = get(this, 'Selection');
subselect = get(this, 'SubSelection');
h         = get(this, 'Handles');

hPop = [];
if ~isempty(h.popup)
  
  % Find a popup with the tag matching the selection.
  hPop = findobj(h.popup, 'Tag', selection);
end

if ~isempty(hPop)
  
  % Find the popup entry with the tag matching the subselection
  tags = get(hPop,'UserData');
  indx = find(strcmpi(subselect,tags));
  
  if isempty(indx)
    indx = 1;
  end
  set(hPop,'Value',indx);
end

end

% ---------------------------------------------------------------
function update_radiobtns(this)
%UPDATE_RADIOBTNS Update the radiobuttons of the Selector

h   = get(this,'Handles');
sel = get(this,'Selection');

% Deactivate all the radio buttons
set(h.radio,'Value',0);
hOn = findobj(h.radio,'tag',sel);

% Activate the radio button that matches the current selection.
set(hOn,'Value',1);

end

% ---------------------------------------------------------------
function update_cshtags(this)

h = get(this, 'Handles');

tags = get(this, 'CSHTags');

for indx = 1:min(length(tags), length(h.radio))
  cshelpcontextmenu(h.radio(indx), tags{indx}, 'fdatool');
  cshelpcontextmenu(h.popup(indx), tags{indx}, 'fdatool');
end

end
