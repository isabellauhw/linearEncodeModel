classdef (CaseInsensitiveProperties=true) masklinedlg < siggui.helpdialogMCOS
  %siggui.masklinedlg class
  %   siggui.masklinedlg extends siggui.helpdialog.
  %
  %    siggui.masklinedlg properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       EnableMask - Property is of type 'bool'
  %       NormalizedFrequency - Property is of type 'bool'
  %       FrequencyVector - Property is of type 'string'
  %       MagnitudeUnits - Property is of type 'MagnitudeUnitTypes enumeration: {'dB','Linear','Squared'}'
  %       MagnitudeVector - Property is of type 'string'
  %       FrequencyUnits - Property is of type 'string'
  %
  %    siggui.masklinedlg methods:
  %       getmaskline -   Get the maskline.
  %       help -   Help for the dialog.
  %       propmod_listener -   Listener to 'propmod'.
  %       setmaskline -   Set the maskline.
  %       setup_figure -   Set up the figure.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %ENABLEMASK Property is of type 'bool'
    EnableMask
    %NORMALIZEDFREQUENCY Property is of type 'bool'
    NormalizedFrequency
    %FREQUENCYVECTOR Property is of type 'string'
    FrequencyVector = '';
    %MAGNITUDEUNITS Property is of type 'MagnitudeUnitTypes enumeration: {'dB','Linear','Squared'}'
    MagnitudeUnits = 'dB';
    %MAGNITUDEVECTOR Property is of type 'string'
    MagnitudeVector = '';
    %FREQUENCYUNITS Property is of type 'string'
    FrequencyUnits = 'Hz';
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %LISTENER Property is of type 'handle.listener'
    Listener = [];
  end
  
  
  methods  % constructor block
    function this = masklinedlg
      %MASKLINEDLG   Construct a MASKLINEDLG object.
      
      %   Author(s): J. Schickler

      % Set this object with the default maskline object.
      setmaskline(this, dspdata.masklineMCOS);
      l = event.proplistener(this, [this.findprop('FrequencyVector') ...
        this.findprop('MagnitudeVector') this.findprop('MagnitudeUnits') ...
        this.findprop('EnableMask') this.findprop('NormalizedFrequency')], ...
        'PostSet', @(s,e)propmod_listener(this,e));
      set(this, 'Listener', l);
      
      
    end  % masklinedlg
    
  end  % constructor block
  
  methods
    function set.EnableMask(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical','numeric'}, {'scalar'},'','EnableMask')
      obj.EnableMask = value;
    end
    
    function set.NormalizedFrequency(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical','numeric'}, {'scalar'},'','NormalizedFrequency')
      obj.NormalizedFrequency = value;
    end
    
    function set.FrequencyVector(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','FrequencyVector')
      obj.FrequencyVector = value;
    end
    
    function set.MagnitudeUnits(obj,value)
      % Enumerated DataType = 'MagnitudeUnitTypes enumeration: {'dB','Linear','Squared'}'
      value = validatestring(value,{'dB','Linear','Squared'},'','MagnitudeUnits');
      obj.MagnitudeUnits = value;
    end
    
    function set.MagnitudeVector(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','MagnitudeVector')
      obj.MagnitudeVector = value;
    end
    
    function set.FrequencyUnits(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','FrequencyUnits')
      obj.FrequencyUnits = value;
    end
    
    function set.Listener(obj,value)
      % DataType = 'event.listener'
      if ~isempty(value)
        validateattributes(value,{'event.listener'}, {'scalar'},'','Listener')
      end
      obj.Listener = value;
    end
    
  end   % set and get functions
  
  methods  % public methods
    function maskline = getmaskline(this)
      %GETMASKLINE   Get the maskline.

      maskline = dspdata.masklineMCOS(...
        'EnableMask',          this.EnableMask, ...
        'NormalizedFrequency', this.NormalizedFrequency, ...
        'FrequencyVector',     evaluatevars(this.FrequencyVector), ...
        'MagnitudeUnits',      this.MagnitudeUnits, ...
        'MagnitudeVector',     evaluatevars(this.MagnitudeVector));
      
    end
    
    
    function help(this)
      %HELP   Help for the dialog.

      helpview(fullfile(docroot,'toolbox','signal','signal.map'), ...
        'fdatool_maskline_dialog');
      
    end
    
    
    function propmod_listener(this, eventData)
      %PROPMOD_LISTENER   Listener to 'propmod'.      

      set(this, 'isApplied', false);
      
    end
    
    
    function setmaskline(this, maskline)
      %SETMASKLINE   Set the maskline.

      set(this, 'EnableMask',    maskline.EnableMask, ...
        'NormalizedFrequency', maskline.NormalizedFrequency, ...
        'FrequencyVector',     mat2str(maskline.FrequencyVector), ...
        'MagnitudeUnits',      maskline.MagnitudeUnits, ...
        'MagnitudeVector',     mat2str(maskline.MagnitudeVector), ...
        'isApplied',           true);
            
    end
    
    
    function setup_figure(this)
      %SETUP_FIGURE   Set up the figure.

      sz = gui_sizes(this);
      
      hFig = figure('Visible', 'Off', ...
        'MenuBar', 'none', ...
        'HandleVisibility', 'off', ...
        'IntegerHandle', 'off', ...
        'NumberTitle', 'Off', ...
        'Color', get(0, 'DefaultUicontrolBackgroundColor'), ...
        'Name', getString(message('signal:sigtools:siggui:UserdefinedSpectralMask')), ...
        'Position', [100 100 300 200]*sz.pixf);
      
      set(this, 'FigureHandle', hFig);
      
    end
    
    
  end  % public methods
  
  
  methods (Hidden) % possibly private or hidden
    function render_controls(this)
      %RENDER_CONTROLS
      
      %   Author(s): J. Schickler
      %   Copyright 2004-2005 The MathWorks, Inc.
      
      sz = dialog_gui_sizes(this);
      
      this.Container = uipanel('Parent', this.Parent, ...
        'Units', 'Pixels', ...
        'Position', sz.controls);
      
      rendercontrols(this, sz.controls-[sz.controls(1:2) 0 0], {'EnableMask', ...
        'NormalizedFrequency', 'FrequencyVector', 'MagnitudeUnits', 'MagnitudeVector'});
      
      hLayout = siglayout.gridbaglayout(this.Parent, ...
        'VerticalWeights',   [1 0], ...
        'HorizontalWeights', [1 0 0 0], ...
        'HorizontalGap',     5*sz.pixf, ...
        'VerticalGap',       5*sz.pixf);
      
      hLayout.add(this.Container, 1, [1 4], ...
        'Fill', 'Both');
      
      width = get(this.DialogHandles.ok, 'Position');
      width = width(3);
      
      hLayout.add(this.DialogHandles.ok, 2, 1, ...
        'Anchor', 'East', ...
        'MinimumWidth', width);
      
      hLayout.add(this.DialogHandles.cancel, 2, 2, ...
        'MinimumWidth', width);
      
      hLayout.add(this.DialogHandles.help, 2, 3, ...
        'MinimumWidth', width);
      
      hLayout.add(this.DialogHandles.apply, 2, 4, ...
        'MinimumWidth', width);
      
      hLayout = siglayout.gridbaglayout(this.Container, ...
        'VerticalWeights',   [0 0 0 0 1], ...
        'HorizontalWeights', [0 1 0], ...
        'VerticalGap',       5*sz.pixf, ...
        'HorizontalGap',     5*sz.pixf);
      
      h = get(this, 'Handles');
      
      % Add a label to show the frequency units.
      h.frequencyunits = uicontrol(this.Container, ...
        'Style', 'text', ...
        'HorizontalAlignment', 'Left', ...
        'String', '0 to 1');
      
      hLayout.add(h.enablemask, 1, [1 3], ...
        'TopInset', 2*sz.pixf, ...
        'Anchor', 'West', ...
        'PreferredWidth', largestuiwidth(h.enablemask)+20*sz.pixf);
      hLayout.add(h.normalizedfrequency, 2, [1 3], ...
        'Anchor', 'West', ...
        'PreferredWidth', largestuiwidth(h.normalizedfrequency)+20*sz.pixf);
      hLayout.add(h.frequencyvector_lbl, 3, 1, ...
        'TopInset', 3*sz.pixf, ...
        'Anchor', 'West', ...
        'MinimumWidth', largestuiwidth(h.frequencyvector_lbl));
      hLayout.add(h.frequencyvector, 3, 2, ...
        'Fill', 'Horizontal');
      hLayout.add(h.frequencyunits, 3, 3, ...
        'RightInset', 5*sz.pixf, ...
        'TopInset',   5*sz.pixf, ...
        'MinimumWidth', largestuiwidth(h.frequencyunits));
      hLayout.add(h.magnitudeunits_lbl, 4, 1, ...
        'TopInset', 3*sz.pixf, ...
        'Anchor', 'West', ...
        'MinimumWidth', largestuiwidth(h.magnitudeunits_lbl));
      hLayout.add(h.magnitudeunits, 4, [2 3], ...
        'RightInset', 5*sz.pixf, ...
        'Fill', 'Horizontal');
      hLayout.add(h.magnitudevector_lbl, 5, 1, ...
        'TopInset', 3*sz.pixf, ...
        'Anchor', 'NorthWest', ...
        'MinimumWidth', largestuiwidth(h.magnitudevector_lbl));
      hLayout.add(h.magnitudevector, 5, [2 3], ...
        'RightInset', 5*sz.pixf, ...
        'Anchor', 'North', ...
        'Fill', 'Horizontal');
      
      set(this, 'Handles', h);
      set(handles2vector(this), 'Visible', 'On');
      
      % Add a listener to update the frequencyunits label.
      l = get(this, 'WhenRenderedListeners');
      l(end+1) = event.proplistener(this, this.findprop('FrequencyUnits'), 'PostSet', @(s,e)frequencyunits_listener(this,e));
      l(end+1) = event.proplistener(this, this.findprop('NormalizedFrequency'), 'PostSet', @(s,e)frequencyunits_listener(this,e));
      
      set(this, 'WhenRenderedListeners', l);
      
      % Update the frequency units label.
      frequencyunits_listener(this);
    end
    
  end
  
end  % classdef


% -------------------------------------------------------------------------
function frequencyunits_listener(this, eventData)

h = get(this, 'Handles');

if this.NormalizedFrequency
  str = getString(message('signal:sigtools:siggui:Normalized0to1'));
else
  str = this.FrequencyUnits;
end

set(h.frequencyunits, 'String', str);

end
