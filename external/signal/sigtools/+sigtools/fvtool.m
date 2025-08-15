classdef (CaseInsensitiveProperties=true) fvtool < sigtools.sigfig & sigio.dyproputil & matlab.mixin.Copyable
  %sigtools.fvtool class
  %   sigtools.fvtool extends sigtools.sigfig.
  %
  %    sigtools.fvtool properties:
  %       Alphamap - Property is of type 'mxArray'
  %       CloseRequestFcn - Property is of type 'mxArray'
  %       Color - Property is of type 'mxArray'
  %       Colormap - Property is of type 'mxArray'
  %       CurrentAxes - Property is of type 'mxArray'
  %       CurrentCharacter - Property is of type 'mxArray'
  %       CurrentObject - Property is of type 'mxArray'
  %       CurrentPoint - Property is of type 'mxArray'
  %       DockControls - Property is of type 'on/off'
  %       FileName - Property is of type 'mxArray'
  %       IntegerHandle - Property is of type 'on/off'
  %       InvertHardcopy - Property is of type 'on/off'
  %       KeyPressFcn - Property is of type 'mxArray'
  %       KeyReleaseFcn - Property is of type 'mxArray'
  %       MenuBar - Property is of type 'mxArray'
  %       Name - Property is of type 'mxArray'
  %       NextPlot - Property is of type 'mxArray'
  %       NumberTitle - Property is of type 'on/off'
  %       PaperUnits - Property is of type 'mxArray'
  %       PaperOrientation - Property is of type 'mxArray'
  %       PaperPosition - Property is of type 'mxArray'
  %       PaperPositionMode - Property is of type 'mxArray'
  %       PaperSize - Property is of type 'mxArray'
  %       PaperType - Property is of type 'mxArray'
  %       Pointer - Property is of type 'mxArray'
  %       PointerShapeCData - Property is of type 'mxArray'
  %       PointerShapeHotSpot - Property is of type 'mxArray'
  %       Position - Property is of type 'mxArray'
  %       Renderer - Property is of type 'mxArray'
  %       RendererMode - Property is of type 'mxArray'
  %       Resize - Property is of type 'on/off'
  %       ResizeFcn - Property is of type 'mxArray'
  %       SelectionType - Property is of type 'mxArray'
  %       ToolBar - Property is of type 'mxArray'
  %       Type - Property is of type 'mxArray'
  %       Units - Property is of type 'mxArray'
  %       WindowButtonDownFcn - Property is of type 'mxArray'
  %       WindowButtonMotionFcn - Property is of type 'mxArray'
  %       WindowButtonUpFcn - Property is of type 'mxArray'
  %       WindowKeyPressFcn - Property is of type 'mxArray'
  %       WindowKeyReleaseFcn - Property is of type 'mxArray'
  %       WindowScrollWheelFcn - Property is of type 'mxArray'
  %       WindowStyle - Property is of type 'mxArray'
  %       BeingDeleted - Property is of type 'mxArray'
  %       ButtonDownFcn - Property is of type 'mxArray'
  %       Children - Property is of type 'mxArray'
  %       Clipping - Property is of type 'on/off'
  %       CreateFcn - Property is of type 'mxArray'
  %       DeleteFcn - Property is of type 'mxArray'
  %       BusyAction - Property is of type 'mxArray'
  %       HandleVisibility - Property is of type 'mxArray'
  %       HitTest - Property is of type 'on/off'
  %       Interruptible - Property is of type 'on/off'
  %       Parent - Property is of type 'mxArray'
  %       Selected - Property is of type 'on/off'
  %       SelectionHighlight - Property is of type 'on/off'
  %       Tag - Property is of type 'mxArray'
  %       UIContextMenu - Property is of type 'mxArray'
  %       UserData - Property is of type 'mxArray'
  %       Visible - Property is of type 'on/off'
  %       AnalysisToolbar - Property is of type 'on/off'
  %       FigureToolbar - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Legend - Property is of type 'on/off'
  %       DesignMask - Property is of type 'on/off'
  %       Fs - Property is of type 'double_vector user-defined'
  %       SOSViewSettings - Property is of type 'dspopts.sosview'
  %
  %    sigtools.fvtool methods:
  %       addfilter - Add a filter to FVTool
  %       currentanalysis_listener - Listener to the current analysis
  %       deletefilter - Delete a filter from FVTool
  %       findall - find all objects.
  %       findfilters -   Find the filters in the input.
  %       findobj -   Find objects matching specified conditions.
  %       fvtool_cbs - FVTool Callbacks.
  %       legend -   Add a legend to FVTool.
  %       loadobj -  Load this object.
  %       notification_listener - Listener to the Notification event
  %       parsedigitalfilterinputs - Parse digitalFilter object inputs
  %       parsesysobjinputs - Parse System object inputs
  %       saveobj -  Save this object.
  %       setfilter - Set the filter to FVTool
  %       settitle - Set the title of the Filter Visualization Tool
  %       visible_listener - Listener to the visible property of FVTool
  %       zoom -   Zoom
  
  %   Copyright 2015-2018 The MathWorks, Inc.
  
  properties
    %GRID Property is of type 'on/off'
    Grid = 'off';
    %LEGEND Property is of type 'on/off'
    Legend = 'off';
  end
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %ANALYSISTOOLBAR Property is of type 'on/off'
    AnalysisToolbar = 'on';
    %FIGURETOOLBAR Property is of type 'on/off'
    FigureToolbar = 'on';
    %DESIGNMASK Property is of type 'on/off'
    DesignMask = 'off';
    %SOSVIEWSETTINGS Property is of type 'dspopts.sosview'
    SOSViewSettings = [];
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %FILTERS Property is of type 'MATLAB array' (hidden)
    Filters = [];
    %FSEDITABLE Property is of type 'on/off' (hidden)
    FsEditable
    %HOSTNAME Property is of type 'String' (hidden)
    HostName = '';
    %SPECTRALMASK Property is of type 'dspdata.maskline' (hidden)
    SpectralMask = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %LISTENERS Property is of type 'handle.listener vector'
    Listeners = [];
    %ANALYSISPARAMETERPROPS Property is of type 'schema.prop vector'
    AnalysisParameterProps = [];
    %PARAMETERLISTENERS Property is of type 'handle.listener vector'
    ParameterListeners = [];
  end
  
  properties (SetObservable, GetObservable)
    %FS Property is of type 'double_vector user-defined'
    Fs = [];
  end
  
  properties (Access=protected)
    DynamicPropNames = {'Analysis', 'OverlayedAnalysis'};
  end
  
  events
    NewPlot
  end  % events
  
  methods  % constructor block
    function this = fvtool(varargin)
      %FVTOOL The constructor for the FVTool object.
      [varargin{:}] = convertStringsToChars(varargin{:});
      [varargin, analysisStr, optstruct, pvpairs] = parse_inputs(this, varargin{:});
      
      % Disable the NextPlot warning
      [wstr, wid] = lastwarn('');
      w = warning('off', 'MATLAB:HandleGraphics:SupersededProperty:NextPlotNew');
      
      this.sigfig_construct('Visible', 'Off', ...
        'Menubar', 'None', ...
        'IntegerHandle', 'On', ...
        'NextPlot', 'New', ...
        'NumberTitle', 'On', ...
        'Tag', 'Initializing', ...
        'Color', get(0, 'DefaultUicontrolBackgroundColor'), ...
        'Name', getString(message('signal:sigtools:sigtools:FilterVisualizationTool')), ...
        'HandleVisibility', 'On', ...
        'WindowStyle','normal',...
        'ToolBar','auto');
      
      lastwarn(wstr, wid);
      warning(w);
      
      % Center the GUI
      movegui(this.FigureHandle, 'center');
      
      hFVT = siggui.fvtool;
      addcomponent(this, hFVT);
      addplugins(hFVT);
      
      [filters, hasfs] = findfilters(this, varargin{:});
      set(hFVT, 'Filters', filters);
      
      alla = getallanalyses(hFVT);
      
      dp1 = this.addprop('Analysis');
      dp1.SetMethod = @(s,e)setanalysis(this,e,'Analysis');
      dp1.GetMethod = @(this)getanalysis(this,'','Analysis');
      
      dp2 = this.addprop('OverlayedAnalysis');
      dp2.SetMethod = @(s,e)setanalysis(this,e,'OverlayedAnalysis');
      dp2.GetMethod = @(s,e)getanalysis(this,'','OverlayedAnalysis');
      
      addplugins(this);
      
      % Set the Current Analysis
      set(hFVT, 'Analysis', analysisStr);
      currentanalysis_listener(this);
      
      if hasfs && isprop(this, 'NormalizedFrequency')
        this.NormalizedFrequency = 'off';
      end
      
      % Set all the inputs before rendering so that we only update once.
      
      if ~isempty(optstruct)
        hFVT = getcomponent(this, 'siggui.fvtool');
        hPrm = get(hFVT, 'Parameters');
        struct2param(hPrm, optstruct);
      end
      
      % We have to attach the listeners first so that setting the analysis will
      % update the dynamic properties.
      attachlisteners(this);
      
      % Make sure the properties are up to date.
      currentanalysis_listener(this);
      
      % Check the filter for FDESIGN to draw the masks.  Do this before setting
      % the P/V Pairs in case the P/V pairs disable the mask.
      Hd = get(this, 'Filters');
      if isfdtbxinstalled
        
        if isa(Hd{1}, 'dfilt.basefilter')
          hfdfirst = privgetfdesign(Hd{1});
          hfmfirst = getfmethod(Hd{1});
        else
          hfdfirst = [];
          hfmfirst = [];
        end
        
        if isempty(hfdfirst) || isempty(hfmfirst), hasmask = false;
        else                                       hasmask = true; end
        
        % Loop over the rest of the filters, but break early if any of them
        % dont have a mask or it does not match the first.
        indx = 2;
        while indx <= length(Hd) && hasmask
          
          if isa(Hd{indx}, 'dfilt.basefilter')
            hfd = privgetfdesign(Hd{indx});
            hfm = getfmethod(Hd{indx});
          else
            hfd = [];
            hfm = [];
          end
          
          % If there is no fdesign or fmethod, or if they do not match the
          % first set, then we cannot draw a mask.
          if isempty(hfd) || isempty(hfm) || ...
              ~isequivalent(hfdfirst, hfd) || ...
              isconstrained(hfm) ~= isconstrained(hfmfirst)
            hasmask = false;
          end
          indx = indx + 1;
        end
        
        if hasmask
          pvpairs = [{'DesignMask', 'On'}, pvpairs];
        end
      end
      
      fdesignOptions = getFVToolOptions(this, filters);
      pvpairs = [fdesignOptions, pvpairs];
      
      % Set the param value pairs one at a time.
      for indx = 1:length(pvpairs)/2                
        try
          % Allow partial completion and case insensitive dynamic property
          % names.
          prop = validatestring(pvpairs{2*indx-1},this.DynamicPropNames);                          
          this.(prop) = pvpairs{2*indx};
        catch
          % If property not found on the dynamic property list, then let
          % set error out.
          this.(pvpairs{2*indx-1}) = pvpairs{2*indx};
        end
      end
      
      % Make sure the properties are up to date.
      currentanalysis_listener(this);
      
      % Render the toolbar
      render_fvtool_toolbar(this);
      
      % Render the Menus
      render_fvtool_menus(this);
      
      render(hFVT, this.FigureHandle);
      setunits(hFVT,'Normalized');
      set(hFVT, 'Visible', 'On');
      
      render_viewmenuitems(this);
      
      % Install Listeners
      this.Tag = 'filtervisualizationtool';
      
      lclnewplot_listener(this, []);
      
      set(hFVT.CurrentAnalysis, 'Filters', get(hFVT, 'Filters'));
      
      if desktop('-inuse')
        
        % MDI code
        
        mdiName = getString(message('signal:sigtools:sigtools:FilterVisualizationTool'));
        
        % store the last warning thrown
        [ lastWarnMsg, lastWarnId ] = lastwarn;
        
        % disable the warning when using the 'JavaFrame' property
        % this is a temporary solution
        oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        jf = matlab.ui.internal.JavaMigrationTools.suppressedJavaFrame(double(this));
        warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        
        % restore the last warning thrown
        lastwarn(lastWarnMsg, lastWarnId);
        
        jf.setGroupName(mdiName);
        
        % restore the last warning thrown
        lastwarn(lastWarnMsg, lastWarnId);
        
        this.WindowStyle = 'docked';
        hdesk = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
        if ~hdesk.isGroupShowing(mdiName)
          hdesk.setGroupDocked(mdiName, false);
        end
      end
    end  % fvtool
    
    
    %-------------------------------------------------------------------
    
  end  % constructor block
  
  methods
    function set.AnalysisToolbar(obj,value)
      % DataType = 'on/off'
      value = validatestring(value,{'on','off'},'','AnalysisToolbar');
      obj.AnalysisToolbar = value;
    end
    
    function set.FigureToolbar(obj,value)
      % DataType = 'on/off'
      value = validatestring(value,{'on','off'},'','FigureToolbar');
      obj.FigureToolbar = value;
    end
    
    function value = get.Filters(obj)
      value = getfilters(obj,obj.Filters);
    end
    function set.Filters(obj,value)
      obj.Filters = setfilters(obj,value);
    end
    
    function value = get.Grid(obj)
      value = getfcn(obj,obj.Grid,'Grid');
    end
    function set.Grid(obj,value)
      % DataType = 'on/off'
      if ~isa(value, 'matlab.lang.OnOffSwitchState')
        value = validatestring(value,{'on','off'},'','Grid');
      end
      obj.Grid = setfcn(obj,value,'Grid');
    end
    
    function value = get.Legend(obj)
      value = getfcn(obj,obj.Legend,'Legend');
    end
    function set.Legend(obj,value)
      % DataType = 'on/off'
      if ~isa(value, 'matlab.lang.OnOffSwitchState')
        value = validatestring(value,{'on','off'},'','Legend');
      end
      obj.Legend = setfcn(obj,value,'Legend');
    end
    
    function value = get.DesignMask(obj)
      value = getfcn(obj,obj.DesignMask,'DisplayMask');
    end
    function set.DesignMask(obj,value)
      % DataType = 'on/off'
      value = validatestring(value,{'on','off'},'','DesignMask');
      obj.DesignMask = setfcn(obj,value,'DisplayMask');
    end
    
    function value = get.Fs(obj)
      value = getfs(obj,obj.Fs);
    end
    function set.Fs(obj,value)
      % User-defined DataType = 'double_vector user-defined'
      obj.Fs = setfs(obj,value);
    end
    
    function value = get.FsEditable(obj)
      value = getfcn(obj,obj.FsEditable,'fseditable');
    end
    function set.FsEditable(obj,value)
      % DataType = 'on/off'
      value = validatestring(value,{'on','off'},'','FsEditable');
      obj.FsEditable = setfcn(obj,value,'fseditable');
    end
    
    function set.HostName(obj,value)
      % DataType = 'String'
      % no cell string checks yet'
      obj.HostName = value;
    end
    
    function value = get.SOSViewSettings(obj)
      value = get_sosview(obj,obj.SOSViewSettings);
    end
    function set.SOSViewSettings(obj,value)
      % DataType = 'dspopts.sosview'
      validateattributes(value,{'dspopts.sosview'}, {'scalar'},'','SOSViewSettings')
      obj.SOSViewSettings = set_sosview(obj,value);
    end
    
    function value = get.SpectralMask(obj)
      value = get_maskline(obj,obj.SpectralMask);
    end
    function set.SpectralMask(obj,value)
      % DataType = 'dspdata.maskline'
      validateattributes(value,{'dspdata.maskline'}, {'scalar'},'','SpectralMask')
      obj.SpectralMask = set_maskline(obj,value);
    end
    
    function set.Listeners(obj,value)
      % DataType = 'handle.listener vector'
      validateattributes(value,{'event.listener'}, {'vector'},'','Listeners')
      obj.Listeners = value;
    end
    
    function set.AnalysisParameterProps(obj,value)
      % DataType = 'schema.prop vector'
      if ~isempty(value)
        validateattributes(value,{'meta.DynamicProperty'}, {'vector'},'','AnalysisParameterProps')
      end
      
      obj.AnalysisParameterProps = value;
    end
    
    function set.ParameterListeners(obj,value)
      % DataType = 'handle.listener vector'
      if ~isempty(value)
        validateattributes(value,{'event.proplistener'}, {'vector'},'','ParameterListeners')
      end
      obj.ParameterListeners = value;
    end
    
    
    
  end   % set and get functions
  
  methods (Hidden)
    function dynpropsetfunction(this,newVal,hprm)
      
      % Set the dependent property
      setvalue(hprm, newVal);
      
    end
    
    function val = dynpropgetfunction(this,hprm)
      % This function hold the property name and the value of the dynamic
      % property being set.
      val = get(hprm, 'Value');
    end
  
  end
  
 
  methods  %% public methods
    function addfilter(this, varargin)
      %ADDFILTER Add a filter to FVTool
      
      narginchk(2,inf);
      if nargin > 1
          [varargin{:}] = convertStringsToChars(varargin{:});
      end
      
      % Check for System object inputs and the corresponding arithmetic
      % specification. Convert to DFILT objects according to the parsed
      % arithmetic.
      varargin = parsesysobjinputs(this, varargin{:});
      
      % Check for digitalFilter object inputs. Conver to DFILT objects.
      varargin = parsedigitalfilterinputs(this,varargin{:});
      
      filters = findfilters(this, varargin{:});
      
      if isempty(filters(1).Fs)
        maxfs = max(get(this, 'Fs'));
        if isnan(maxfs)
          maxfs = 1;
        end
        for indx = 1:length(filters)
          set(filters(indx), 'Fs', maxfs);
        end
      end
      
      hFVT = getcomponent(this, 'siggui.fvtool');
      
      hFVT.addfilter(filters);
      
    end
    
    function currentanalysis_listener(this, ~)
      %CURRENTANALYSIS_LISTENER Listener to the current analysis
      
      hFVT = getcomponent(this, 'siggui.fvtool');
      
      h  = get(this, 'Handles');
      ca = get(hFVT, 'CurrentAnalysis');
      
      if ~isempty(h)
        if isa(ca, 'sigresp.analysisaxis')
          enab = 'on';
        else
          enab = 'off';
        end
        
        set([h.toolbar.legend h.toolbar.grid], 'Enable', enab);
      end
      
      oldp = get(this, 'AnalysisParameterProps');
      delete(oldp);
      oldl = get(this, 'ParameterListeners');
      delete(oldl);
      
      l = [];
      if isempty(ca)
        p = [];
      else
        
        hPrm = getparameter(ca, '-all');
        if isempty(hPrm)
          p = [];
        end
        
        for indx = 1:length(hPrm)
          hindx = hPrm(indx);
          
          % Get the parameter name
          name = rmspaces(get(hindx, 'Name'));
          
          % Create a property based on the parameter object.
          try
            p(indx) = this.addprop(name);
            p(indx).GetObservable = true;
            p(indx).SetObservable = true;
            p(indx).Dependent = true;
                        
          catch %#ok<*CTCH>
            name = [name '2'];
            p(indx) = this.addprop(name);
            p(indx).GetObservable = true;
            p(indx).SetObservable = true;
            p(indx).Dependent = true;
          end
          
          if ~any(strcmp(this.DynamicPropNames,name))
            this.DynamicPropNames{end+1} = name;
          end
          
          this.(name) = get(hindx, 'Value');
          
          % The following function is used to store the dynamic property name
          % and its new value information inside the object.
          p(indx).SetMethod = @(s,e)dynpropsetfunction(s,e,hindx);          
          p(indx).GetMethod = @(s,e)dynpropgetfunction(s,hindx);
          
        end
        
      end
      
      this.AnalysisParameterProps = p;
      this.ParameterListeners = l;
      
    end
    
    function deletefilter(hObj, varargin)
      %DELETEFILTER Delete a filter from FVTool
      
      hFVT = getcomponent(hObj, 'siggui.fvtool');
      
      hFVT.deletefilter(varargin{:});
      
    end    
    
    function h = findall(this, varargin)
      %FINDALL find all objects.
      
      h = findall(double(this), varargin{:});
      
    end
    
    
    function [filters, hasfs] = findfilters(this, varargin)
      %FINDFILTERS   Find the filters in the input.
      
      Fs = [];
      for indx = 1:length(varargin)
        if ischar(varargin{indx}) && strcmpi(varargin{indx}, 'fs')
          Fs = varargin{indx+1};
          varargin(indx:end) = [];
          break;
        end
      end
      
      if ispref('SignalProcessingToolbox', 'DefaultFs')
        defaultFs = getpref('SignalProcessingToolbox', 'DefaultFs');
      else
        defaultFs = 1;
      end
      
      hfvt = getcomponent(this, 'siggui.fvtool');
      
      [filters, index] = hfvt.findfilters(varargin{:});
      for indx = index.object
        
        % Copy the filter, but make sure we keep the mask info.
        mi = [];
        if isprop(filters(indx).Filter, 'MaskInfo')
          mi = get(filters(indx).Filter, 'MaskInfo');
        end
        filters(indx).Filter = copy(filters(indx).Filter);
        if ~isempty(mi)
            if isa(filters(indx).Filter,'dfilt.basefilter')
                addprop(filters(indx).Filter,'MaskInfo');
            else
                schema.prop(filters(indx).Filter, 'MaskInfo', 'mxArray');
            end
          set(filters(indx).Filter, 'MaskInfo', mi);
        end
      end
      
      % Set the filter's Sampling Frequency to [] and we will fix it later
      % depending on the inputs.
      set(filters(setdiff(1:length(filters), index.objectwfs)), 'Fs', []);
      
      if isempty(Fs)
        
        % When we don't have any filters we won't have an old Fs.  The default
        % is 1, so we use that instead.
        if isempty(this.Filters) || isempty(this.Filters{1})
          oldfs = defaultFs;
        else
          oldfs = get(this, 'Fs');
        end
        
        maxindx = min(length(filters), length(oldfs));
        
        for indx = 1:maxindx
          
          % If the old Fs is not a nan and the current filter doesn't already have
          % an Fs we want to use the old Fs.
          if ~isnan(oldfs(indx)) && isempty(get(filters(indx),'Fs'))
            set(filters(indx), 'Fs', oldfs(indx));
          end
        end
        mfs = max(oldfs);
        if isnan(mfs)
          mfs = defaultFs;
        end
        for indx = maxindx+1:length(filters)
          if isempty(get(filters(indx), 'Fs'))
            set(filters(indx), 'Fs', mfs);
          end
        end
        
      else
        if length(Fs) == 1
          set(filters, 'Fs', Fs);
        else
          if length(filters) ~= length(Fs)
            error(message('signal:sigtools:fvtool:findfilters:lengthMismatch'));
          end
          for indx = 1:length(Fs)
            set(filters(indx), 'Fs', Fs(indx));
          end
        end
      end
      
      hasfs = false;
      empty = [];
      for indx = 1:length(filters)
        hspecs = privgetfdesign(filters(indx).Filter);
        if ~isempty(hspecs) && ~hspecs.NormalizedFrequency
          set(filters(indx), 'Fs', hspecs.Fs);
          hasfs = true;
        elseif isprop(filters(indx).Filter,'SystemObjParams') && isfield(filters(indx).Filter.SystemObjParams,'SampleRate')
          set(filters(indx), 'Fs', filters(indx).Filter.SystemObjParams.SampleRate);
          hasfs = true;
        elseif filters(indx).Fs ~= defaultFs
          hasfs = true;
        else
          empty = [empty indx];
        end
      end
      
      if ~isempty(empty)
        hasfs = false;
        set(filters, 'Fs', defaultFs);
      end
      
      % [EOF]
      
      
    end
    
    
    function h = findobj(this, varargin)
      %FINDOBJ   Find objects matching specified conditions.
      
      h = findobj(double(this), varargin{:});
      
    end
    
    
    function fcns = fvtool_cbs(hFVT)
      %FVTOOL_CBS FVTool Callbacks.
      
      fcns.new_cb              = @new_cb;
      fcns.fileprint_cb        = @fileprint_cb;
      fcns.fileprintpreview_cb = @fileprintpreview_cb;
      fcns.legend_cb           = @legend_cb;
      fcns.grid_cb             = @grid_cb;
      
      
    end
    
    
    function legend(hObj, varargin)
      %LEGEND   Add a legend to FVTool.
      %   LEGEND(H, STR1, STR2, etc.) Add a legend to the FVTool associated with
      %   H.  STR1 will be associated with the first filter, STR2 will be
      %   associated with the second filter, etc.
      %
      %   LEGEND(H, ..., 'Location', LOC) Add a legend to FVTool in the location
      %   LOC.  See LEGEND for more information.  LOC is 'Best' by default.
      %
      %   LEGEND(H, 'Location', LOC) Changes the location of the legend without
      %   changing the strings in the legend.
      
      hFVT = getcomponent(hObj, 'siggui.fvtool');
      
      legend(hFVT, varargin{:});
      
      
    end
    
    
    function notification_listener(hObj, eventData)
      %NOTIFICATION_LISTENER Listener to the Notification event
      
      notify(hObj, 'Notification', eventData);
      
      NTypes = {'ErrorOccurred','WarningOccurred','StatusChanged','FileDirty'};
      NType  = get(eventData, 'NotificationType');
      
      hFVT = getcomponent(hObj, 'siggui.fvtool');
      
      % Switch on the Notification type. Note that warning and error are methods
      % of fvtool and not the warning and error functions.
      switch NType
        case NTypes{1} % 'ErrorOccurred'
          str = getString(message('signal:sigtools:fvtool:notification_listener:FVToolError'));
          error(hFVT, str, eventData.Data.ErrorString);
        case NTypes{2} % 'WarningOccurred'
          str = getString(message('signal:sigtools:fvtool:notification_listener:FVToolWarning'));
          warning(hFVT, str, eventData.Data.WarningString,eventData.Data.WarningID);
        case NTypes{3} % 'StatusChanged'
          % NO OP.  FVTool has no way of doing this
        case NTypes{4} % File Dirty
          % NO OP.  FVTool has no sessions.
        otherwise
          str1 = getString(message('signal:sigtools:fvtool:notification_listener:FVToolError'));
          str2 = getString(message('signal:sigtools:fvtool:notification_listener:UnhandledNotification',NType,class(eventData.Source)));
          error(hFVT, str1, str2)
      end
      
    end
    
    function cellOut = parsedigitalfilterinputs(~, varargin)
      %PARSEDIGITALFILTERINPUTS Parse digitalFilter object inputs
      
      cellOut = varargin;
      
      % Find digitalFilter object inputs
      for idx = 1:length(cellOut)
        if isa(cellOut{idx},'digitalFilter')
          cellOut{idx} = todfilt(cellOut{idx});
        end
      end
      
    end
    
    
    function cellOut = parsesysobjinputs(~, varargin)
      %PARSESYSOBJINPUTS Parse System object inputs
      
      sysObjCell = {};
      sysObjCellIndx = [];
      charInputCell = {};
      charInputCellIndx = [];
      
      % Find System object inputs
      for idx = 1:length(varargin)
        if isa(varargin{idx},'dsp.private.FilterAnalysis')
          sysObjCell = [sysObjCell varargin(idx)]; %#ok<*AGROW>
          sysObjCellIndx = [sysObjCellIndx idx];
        end
        if ischar(varargin{idx})
          charInputCell = [charInputCell varargin(idx)];
          charInputCellIndx = [charInputCellIndx idx];
        end
      end
      
      arith = [];
      % See if an arithmetic input has been passed to the addfilter method, cache
      % the arithmetic and remove the arithmetic inputs from the input varargin
      % cell
      arithIdx = find(strcmpi(charInputCell,'arithmetic'));
      if ~isempty(arithIdx)
        if (length(charInputCell) >= arithIdx+1 &&...
            ~any(strcmpi({'double','single','fixed'},charInputCell{arithIdx+1}))) ...
            || length(charInputCell) < arithIdx+1
          error(message('signal:sigtools:fvtool:fvtool:InvalidArithmeticInput'))
        end
        arith = charInputCell{arithIdx+1};
        varargin([charInputCellIndx(arithIdx) charInputCellIndx(arithIdx+1)]) = [];
        if isempty(sysObjCell)
          warning(message('signal:sigtools:fvtool:fvtool:IrrelevantArithInput'))
        end
      end
      
      % Throw 'same as input' warnings only once
      lastwarn('')
      wId2 = 'dsp:dsp:private:FilterSystemObjectBase:DefaultCoeffDataTypeFIR';
      wId3 = 'dsp:dsp:private:FilterSystemObjectBase:DefaultCoeffDataTypeSOS';
      wId4 = 'dsp:dsp:private:FilterSystemObjectBase:DefaultCoeffDataTypeLockedFIR';
      wId5 = 'dsp:dsp:private:FilterSystemObjectBase:DefaultCoeffDataTypeLockedSOS';
      wState2 =  warning('QUERY', wId2);
      wState3 =  warning('QUERY', wId3);
      wState4 =  warning('QUERY', wId4);
      wState5 =  warning('QUERY', wId5);
      c1 = onCleanup(@()restoreWarningState(wState2,wState3,wState4,wState5));
      
      % Convert input System object filters to DFILT objects. Throw warnings only
      % once
      
      for k = 1:length(sysObjCell)
        indx = sysObjCellIndx(k);
        varargin = parseObjectLevelOptions(sysObjCell{k},varargin);
        varargin{indx} = todfilt(sysObjCell{k},arith);
        [wmsg, wid] = lastwarn; %#ok<ASGLU>
        if strcmpi(wid,wId2)
          warning('off',wId2);
        end
        if strcmpi(wid,wId3)
          warning('off',wId3);
        end
        if strcmpi(wid,wId4)
          warning('off',wId4);
        end
        if strcmpi(wid,wId5)
          warning('off',wId5);
        end
      end
      
      cellOut = varargin;
      
    end
    
    
    function s = saveobj(~)
      %SAVEOBJ  Save this object.
      
      warning(message('signal:fvtool:NotSerializable'));
      
      % Something must be returned to avoid the default object load.
      s.EmptyField = [];
      
    end
    
    
    function setfilter(this, varargin)
      %SETFILTER Set the filter to FVTool
      
      % FINDFILTERS is now done in SETFCN.
      % filters = findfilters(this, varargin{:});
      
      % Check for System object inputs and the corresponding arithmetic
      % specification. Convert to DFILT objects according to the parsed
      % arithmetic.
      varargin = parsesysobjinputs(this, varargin{:});
      
      % Check for digitalFilter object inputs. Conver to DFILT objects.
      varargin = parsedigitalfilterinputs(this,varargin{:});
      
      this.Filters = varargin;
      
    end
    
    
    function settitle(this)
      %SETTITLE Set the title of the Filter Visualization Tool
      
      hFVT = getcomponent(this, 'siggui.fvtool');
      
      str  = get(hFVT.CurrentAnalysis, 'Name');
      
      % Set the figure title.
      hn = get(this, 'HostName');
      if ~isempty(hn), str = sprintf('%s (%s)', str, hn); end
      
      if ~strcmpi(get(this, 'WindowStyle'), 'docked')
        str = sprintf([getString(message('signal:sigtools:sigtools:FilterVisualizationTool')) ' - %s'], str);
      end
      
      this.Name = str;
      
    end
    
    
    function visible_listener(hFVT, eventData)
      %VISIBLE_LISTENER Listener to the visible property of FVTool
      
      visState = get(hFVT, 'Visible');
      
      if strcmpi(visState, 'on')
        fvtool_visible_listener(hFVT, eventData);
      end
      
      hFig = get(hFVT,'FigureHandle');
      set(hFig,'Visible', hFVT.Visible);
      
      if strcmpi(visState, 'off')
        fvtool_visible_listener(hFVT, eventData);
      end
      
    end
    
    
    function zoom(this, varargin)
      %ZOOM   Zoom
      
      narginchk(2,3);
      
      hFVT = getcomponent(this, 'siggui.fvtool');
      
      zoom(hFVT, varargin{:});
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function cleanup(this)
      %CLEANUP
      
      hFVT = getcomponent(this, 'siggui.fvtool');
      
      % Delete FVTool and the figure object
      delete(hFVT);
      
      % This was for g279483, but we have decided that we want to leave the
      % MDI open because the user may have setup the MDI and removing it might be
      % annoying.
      hFVTs = findall(0, 'tag', 'filtervisualizationtool');
      
      %       if isempty(setdiff(hFVTs, this.double))
      %         com.mathworks.mlservices.MatlabDesktopServices.getDesktop.closeGroup(getString(message('signal:sigtools:sigtools:FilterVisualizationTool')));
      %       end
      
    end
    
  end  %% possibly private or hidden
  
  
  methods (Static, Hidden) %% static methods
    function this = loadobj(~)
      %LOADOBJ  Load this object.
      
      this = [];
      
    end
    
  end  %% static methods
  
end  % classdef

function sosview = set_sosview(this, sosview)

hFVT = getcomponent(this, 'siggui.fvtool');

set(hFVT, 'SOSViewOpts', copy(sosview));

setup_sosview_listener(this, sosview);
end  % set_sosview



% -----------------------------------------------------------------
function sosview = get_sosview(this, sosview) %#ok<*INUSD>

hFVT = getcomponent(this, 'siggui.fvtool');

sosview = get(hFVT, 'SOSViewOpts');
if isempty(sosview)
  sosview = dspopts.sosview;
  set(hFVT, 'SOSViewOpts', sosview);
else
  sosview = copy(sosview);
end

setup_sosview_listener(this, sosview);
end  % get_sosview


% -------------------------------------------------------------------------
function setup_sosview_listener(this, h)

l(1) = event.proplistener(h, h.findprop('View'),                'PostSet', @(s,e)sosview_listener(this,e));
l(2) = event.proplistener(h, h.findprop('UserDefinedSections'), 'PostSet', @(s,e)sosview_listener(this,e));
l(3) = event.proplistener(h, h.findprop('SecondaryScaling'),    'PostSet', @(s,e)sosview_listener(this,e));

setappdata(this, 'sosview_listener', l);
end  % setup_sosview_listener


% -----------------------------------------------------------------
function sosview_listener(this, eventData)

sosview = eventData.AffectedObject;
hFVT    = getcomponent(this, 'siggui.fvtool');

set(hFVT, 'SOSViewOpts', copy(sosview));
end  % sosview_listener


% -----------------------------------------------------------------
function h = set_maskline(this, h)

hFVT = getcomponent(this, 'siggui.fvtool');

set(hFVT, 'UserDefinedMask', copy(h));

setup_maskline_listener(this, h);
end  % set_maskline


% -----------------------------------------------------------------
function h = get_maskline(this, h)

hFVT = getcomponent(this, 'siggui.fvtool');

h = get(hFVT, 'UserDefinedMask');
if isempty(h)
  h = dspdata.masklineMCOS;
  set(hFVT, 'UserDefinedMask', h);
else
  h = copyTheObj(h);
end

setup_maskline_listener(this, h);
end  % get_maskline


% -------------------------------------------------------------------------
function setup_maskline_listener(this, h)

l(1) = event.proplistener(h, h.findprop('EnableMask'),      'PostSet', @(s,e)maskline_listener(this,e));
l(2) = event.proplistener(h, h.findprop('MagnitudeUnits'),  'PostSet', @(s,e)maskline_listener(this,e));
l(3) = event.proplistener(h, h.findprop('FrequencyVector'), 'PostSet', @(s,e)maskline_listener(this,e));
l(4) = event.proplistener(h, h.findprop('MagnitudeVector'), 'PostSet', @(s,e)maskline_listener(this,e));

% set(l, 'CallbackTarget', this);
setappdata(this, 'maskline_listener', l);
end  % setup_maskline_listener


% -----------------------------------------------------------------
function maskline_listener(this, eventData)

maskline = eventData.AffectedObject;
hFVT     = getcomponent(this, 'siggui.fvtool');

objA = copyTheObj(maskline);

set(hFVT,'UserDefinedMask',objA)

ca = get(hFVT, 'CurrentAnalysis');

if ~isempty(ca) && isprop(ca, 'UserDefinedMask')
  show_listener(ca)
end

sendfiltrespwarnings(hFVT);

end  % maskline_listener


% -----------------------------------------------------------------
function fs = setfs(this, fs)

hFVT = getcomponent(this, 'siggui.fvtool');

filt = get(hFVT, 'Filters');

oldfs = get(this, 'Fs');

if length(fs) == 1
  if isnan(fs)
    set(filt, 'Fs', 1);
  else
    set(filt, 'Fs', fs);
  end
else
  if length(fs) ~= length(filt)
    error(message('signal:sigtools:fvtool:schema:lengthMismatch'));
  end
  for indx = 1:length(filt)
    if isnan(fs(indx))
      set(filt(indx), 'Fs', 1);
    else
      set(filt(indx), 'Fs', fs(indx));
    end
  end
end

if isprop(this, 'NormalizedFrequency')
  this.NormalizedFrequency = 'Off';
end

if ~isequal(oldfs, fs) && isrendered(hFVT), draw(hFVT.CurrentAnalysis); end
end  % setfs


% fs = [];

% -----------------------------------------------------------------
function fs = getfs(this, fs)

hFVT = getcomponent(this, 'siggui.fvtool');

filt = get(hFVT, 'Filters');

for indx = 1:length(filt)
  lfs = get(filt(indx), 'Fs');
  if isempty(lfs)
    fs(indx) = NaN;
  else
    fs(indx) = lfs;
  end
end
end  % getfs


% -----------------------------------------------------------------
function out = setfilters(this, out)

if ~iscell(out)
  out = {out};
end

hFVT = getcomponent(this, 'siggui.fvtool');

% Check for System object inputs and convert to DFILT objects.
out = parsesysobjinputs(this, out{:});

% Check for digitalFilter object inputs and convert to DFILT objects.
out = parsedigitalfilterinputs(this,out{:});

out = this.findfilters(out{:});

hFVT.setfilter(out);
end  % setfilters


% -----------------------------------------------------------------
function out = getfilters(this, out)

hFVT = getcomponent(this, 'siggui.fvtool');

out  = get(hFVT.Filters, 'Filter');

if ~iscell(out), out = {out}; end
end  % getfilters


% -----------------------------------------------------------------
function out = setfcn(this, out, prop)

hFVT = getcomponent(this, 'siggui.fvtool');

hFVT.(prop) = out;
end  % setfcn


% -----------------------------------------------------------------
function out = getfcn(this, out, prop) %#ok<*INUSL>

hFVT = getcomponent(this, 'siggui.fvtool');

out = get(hFVT, prop);
end  % getfcn

% -----------------------------------------------------------------
function attachlisteners(this)

hFVT  = getcomponent(this, 'siggui.fvtool');

hfig = this.FigureHandle;
addlistener(hfig, hfig.findprop('WindowStyle'), 'PostSet', @(h, ev) onWindowStyleChange(this));
addlistener(hfig, 'ObjectChildAdded', @(h, ev) onChildAdded(ev));

l(1) = event.listener(hFVT, 'NewPlot', @(s,e)lclnewplot_listener(this,e));
l(2) = event.proplistener(this, this.findprop('HostName'),        'PostSet', @(s,e)lclhostname_listener(this,e));
l(3) = event.proplistener(this, this.findprop('AnalysisToolbar'), 'PostSet', @(s,e)lclanalysistoolbar_listener(this,e));
l(4) = event.proplistener(this, this.findprop('FigureToolbar'),   'PostSet', @(s,e)lclfiguretoolbar_listener(this,e));
l(5) = event.proplistener(hFVT, hFVT.findprop('Grid'),            'PostSet', @(s,e)lclonoff_listener(this,e));
l(6) = event.proplistener(hFVT, hFVT.findprop('Legend'),          'PostSet', @(s,e)lclonoff_listener(this,e));
l(7) = event.proplistener(hFVT, hFVT.findprop('CurrentAnalysis'), 'PostSet', @(s,e) currentanalysis_listener(this,s));
l(8) = event.listener(hFVT, 'NewParameters', @(s,e)currentanalysis_listener(this,e));

this.Listeners = l;
end  % attachlisteners


%-------------------------------------------------------------------
function render_fvtool_menus(this)

hFig = get(this, 'FigureHandle');
h    = get(this, 'Handles');

% Render the "File" menu
hmenus.hfile = render_filemenu(this, hFig);

% Render the "Edit" menu
hmenus.hedit = render_spteditmenu(hFig);

% Render the "Insert" menu
hmenus.hinsert = render_sptinsertmenu(hFig,3);

h.menu.view = uimenu(hFig, 'Label', getString(message('signal:sigtools:sigtools:Viewamp')), 'Tag', 'view');

% Render the "Tools" menu
hmenus.htools = render_spttoolsmenu(hFig,5);
delete(hmenus.htools);

render_zoommenus(hFig, [get(h.menu.view, 'Position') 1], 'defaultview');

% Render the "Window" menu
hmenus.hwindow = render_sptwindowmenu(hFig,5);

% Render a Signal Processing Toolbox "Help" menu
render_helpmenu(hFig,6);

this.Handles = h;
end  % render_fvtool_menus


%-------------------------------------------------------------------
function render_viewmenuitems(hFVT)

h = get(hFVT, 'Handles');

if length(allchild(h.menu.view(1))) > 1
  sep = 'on';
else
  sep = 'off';
end

h.menu.view(end+1) = uimenu(h.menu.view(1), ...
  'Label', getString(message('signal:sigtools:sigtools:FigureToolbar')), ...
  'Checked', hFVT.FigureToolbar, ...
  'Tag', 'fvtool_showfiguretoolbar', ...
  'Separator', sep, ...
  'Callback', {@lcltoolbar_cb, hFVT, 'figuretoolbar'});

h.menu.view(end+1) = uimenu(h.menu.view(1), ...
  'Label', getString(message('signal:sigtools:sigtools:AnalysisToolbar')), ...
  'Checked', hFVT.AnalysisToolbar, ...
  'Tag', 'fvtool_showanalysistoolbar', ...
  'Callback', {@lcltoolbar_cb, hFVT, 'analysistoolbar'});

set(hFVT, 'Handles', h);
end  % render_viewmenuitems


%-------------------------------------------------------------------
function render_helpmenu(hFig, pos)

render_spthelpmenu(hFig, pos);
addmenu(hFig, [pos 1], getString(message('signal:sigtools:sigtools:FVToolHelp')), @(h, ev) aboutfvtool_cb, 'fvtoolhelp');
end  % render_helpmenu


%-------------------------------------------------------------------
function hfile = render_filemenu(this, hFig)

% Render the "File " menu
hfile = render_sptfilemenu(hFig);

% Add the "New Filter Analysis' menu item
strs  = getString(message('signal:sigtools:sigtools:NewFilterAnalysis'));
cbs   = fvtool_cbs(this);
cbs   = {cbs.new_cb, this};
tags  = 'newanalysis';
sep   = 'off';
accel = 'N';
hnew = addmenu(hFig,[1 1],strs,cbs,tags,sep,accel);

set(findobj(hfile, 'tag', 'export'), 'Separator', 'On')

hfile = [hfile hnew];
end  % render_filemenu


%-------------------------------------------------------------------
function render_fvtool_toolbar(this)
%Render the toolbar

h = get(this, 'Handles');

hFig = get(this, 'FigureHandle');
h.figuretoolbar = uitoolbar(hFig);

% Render the New Button
render_newbtn(this, h.figuretoolbar);

% Render Print buttons (Print, Print Preview)
render_sptprintbtns(h.figuretoolbar);

% Render the annotation buttons (Edit Plot, Insert Arrow, etc)
render_sptscribebtns(h.figuretoolbar);

% Render the zoom buttons
render_zoombtns(hFig);

sigComp = this.SigguiComponents;

% Render the Legend buton
cbs = fvtool_cbs(this);
h.toolbar.legend = render_legendonoffbtn(h.figuretoolbar, {cbs.legend_cb, this});
h.toolbar.grid   = render_gridonoffbtn(h.figuretoolbar, {cbs.grid_cb, this});
set(h.toolbar.legend, 'State', sigComp.Legend);
set(h.toolbar.grid, 'Separator', 'Off', 'State', sigComp.Grid);

h.analysistoolbar = uitoolbar(hFig, 'Tag', 'analysistoolbar');

this.Handles = h;
end  % render_fvtool_toolbar


%-------------------------------------------------------------------
function hnewbtn = render_newbtn(this, hut)

% Load new, open, save print and print preview icons.
load mwtoolbaricons;

pushbtns = newdoc;

tooltips = getString(message('signal:sigtools:sigtools:NewFilterAnalysis'));

tags = 'newanalysis';

cbs = fvtool_cbs(this);
btncbs = cbs.new_cb;

% Render the PushButton
hnewbtn = uipushtool('CData',pushbtns,...
  'Parent',         hut,...
  'ClickedCallback',{btncbs, this},...
  'Tag',            tags,...
  'Interruptible',  'Off', ...
  'BusyAction',     'cancel', ...
  'TooltipString',  tooltips);
end  % render_newbtn



%-------------------------------------------------------------------
function aboutfvtool_cb

helpview(fullfile(docroot, '/toolbox/signal/', 'signal.map'), 'fvtool_overview');
end  % aboutfvtool_cb



%-------------------------------------------------------------------
%                       Utility Functions
%-------------------------------------------------------------------
%-------------------------------------------------------------------
function analysis = setanalysis(this, analysis, prop)

analysis = convertStringsToChars(analysis);
hfvt = getcomponent(this, 'siggui.fvtool');
set(hfvt, prop, analysis);
end  % setanalysis


%-------------------------------------------------------------------
function analysis = getanalysis(this, analysis, prop) 

hfvt = getcomponent(this, 'siggui.fvtool');
analysis = get(hfvt, prop);
end  % getanalysis


%-------------------------------------------------------------------
%   Listeners
%-------------------------------------------------------------------

% -------------------------------------------------------------------
function onChildAdded(eventData)
%Set all legends invisible.

hSrc = eventData.Child;

if isa(hSrc, 'matlab.graphics.illustration.Legend')
  warning(message('signal:sigtools:fvtool:fvtool:useLegendMethod', 'LEGEND', 'help fvtool'));
end
end  % onChildAdded


%-------------------------------------------------------------------
function lclnewplot_listener(this, eventData)

settitle(this);
notify(this, 'NewPlot');
end  % lclnewplot_listener


%-------------------------------------------------------------------
function onWindowStyleChange(this)

settitle(this);
end  % onWindowStyleChange


%-------------------------------------------------------------------
function lclhostname_listener(this, eventData) 

settitle(this);
end  % lclhostname_listener


%-------------------------------------------------------------------
function lclonoff_listener(this, eventData)

prop = eventData.Source.Name;
h = get(this, 'Handles');

if isempty(h)
  return;
end

propVal = this.(prop);

set(h.toolbar.(lower(prop)), 'State', propVal);
end  % lclonoff_listener


%-------------------------------------------------------------------
function lclanalysistoolbar_listener(this, eventData) %#ok

h = get(this, 'Handles');

set(h.analysistoolbar, 'Visible', this.AnalysisToolbar);
set(findobj(h.menu.view, 'tag', 'fvtool_showanalysistoolbar'), ...
  'Checked', this.AnalysisToolbar);
end  % lclanalysistoolbar_listener


%-------------------------------------------------------------------
function lclfiguretoolbar_listener(hFVT, eventData) %#ok

h = get(hFVT, 'Handles');

set(h.figuretoolbar, 'Visible', hFVT.FigureToolbar);
set(findobj(h.menu.view, 'tag', 'fvtool_showfiguretoolbar'), ...
  'Checked', hFVT.FigureToolbar);
end  % lclfiguretoolbar_listener


%-------------------------------------------------------------------
function lcltoolbar_cb(hcbo, eventData, hFVT, prop) %#ok

at = get(hFVT, prop);

if strcmpi(at, 'off'), at = 'on';
else                   at = 'off'; end

set(hFVT, prop, at);
end  % lcltoolbar_cb


% -----------------------------------------------------
function options = getFVToolOptions(this, filters)

firstOptions = [];

% Loop over each of the filters and check its FDesign.
for indx = 1:length(filters)
  Hd = get(filters(indx), 'Filter'); %#ok<NASGU>
  hfdesign = getfdesign(filters(indx).Filter);
  
  % If any of the filters do not have a contained FDesign, do not use any
  % options returned.
  if isempty(hfdesign)
    options = {};
    return;
  else
    
    % Get the options from the FDesign.
    options = getfvtoolinputs(hfdesign);
    if isempty(firstOptions)
      firstOptions = options;
    else
      
      % If the options do not match the first
      if ~isequal(firstOptions, options)
        options = {};
        return;
      end
    end
  end
end

% Validate the options, if any fail, do not use any of them.
for indx = 1:2:length(options)
  if ~isprop(this, options{indx})
    options = {};
    return;
  end
end
end  % getFVToolOptions


% -----------------------------------------------------
function [varargin, analysisStr, optstruct, pvpairs] = parse_inputs(this, varargin) %#ok<VALST>
% Find the analysis string.  The rest is passed to the object

analysisStr = 'magnitude';
optstruct   = [];
pvpairs     = {};
msg         = '';

% Check for System object inputs and the corresponding arithmetic
% specification. Convert to DFILT objects according to the parsed
% arithmetic.
varargin = parsesysobjinputs(this,varargin{:});

% Check for digitalFilter object inputs. Conver to DFILT objects.
varargin = parsedigitalfilterinputs(this,varargin{:});

indx = 1;
while indx <= length(varargin) && isempty(pvpairs)
  if ischar(varargin{indx})
    if indx == length(varargin)
      analysisStr = varargin{indx};
    elseif isstruct(varargin{indx+1})
      analysisStr = varargin{indx};
      optstruct = varargin{indx+1};
    else
      pvpairs = varargin(indx:end);
      varargin = varargin(1:indx-1);
    end
  elseif isstruct(varargin{indx})
    optstruct = varargin{indx};
  elseif isnumeric(varargin{indx}) || isa(varargin{indx}, 'qfilt') || ...
      isa(varargin{indx}, 'dfilt.basefilterMCOS') || isa(varargin{indx}, 'dfilt.basefilter') || ...
      isa(varargin{indx}, 'sigdatatypes.parameter') || ...
      isa(varargin{indx}, 'dfilt.dfiltwfs')
    % NO OP.  These are the filters.
  elseif iscell(varargin{indx})
    msg = 'cell arrays';
  else
    msg = class(varargin{indx});
  end
  indx = indx + 1;
  if ~isempty(msg)
    error(message('signal:sigtools:fvtool:fvtool:invalidInputs', msg));
  end
end
end  % parse_inputs



% -------------------------------------------------------------------------
function s = rmspaces(s)

indx = strfind(s, ' ');
s(indx) = [];
openp = strfind(s, '(');
for indx = length(openp):-1:1
  closep = min(strfind(s(openp(indx):end), ')'));
  if isempty(closep)
    s(openp(indx):end) = [];
  else
    s(openp(indx):openp(indx)+closep-1) = [];
  end
end

end

%-------------------------------------------------------------------------
function legend_cb(hcbo,eventStruct, hFVT)
%LEGEND_CB OnCallback for Legend On/Off button.

hFig = gcbf;
p    = getptr(hFig);
setptr(hFig, 'watch');

set(hFVT,'Legend',get(hcbo,'State'));

set(hFig, p{:});

end

%-------------------------------------------------------------------------
function grid_cb(hcbo,eventStruct, hFVT)
%LEGEND_CB OnCallback for Legend On/Off button.

hFig = gcbf;
p    = getptr(hFig);
setptr(hFig, 'watch');

set(hFVT,'Grid',get(hcbo,'State'));

set(hFig, p{:});

end

%---------------------------------------------------------------------
function new_cb(hcbo,eventStruct, hObj)
% Callback for the "New Session" toolbar pushbutton.
%
% Inputs:
%   Not being used

hFVT = getcomponent(hObj, 'siggui.fvtool');

G     = get(hFVT, 'Filters');
canal = get(hFVT, 'Analysis');
hPrm  = copyparams(get(hFVT, 'Parameters'));

fvtool(G, hPrm, canal);

end

%---------------------------------------------------------------------
function fileprint_cb(hcbo,eventStruct, hFVT)
% Callback for the "Print" toolbar pushbutton.
%
% Inputs:
%   Not being used

printdlg(gcbf);

end

%---------------------------------------------------------------------
function fileprintpreview_cb(hcbo,eventStruct, hFVT)
% Callback for the "Print Preview" toolbar pushbutton.
%
% Inputs:
%   Not being used

printpreview(gcbf);

end

%-------------------------------------------------------------------
function h = copyparams(hold)

for i = 1:length(hold)
  h(i) = sigdatatypes.parameter(hold(i).Name, hold(i).Tag, ...
    hold(i).ValidValues, hold(i).Value);
end

end


%--------------------------------------------------------------------------
function restoreWarningState(wState1,wState2,wState3,wState4)
% Restore nonRelevantProperty warning state
warning(wState1)
if nargin > 1
  warning(wState2)
  warning(wState3)
  warning(wState4)
end

end




