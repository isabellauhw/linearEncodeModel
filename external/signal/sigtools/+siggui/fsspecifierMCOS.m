classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) fsspecifierMCOS < siggui.sigguiMCOS & hgsetget
  %siggui.fsspecifier class
  %   siggui.fsspecifier extends siggui.siggui.
  %
  %    siggui.fsspecifier properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Units - Property is of type 'signalFrequencyUnits enumeration: {'Normalized (0 to 1)','Hz','kHz','MHz','GHz'}'
  %       Value - Property is of type 'string'
  %
  %    siggui.fsspecifier methods:
  %       getfs - Returns the Sampling Frequency structure
  %       getfsvalue - Returns the Fs specified in Hz.
  %       thisrender - RENDER Render the Sampling Frequency Specifier

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %UNITS Property is of type 'signalFrequencyUnits enumeration: {'Normalized (0 to 1)','Hz','kHz','MHz','GHz'}'
    Units = 'Normalized (0 to 1)';
    %VALUE Property is of type 'string'
    Value = 'Fs';
  end
  
  methods  % constructor block
    function hFs = fsspecifierMCOS
      %FSSPECIFIER Constructor for the sampling frequency specifier

      narginchk(0,0);

      setstate(hFs,defaultfs);
      hFs.Version = 1;
    end  % fsspecifier
    
    % -----------------------------------------------------
    
  end  % constructor block
  
  methods
    function set.Units(obj,value)
      % Enumerated DataType = 'signalFrequencyUnits enumeration: {'Normalized (0 to 1)','Hz','kHz','MHz','GHz'}'
      value = validatestring(value,{'Normalized (0 to 1)','Hz','kHz','MHz','GHz'},'','Units');
      obj.Units = value;
    end
    
    function set.Value(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Value');
      obj.Value = value;
    end
    
    function values = getAllowedStringValues(~,prop)
      % This function gives the the valid string values for object properties.
      
      switch prop
        case 'Units'
          values = {...
            'Normalized (0 to 1)'
            'Hz'
            'kHz'
            'MHz'
            'GHz'};
          
        otherwise
          values = {};
      end
      
    end
    
    function varargout = set(obj,varargin)
      [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function fs = getfs(hFs)
      %GETFS Returns the Sampling Frequency structure

      fs = getstate(hFs);
      
      if strcmpi(fs.Units,'normalized (0 to 1)')
        fs.value = [];
      else
        fs.value = evaluatevars(fs.Value);
      end
      
      fs.units = fs.Units;
      
      fs = rmfield(fs, {'Value', 'Units'});
      
    end
    
    function fs = getfsvalue(hObj, fs)
      %GETFSVALUE Returns the Fs specified in Hz.

      if nargin < 2
        fs = getfs(hObj);
      end
      if isfield(fs, 'Units'), fs.units = fs.Units; end
      if isfield(fs, 'Value'), fs.value = fs.Value; end
      
      if ~strncmpi(fs.units, 'normalized', 10)
        fs = convertfrequnits(fs.value, fs.units, 'Hz');
      else
        fs = [];
      end
      
    end
    
    
    function thisrender(this, varargin)
      %RENDER Render the Sampling Frequency Specifier

      frpos = parserenderinputs(this, varargin{:});
      
      sz   = gui_sizes(this);
      bgc  = get(0,'DefaultUicontrolBackgroundColor');
      hFig = get(this,'FigureHandle');
      cbs  = siggui_cbs(this);
      
      if isempty(frpos), frpos = [10 10 160 sz.uh*3+sz.uuvs]*sz.pixf; end
      
      % Title Position
      pos = [frpos(1)+5 frpos(2)+frpos(4)-sz.uh frpos(3)-sz.hfus sz.uh];
      
      h.fstitle = uicontrol(hFig,...
        'Style',              'text',...
        'Position',           pos,...
        'Visible',            'Off',...
        'String',             getString(message('signal:sigtools:siggui:SamplingFrequency1')),...
        'Tag',                'fsspecifier_title',...
        'HorizontalAlignment','left');
      
      % Label Position
      lbl = getString(message('signal:sigtools:siggui:Units'));
      pos(3) = largestuiwidth ({lbl});
      pos(2) = pos(2)-sz.uh;
      
      h.units_lbl = uicontrol(hFig,...
        'Style',               'text',...
        'Position',            pos,...
        'Visible',             'Off',...
        'String',              lbl, ...
        'Tag',                 'fsspecifier_popup_lbl',...
        'HorizontalAlignment', 'right');
      
      pos(2) = pos(2) - sz.uh - sz.uuvs;
      h.value_lbl = uicontrol(hFig,...
        'Style',               'text',...
        'Position',            pos,...
        'Visible',             'Off',...
        'String',              'Fs:',...
        'Tag',                 'fsspecifier_editbox_lbl',...
        'HorizontalAlignment', 'right');
      
      pos    = get(h.units_lbl, 'Position');
      pos(1) = pos(1)+pos(3)+sz.uuhs;
      pos(3) = 113*sz.pixf;
      
      if pos(3) + pos(1) > frpos(1)+frpos(3)
        pos(3) = frpos(3)-pos(1)+frpos(1);
      end
      
      % Untranslated and translated strings
      strU = set(this,'Units');
      strT = getTranslatedStringcell('signal:siggui:labelsandvalues:updateuis',strU);
      
      h.units = uicontrol(hFig, ...
        'Style',           'popup', ...
        'BackgroundColor', 'White', ...
        'Position',        pos,...
        'String',          strT, ...
        'Tag',             'fsspecifier_popup', ...
        'Visible',         'Off', ...
        'Callback',        {cbs.property, this, 'Units', 'change Fs units'});
      
      % Save untranslated strings in the app data for use in the callback
      setappdata(h.units, 'PopupStrings', strU);
      
      % Edit box position
      pos(2) = pos(2) - sz.uh - sz.uuvs;
      
      h.value = uicontrol(hFig,...
        'Style',               'edit',...
        'BackgroundColor',     'white',...
        'Position',            pos,...
        'Tag',                 'fsspecifier_editbox',...
        'Visible',             'Off',...
        'String',              this.Value,...
        'HorizontalAlignment', 'left',...
        'Callback',            {cbs.property, this, 'Value', 'change Fs'});
      
      set(this,'Handles',h);
      
      wrl(1) = event.proplistener(this, this.findprop('Units'),'PostSet', @(s,e)lclprop_listener(this,e));
      wrl(2) = event.proplistener(this, this.findprop('Value'),'PostSet', @(s,e)lclprop_listener(this,e));
      
      set(this,'WhenRenderedListeners',wrl);
      
      prop_listener(this, 'Units');
      
      setupenablelink(this, 'Units', {'hz', 'khz','mhz','ghz'}, 'value');
      
    end
    
  end  %% public methods
  
end  % classdef

function specs = defaultfs

specs.Units = 'Normalized (0 to 1)';
specs.Value = 'Fs';
end  % defaultfs

% -------------------------------------------------------------------------
function lclprop_listener(this, eventData)

prop_listener(this, eventData);

end
