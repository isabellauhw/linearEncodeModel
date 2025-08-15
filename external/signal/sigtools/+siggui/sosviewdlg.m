classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) sosviewdlg < siggui.helpdialogMCOS & hgsetget & matlab.mixin.Copyable
  %trial.sosviewdlg class
  %    trial.sosviewdlg properties:
  %       ViewType - Property is of type 'sosviewtypes enumeration: {'Complete','Individual','Cumulative','UserDefined'}'
  %       Custom - Property is of type 'string'
  %       SecondaryScaling - Property is of type 'on/off'
  %
  %    trial.sosviewdlg methods:
  %       action -   Test the settings.
  %       enable_listener -   Listener to the Enable property.
  %       getopts -   Get the opts.
  %       help -   Display the help for the SOS View dialog.
  %       newselection_listener -   Listener to the NewSelection event.
  %       setopts -   Set the opts.
  %       setup_figure -   Set up the figure for the SOSVIEWDLG
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %VIEWTYPE Property is of type 'sosviewtypes enumeration: {'Complete','Individual','Cumulative','UserDefined'}'
    ViewType
    %CUSTOM Property is of type 'string'
    Custom = '{1, 1:2}';
    %SECONDARYSCALING Property is of type 'on/off'
    SecondaryScaling = 'off';
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %USERMODIFIEDLISTENER Property is of type 'handle.listener vector'
    UserModifiedListener
  end
  
  
  methods  % constructor block
    function this = sosviewdlg
      %SOSVIEWDLG   Construct a SOSVIEWDLG object.

      hs = siggui.selectorMCOS(getString(message('signal:sigtools:siggui:View')),...
        {'Complete';'Individual';'Cumulative';'UserDefined'}, ...
        {getString(message('signal:sigtools:siggui:OverallFilter')), ...
        getString(message('signal:sigtools:siggui:IndividualSections')), ...
        getString(message('signal:sigtools:siggui:CumulativeSections')), ...
        getString(message('signal:sigtools:siggui:UserDefined'))});
      
      addcomponent(this, hs);
      
      l(1) = event.listener(hs, 'NewSelection', @(s,e)usermodified_listener(this,e));
      l(2) = event.proplistener(this, this.findprop('SecondaryScaling'), 'PostSet', @(s,e)usermodified_listener(this,e));
      l(3) = event.proplistener(this, this.findprop('Custom'), 'PostSet', @(s,e)usermodified_listener(this,e));
      
      set(this, 'UserModifiedListener', l);
      
      set(this, 'isApplied', true);
      
      
    end  % sosviewdlg
    
  end  % constructor block
  
  methods
    function value = get.ViewType(obj)
      value = getviewtype(obj,obj.ViewType);
    end
    function set.ViewType(obj,value)
      % Enumerated DataType = 'sosviewtypes enumeration: {'Complete','Individual','Cumulative','UserDefined'}'
      value = validatestring(value,{'Complete','Individual','Cumulative','UserDefined'},'','ViewType');
      obj.ViewType = setviewtype(obj,value);
    end
    
    function set.Custom(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Custom')
      obj.Custom = value;
    end
    
    function value = get.SecondaryScaling(obj)
      value = get_secondaryscaling(obj,obj.SecondaryScaling);
    end
    function set.SecondaryScaling(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','SecondaryScaling');
      obj.SecondaryScaling = value;
    end
    
    function set.UserModifiedListener(obj,value)
      % DataType = 'handle.listener vector'
      if ~isempty(value)
        validateattributes(value,{'event.listener'}, {'vector'},'','UserModifiedListener');
      end
      obj.UserModifiedListener = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function success = action(this)
      %ACTION   Test the settings.

      success = true;
      
      % Test that the 'Custom' entry is valid.
      if strcmpi(this.ViewType, 'userdefined')
        try
          % Ask for an output from evalin so that we do not get the values
          % echoed to the command line. g381461
          suppress = evalin('base', this.Custom); %#ok
        catch ME
          throwAsCaller(ME)
        end
      end
      
    end
    
    
    function enable_listener(this, varargin)
      %ENABLE_LISTENER   Listener to the Enable property.

      hall = get(this, 'Handles');
      
      set(this, 'Handles', rmfield(hall, 'custom'));
      dialog_enable_listener(this, varargin{:});
      set(this, 'Handles', hall);
      
      newselection_listener(this);
      
      
    end
    
    
    function opts = getopts(this, opts)
      %GETOPTS   Get the opts.
 
      % If an options is passed in use it, otherwise create a new one.
      if nargin < 2
        opts = dspopts.sosview;
      end
      if isempty(opts)
        opts = dspopts.sosview;
      end
      
      % Convert the 'on/off' property to a boolean.
      if strcmpi(this.SecondaryScaling, 'on')
        ss = true;
      else
        ss = false;
      end
      
      
      opts.View = this.ViewType;
      opts.UserDefinedSections = evalin('base', this.Custom);
      opts.SecondaryScaling = ss;
      
    end
    
    
    function help(this)
      %HELP   Display the help for the SOS View dialog.

      helpview(fullfile(docroot,'toolbox','dsp','dsp.map'), ...
        'sosview');
      
    end
    
    
    function newselection_listener(this, eventData)
      %NEWSELECTION_LISTENER   Listener to the NewSelection event.

      switch lower(this.ViewType)
        case 'userdefined'
          enab1 = this.Enable;
          enab2 = 'off';
        case 'cumulative'
          enab1 = 'off';
          enab2 = this.Enable;
        otherwise
          enab1 = 'off';
          enab2 = 'off';
      end
      
      setenableprop(this.Handles.custom, enab1);
      setenableprop(this.Handles.secondaryscaling, enab2);
      prop_listener(this, 'SecondaryScaling');
      
      
    end
    
    
    function setopts(this, opts)
      %SETOPTS   Set the opts.

      type = lower(get(opts, 'View'));
      
      this.ViewType = type;
      switch type
        case 'custom'
          custom = get(opts, 'UserDefinedSections');
          
          % Format the custom settings into a string.
          if iscell(custom)
            customstr = '{';
            for indx = 1:length(custom)
              customstr = sprintf('%s%s, ', customstr, mat2str(custom{indx}));
            end
            customstr(end-1:end) = [];
            customstr = sprintf('%s}', customstr);
            
          else
            customstr = mat2str(custom);
          end
          
          set(this, 'Custom', customstr);
        case 'cumulative'
          
          % Convert the boolean secondaryscaling to 'on/off'
          if opts.SecondaryScaling
            ss = 'on';
          else
            ss = 'off';
          end
          set(this, 'SecondaryScaling', ss);
      end
      
      this.isApplied = true;
      set(this, 'isApplied', true);
      
    end
    
    function setup_figure(this)
      %SETUP_FIGURE   Set up the figure for the SOSVIEWDLG

      sz = gui_sizes(this);
      cbs = dialog_cbs(this);
      
      this.FigureHandle = figure('MenuBar', 'none', ...
        'Position', [200 200 340 215]*sz.pixf, ...
        'HandleVisibility', 'Off', ...
        'Visible', 'Off', ...
        'Resize', 'Off', ...
        'NumberTitle', 'Off', ...
        'Name', getString(message('signal:sigtools:siggui:SOSViewSettings')), ...
        'Color', get(0, 'DefaultUicontrolBackgroundColor'), ...
        'CloseRequestFcn', cbs.cancel);
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function render_controls(this)
      %RENDER_CONTROLS
 
      sz = dialog_gui_sizes(this);
      
      h = getcomponent(this, '-class', 'siggui.selectorMCOS');
      
      sz.controls(4) = sz.controls(4)-sz.vfus*2;
      
      cpos = sz.controls;
      cpos(2) = cpos(2)+2*sz.uh+2*sz.uuvs;
      cpos(4) = cpos(4)-2*sz.uh-2*sz.uuvs;
      
      render(h, this.FigureHandle, sz.controls, cpos);
      
      cpos = sz.controls;
      cpos(2) = cpos(2)+sz.vfus;
      cpos(4) = sz.uh*2+2*sz.uuvs;
      
      rendercontrols(this, cpos, {'Custom', 'SecondaryScaling'}, {'', ...
        getString(message('signal:sigtools:siggui:Usesecondaryscalingpoints'))});
      
      l = event.listener(h, 'NewSelection', @(s,e)newselection_listener(this,e));
      set(this, 'WhenRenderedListeners', union(this.WhenRenderedListeners, l));
      
      newselection_listener(this);
      
      % Turn all the children on since this is a dialog.
      set(handles2vector(this), 'Visible', 'On');
      set(h, 'Visible','on');
      
    end
    
    function usermodified_listener(this, eventData)
      %USERMODIFIED_LISTENER

      set(this, 'isApplied', false);
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

% -------------------------------------------------------------------------
function ss = get_secondaryscaling(this, ss)

if ~strcmpi(get(this, 'ViewType'), 'cumulative')
  ss = 'off';
end

end

% -------------------------------------------------------------------------
function vt = setviewtype(this, vt)

h = getcomponent(this, '-class', 'siggui.selectorMCOS');
set(h, 'Selection', vt);

end

% -------------------------------------------------------------------------
function vt = getviewtype(this, vt)

h = getcomponent(this, '-class', 'siggui.selectorMCOS');
vt = get(h, 'Selection');
end
