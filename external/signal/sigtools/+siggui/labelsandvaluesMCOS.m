classdef labelsandvaluesMCOS < siggui.sigguiMCOS & matlab.mixin.SetGet
  %siggui.labelsandvalues class
  %   siggui.labelsandvalues extends siggui.siggui.
  %
  %    siggui.labelsandvalues properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Maximum - Property is of type 'double' (read only)
  %       Values - Property is of type 'string vector'
  %       Labels - Property is of type 'string vector'
  %       HiddenLabels - Property is of type 'posint_vector user-defined'
  %       HiddenValues - Property is of type 'posint_vector user-defined'
  %       DisabledValues - Property is of type 'posint_vector user-defined'
  %
  %    siggui.labelsandvalues methods:
  %       enable_listener - Listener to the enable property.
  %       thisrender -  Render the labels and values uicontrols
  %       update_uis - updates visibility of the labels and value uicontrols
  %       visible_listener - is the abstract class's implementation of the enable listener
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %VALUES Property is of type 'string vector'
    Values
    %LABELS Property is of type 'string vector'
    Labels
    %HIDDENLABELS Property is of type 'posint_vector user-defined'
    HiddenLabels = [];
    %HIDDENVALUES Property is of type 'posint_vector user-defined'
    HiddenValues = [];
    %DISABLEDVALUES Property is of type 'posint_vector user-defined'
    DisabledValues = [];
  end
  
  properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
    %MAXIMUM Property is of type 'double' (read only)
    Maximum = 4;
  end
  
  
  methods  % constructor block
    function h = labelsandvaluesMCOS(varargin)
      %LABELSANDVALUES  Constructor for this class
      
      %   Author(s): Z. Mecklai, J. Schickler
      
      set(h, varargin{:});
      
      % Set the version and tag
      h.Version = 1.0;
      settag(h);
      
      
    end  % labelsandvalues
    
    function set.Maximum(obj,value)
      % DataType = 'double'
      validateattributes(value,{'double'}, {'scalar'},'','Maximum')
      obj.Maximum = value;
    end
    
    function set.Values(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.Values = setstrings(obj,value);
    end
    
    function set.Labels(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.Labels = setstrings(obj,value);
    end
    
    function set.HiddenLabels(obj,value)
      % User-defined DataType = 'posint_vector user-defined'
      obj.HiddenLabels = setlengths(obj,value);
    end
    
    function set.HiddenValues(obj,value)
      % User-defined DataType = 'posint_vector user-defined'
      obj.HiddenValues = setlengths(obj,value);
    end
    
    function set.DisabledValues(obj,value)
      % User-defined DataType = 'posint_vector user-defined'
      obj.DisabledValues = setlengths(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    
    function enable_listener(this, eventData)
      %ENABLE_LISTENER Listener to the enable property.
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      dvalues = get(this, 'DisabledValues');
      
      h = get(this, 'Handles');
      
      loff = h.labels(dvalues);
      setenableprop(loff, 'Off');
      voff = h.values(dvalues);
      setenableprop(voff, 'Off');
      
      setenableprop(setdiff(h.labels, loff), this.Enable, false);
      setenableprop(setdiff(h.values, voff), this.Enable, false);
      
    end
    
    %--------------------------------------------------------------------------
    function thisrender(this, hFig, pos, lblwidth, type)
      %THISRENDER  Render the labels and values uicontrols
      %   It is assumed that this is not going be rendered by itself
      %   and so it is safe to call upon the figure and frame as already
      %   existing.
      %
      %   THISRENDER(H, HFIG, POS, LBLWIDTH, TYPE)
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      narginchk(3,5);
      
      % Store the figure handle
      set(this, 'FigureHandle', hFig);
      
      m   = get(this, 'Maximum');
      sz  = gui_sizes(this);
      
      width = pos(3);
      
      if nargin < 4, lblwidth = 40*sz.pixf; end
      if nargin < 5, type = false; end
      
      valwidth = min(lblwidth, width-lblwidth);
      
      left = width-lblwidth-valwidth;
      lblwidth = lblwidth+left*.15;
      valwidth = valwidth+left*.85;
      
      lblpos  = [pos(1) pos(2)+pos(4) lblwidth sz.uh];
      editpos = [pos(1)+lblpos(3) lblpos(2) valwidth sz.uh];
      lblpos(2) = lblpos(2)-sz.lblTweak;
      
      if type
        skip = (pos(4)-m*sz.uh)/(m+1);
      else
        if m == 1, skip = 0;
        else       skip = (pos(4)-m*sz.uh)/m; end
        lblpos(2) = lblpos(2)+skip;
        editpos(2) = editpos(2)+skip;
      end
      commonprops = {'HorizontalAlignment', 'Left', 'Visible', 'Off'};
      
      % Make the labels take up all the "skipped" space.  In this way we can
      % prevent as much clipping of translated text as possible.
      lblpos(2) = lblpos(2)-skip; lblpos(4) = lblpos(4)+skip;
      
      for indx = 1:m
        lblpos(2)  = lblpos(2)-skip-sz.uh;
        editpos(2) = editpos(2)-skip-sz.uh;
        
        h.labels(indx) = uicontrol(hFig, commonprops{:}, ...
          'Position', lblpos, ...
          'Tag', sprintf('label%d', indx), ...
          'Style', 'Text');
        h.values(indx) = uicontrol(hFig, commonprops{:}, ...
          'Position', editpos, ...
          'Style', 'Edit', ...
          'BackgroundColor', 'w', ...
          'Tag', sprintf('value%d', indx), ...
          'Callback', {@value_cb, this, indx});
        
        setappdata(h.values(indx), 'index', indx);
      end
      
      set(this, 'Handles', h);
      
      l = [ ...
        event.proplistener(this, [this.findprop('values'), this.findprop('labels'), ...
        this.findprop('HiddenValues') this.findprop('HiddenLabels')], ...
        'PostSet', @(s,e)values_labels_listener(this,e));
        event.proplistener(this, this.findprop('DisabledValues'), 'PostSet', ...
        @(s,e)disabledvalues_listener(this,e)) ...
        ];
      
      
      % Store the listeners in the WhenRenderedListeners property of the superclass
      this.WhenRenderedListeners = l;
      
      values_labels_listener(this);
      enable_listener(this);
      
    end
    
    %--------------------------------------------------------------------------
    function update_uis(this)
      %SUPER_UPDATE_UIS updates visibility of the labels and value uicontrols
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % Determine the object state
      visstate = get(this, 'Visible');
      
      % Get the necessary data and turn the values
      % and labels to the current visstate
      h = get(this, 'Handles');
      
      % Extract the actual specification values and labels
      labels = get(this, 'Labels');
      values = get(this, 'Values');
      
      % First set everything to invisible and turn on as appropriate
      set(h.labels(union(this.HiddenLabels, (length(labels)+1):this.Maximum)), ...
        'Visible','off')
      set(h.values(union(this.HiddenValues, (length(values)+1):this.Maximum)), ...
        'Visible','off')
      
      for i = 1:length(values)
        if ~any(i == this.HiddenValues)
          set(h.values(i),...
            'Visible',visstate,...
            'String',values{i});
        end
      end
      
      for i = 1:length(labels)
        if ~any(i == this.HiddenLabels)
          set(h.labels(i),...
            'Visible',visstate,...
            'String',getTranslatedString('signal:siggui:labelsandvalues:updateuis',labels{i}));
        end
      end
      
    end
    
    %--------------------------------------------------------------------------
    function visible_listener(h, eventData)
      %VISIBLE_LISTENER is the abstract class's implementation of the enable listener
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      % Get the vis state
      visState = get(h, 'Visible');
      
      if strcmp(visState, 'off')
        set(handles2vector(h), 'Visible', 'off');
      else
        update_uis(h);
      end
    end
    
  end  %% public methods
  
end  % classdef

%--------------------------------------------------------------------------
function out = setlengths(this, out)

idx = find(out > this.Maximum);
out(idx) = [];
end  % setlengths


%--------------------------------------------------------------------------
function out = setstrings(this, out)

m = get(this, 'Maximum');

if length(out) > m
  error(message('signal:siggui:labelsandvalues:schema:TooManyStrings', m))
end
end  % setstrings


% -------------------------------------------------------------------------
function values_labels_listener(this, eventData) %#ok

if strcmpi(this.Visible, 'on'), update_uis(this); end

end

% -------------------------------------------------------------------------
function disabledvalues_listener(this, eventData) %#ok

enable_listener(this);

end

% -------------------------------------------------------------------------
function value_cb(hcbo, eventData, this, indx) %#ok

vals = get(this, 'Values');
vals(indx) = fixup_uiedit(hcbo);
set(this, 'Values', vals);
notify(this, 'UserModifiedSpecs');

end

% [EOF]
