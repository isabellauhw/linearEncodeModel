classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) fvtool < siggui.sigcontainerMCOS & hgsetget
  %siggui.fvtool class
  %   siggui.fvtool extends siggui.sigcontainer.
  %
  %    siggui.fvtool properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Analysis - Property is of type 'string'
  %       OverlayedAnalysis - Property is of type 'string'
  %       Filters - Property is of type 'MATLAB array'
  %       Grid - Property is of type 'on/off'
  %       ShowReference - Property is of type 'on/off'
  %       PolyphaseView - Property is of type 'on/off'
  %       Legend - Property is of type 'on/off'
  %       FastUpdate - Property is of type 'on/off'
  %       DisplayMask - Property is of type 'on/off'
  %       SOSViewOpts - Property is of type 'dspopts.sosview'
  %       UserDefinedMask - Property is of type 'dspdata.maskline'
  %       CurrentAnalysis - Property is of type 'sigresp.abstractanalysis' (read only)
  %       Parameters - Property is of type 'sigdatatypes.parameter vector' (read only)
  %
  %    siggui.fvtool methods:
  %       addfilter - Add a filter to FVTool
  %       callbacks - Callbacks for the HG objects within the FVTool
  %       deletefilter - Delete a filter from FVTool
  %       editfs - Edit the Sampling Frequencies of the filters
  %       editparameters - Edit the parameters for the Current Analysis
  %       enable_listener - Listener to the enable property of FVTool
  %       findfilters - Finds filters in a variable number of inputs
  %       fix_submenu -   Fix the overlay plot submenu.
  %       getallanalyses -   Get all the analyses tags.
  %       getanalysisdata - GETDATA Returns the analysis data in cell arrays
  %       getanalysisobject - Return the specified analysis object
  %       getfilters -   Preget function for the filters property.
  %       getindexoffilts -  Return an index with the number of dfilt objects.
  %       getparameter - Get a parameter from FVTool
  %       getstate - Return the state of the Filter Visualization Tool
  %       legend - FVTool Legend.
  %       listeners - Returns a structure of function handles to FVTool's listeners.
  %       registeranalysis - Register a new analysis with FVTool
  %       render_component - Render FVTool's components.
  %       saveparameters - Save the parameters for use by another FVTool
  %       setanalysis - Set the analysis in FVTool
  %       setfilter - Set the filter in FVTool
  %       setfilters -   PreSet function for the filters.
  %       setstate - Set the state of the Filter Visualization Tool
  %       sosview -   Change the way we view SOS filters
  %       thisrender - RENDER Render the Filter Visualization Tool
  %       userdefinedmask -   User Defined Mask dialog interface.
  %       visible_listener - Listener to the visible property of FVTool
  %       zoom -   Zoom into the axis.

%   Copyright 2015-2019 The MathWorks, Inc.
  
  properties (SetObservable)
    %POLYPHASEVIEW Property is of type 'on/off'
    PolyphaseView = 'off';
  end
  properties (SetObservable, GetObservable)        
    %SOSVIEWOPTS Property is of type 'dspopts.sosview'
    SOSViewOpts = [];    
  end
  properties (AbortSet, SetObservable, GetObservable)
    % Filters
    Filters = [];
    %ANALYSIS Property is of type 'string'
    Analysis = '';
    %OVERLAYEDANALYSIS Property is of type 'string'
    OverlayedAnalysis = '';
    %GRID Property is of type 'on/off'
    Grid = 'On';
    %SHOWREFERENCE Property is of type 'on/off'
    ShowReference = 'on';
    %LEGEND Property is of type 'on/off'
    Legend = 'off';
    %FASTUPDATE Property is of type 'on/off'
    FastUpdate = 'off';
    %DISPLAYMASK Property is of type 'on/off'
    DisplayMask = 'off';
    %USERDEFINEDMASK Property is of type 'dspdata.maskline'
    UserDefinedMask = [];
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %FSEDITABLE Property is of type 'on/off' (hidden)
    FsEditable = 'On';
    %UPDATEAXISSCALESETTINGS Property is of type 'bool' (hidden)
    UpdateAxisScaleSettings = true;
    %DIALOGLISTENERS Property is of type 'mxArray' (hidden)
    DialogListeners = [  ];
  end
  
  properties (Access=protected, SetObservable, GetObservable)
    %ANALYSISLISTENERS Property is of type 'handle.listener vector'
    AnalysisListeners = [];
    %CURRENTANALYSISLISTENERS Property is of type 'handle.listener vector'
    CurrentAnalysisListeners = [];
    %ANALYSESINFO Property is of type 'MATLAB array'
    AnalysesInfo = [];
    %SUBMENUFIXED Property is of type 'bool'
    SubMenuFixed
    %PARAMETERDLG Property is of type 'handle'
    ParameterDlg = [];
    %FILTRESPWARNINGS Property is of type 'handle.EventData vector'
    FiltRespWarnings = [];
    %PRIVFILTERS Property is of type 'MATLAB array'
    privFilters = [];
    %SOSVIEWLISTENERS Property is of type 'handle.listener vector'
    SosViewListeners = [];
    %MASKLISTENERS Property is of type 'handle.listener vector'
    MaskListeners = [];
    %CACHEDFILTERS Property is of type 'MATLAB array'
    CachedFilters = [];
  end
  
  properties (SetAccess=protected, SetObservable, GetObservable)
    %CURRENTANALYSIS Property is of type 'sigresp.abstractanalysis' (read only)
    CurrentAnalysis = [];
    %PARAMETERS Property is of type 'sigdatatypes.parameter vector' (read only)
    Parameters = [];
  end
  
  
  events
    NewAnalysis
    NewFilter
    NewPlot
    NewParameters
  end  % events
  
  methods  % constructor block
    function this = fvtool(varargin)
      %FVTOOL The constructor for the FVTool object.
      [varargin{:}] = convertStringsToChars(varargin{:});

      % Parse the FVTools' inputs
      [filtobj, hPrms] = parseinputs(this, varargin{:});
      
      this.Filters = filtobj; % xxx UDD Limitation
      
      installanalyses(this);
      
      set(this, 'Tag', 'fvtool');
      set(this, 'Version', 1);
      hPrms = getparams(hPrms);
      
      set(this, 'Parameters', hPrms);
      
      l(1) = event.proplistener(this,this.findprop('Analysis'),'PostSet',@(s,e) listeners(this,e,'analysis_listener'));
      l(2) = event.proplistener(this,this.findprop('OverlayedAnalysis'),'PostSet',@(s,e) listeners(this,e,'secondanalysis_listener'));
      
      set(this, 'AnalysisListeners', l);
    end  % fvtool
    
    
    %-------------------------------------------------------------------
    
  end  % constructor block
  
  methods
    function set.Analysis(obj,value)
      % DataType = 'string'
      if ~strcmp(value,'')          
        if isstring(value)
            validateattributes(value,{'char','string'}, {'scalar'},'','Analysis')   
            value = char(value);
        end
        validateattributes(value,{'char'}, {'row'},'','Analysis')
        value = validatestring(value,{'magnitude','phase','freq','grpdelay','phasedelay','impulse','step','polezero','coefficients','info','magestimate','noisepower'},'','Analysis');
      end
      obj.Analysis = setanalysis(obj,value);
    end
    
    function set.OverlayedAnalysis(obj,value)
      % DataType = 'string'
      if ~isempty(value)
        validateattributes(value,{'char'}, {'row'},'','OverlayedAnalysis')
      end
      obj.OverlayedAnalysis = setanalysis(obj,value);
    end
    
    function value = get.Filters(obj)      
      value = getfilters(obj,obj.Filters);
    end
    function set.Filters(obj,value)
      obj.Filters = setfilters(obj,value);
    end
    
    function set.Grid(obj,value)
      % DataType = 'on/off'
      if ~isa(value, 'matlab.lang.OnOffSwitchState')
          value = validatestring(value,{'on','off'},'','Grid');
      end
      obj.Grid = setprop(obj,value,'Grid');
    end
    
    function set.ShowReference(obj,value)
      % DataType = 'on/off'
      value = validatestring(value,{'on','off'},'','ShowReference');
      obj.ShowReference = setprop(obj,value,'ShowReference');
    end
    
    function set.PolyphaseView(obj,value)
      % DataType = 'on/off'
      value = validatestring(value,{'on','off'},'','PolyphaseView');
      obj.PolyphaseView = setprop(obj,value,'PolyphaseView');
    end
    
    function set.Legend(obj,value)
      % DataType = 'on/off'
      if ~isa(value, 'matlab.lang.OnOffSwitchState')
          value = validatestring(value,{'on','off'},'','Legend');
      end
      obj.Legend = setprop(obj,value,'Legend');
    end
    
    function set.FastUpdate(obj,value)
      % DataType = 'on/off'
      value = validatestring(value,{'on','off'},'','FastUpdate');
      obj.FastUpdate = setprop(obj,value,'FastUpdate');
    end
    
    function set.DisplayMask(obj,value)
      % DataType = 'on/off'
      value = validatestring(value,{'on','off'},'','DisplayMask');
      obj.DisplayMask = setprop(obj,value,'DisplayMask');
    end
    
    function set.SOSViewOpts(obj,value)
      % DataType = 'dspopts.sosview'
      if ~isempty(value)
        validateattributes(value,{'dspopts.sosview'}, {'scalar'},'','SOSViewOpts')
      end
      obj.SOSViewOpts = setprop(obj,value,'SOSViewOpts');
    end
    
    function set.UserDefinedMask(obj,value)
      % DataType = 'dspdata.maskline'
      if ~isempty(value)
        validateattributes(value,{'dspdata.masklineMCOS'}, {'scalar'},'','UserDefinedMask')
      end
      obj.UserDefinedMask = setprop(obj,value,'UserDefinedMask');
    end
    
    function set.CurrentAnalysis(obj,value)
      % DataType = 'sigresp.abstractanalysis'
      if ~isempty(value)
        validateattributes(value,{'sigresp.abstractanalysis'}, {'scalar'},'','CurrentAnalysis')
      end
      
      obj.CurrentAnalysis = value;
      
      if isprop(value, 'DisplayMask')
        set(value, 'DisplayMask', obj.DisplayMask);
      end
    end
    
    function set.Parameters(obj,value)
      % DataType = 'sigdatatypes.parameter vector'
      if ~isempty(value)
        validateattributes(value,{'sigdatatypes.parameter'}, {'vector'},'','Parameters')
      end
      obj.Parameters = setparameters(obj,value);
    end
    
    function set.FsEditable(obj,value)
      % DataType = 'on/off'
      value = validatestring(value,{'on','off'},'','FsEditable');
      obj.FsEditable = value;
    end
    
    function set.AnalysisListeners(obj,value)
      % DataType = 'handle.listener vector'
      if ~isempty(value)
        validateattributes(value,{'event.listener'}, {'vector'},'','AnalysisListeners')
      end
      obj.AnalysisListeners = value;
    end
    
    function set.CurrentAnalysisListeners(obj,value)
      % DataType = 'handle.listener vector'
      if ~isempty(value)
        validateattributes(value,{'event.listener'}, {'vector'},'','CurrentAnalysisListeners')
      end
      obj.CurrentAnalysisListeners = value;
    end
    
    function set.SubMenuFixed(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical'}, {'scalar'},'','SubMenuFixed')
      obj.SubMenuFixed = value;
    end
    
    function set.ParameterDlg(obj,value)
      % DataType = 'handle'
      if ~isempty(value)
        validateattributes(value,{'handle'}, {'scalar'},'','ParameterDlg')
      end
      obj.ParameterDlg = value;
    end
    
    function set.FiltRespWarnings(obj,value)
      % DataType = 'sigdatatypes.notificationeventdataMCOS vector'
      if ~isempty(value)
        validateattributes(value,{'sigdatatypes.notificationeventdataMCOS'}, {'vector'},'','FiltRespWarnings')
      end
      obj.FiltRespWarnings = value;
    end
    
    function set.SosViewListeners(obj,value)
      % DataType = 'handle.listener vector'
      if ~isempty(value)
        validateattributes(value,{'event.listener'}, {'vector'},'','SosViewListeners');
      end
      obj.SosViewListeners = value;
    end
    
    function set.MaskListeners(obj,value)
      % DataType = 'handle.listener vector'
      if ~isempty(value)
        validateattributes(value,{'event.listener'}, {'vector'},'','MaskListeners')
      end
      obj.MaskListeners = value;
    end
    
    function set.UpdateAxisScaleSettings(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical'}, {'scalar'},'','UpdateAxisScaleSettings')
      obj.UpdateAxisScaleSettings = value;
    end
    
    function set.DialogListeners(obj,value)
      obj.DialogListeners = value;
    end
    
    function value = setprop(this, value, prop)
      
      ca = get(this, 'CurrentAnalysis');
      
      if ~isempty(ca) && isprop(ca, prop)
        ca.(prop) = value;
      end
      
      sendfiltrespwarnings(this);
    end  % setprop
    
  end   % set and get functions
  
  methods  %% public methods
    function addfilter(hFVT, varargin)
      %ADDFILTER Add a filter to FVTool
      %   ADDFILTER(hFVT, NUM, DEN) Add a DF2T filter to FDATool specified by a
      %   numerator NUM and a denominator DEN.
      %
      %   ADDFILTER(hFVT, NUM) Add a DF2T filter to FDATool specified by the
      %   numerator NUM.
      %
      %   ADDFILTER(hFVT, FILTOBJ) Add a filter to FDATool specified by the filter
      %   object FILTOBJ.
      %
      %   See also SETFILTER.

      narginchk(2,3)
      
      oldfilt = hFVT.Filters;
      newfilt = hFVT.findfilters(varargin{:});
      
      newfilt = [oldfilt(:); newfilt(:)];
      hFVT.setfilter(newfilt);
      
    end
    
    
    function fcns = callbacks(hObj)
      %CALLBACKS Callbacks for the HG objects within the FVTool

      fcns            = siggui_cbs(hObj);
      fcns.analysis   = {@analysis_cb, hObj};
      fcns.editparams = {fcns.method, hObj, 'editparameters'};
      fcns.editfs     = {fcns.method, hObj, 'editfs'};
      fcns.righthand  = {@righthand_cb, hObj};
      
    end
    
    function deletefilter(hFVT, indx)
      %DELETEFILTER Delete a filter from FVTool

      narginchk(2,2);
      
      filtobjs = get(hFVT, 'Filters');
      
      if isa(indx, 'dfilt.dfiltwfs')
        indx = find(filtobjs == indx);
      end
      
      % Verify that the input is valid.
      if length(filtobjs) < indx
        error(message('signal:siggui:fvtool:deletefilter:IdxOutOfBound'));
      end
      
      % Delete the selected filter
      filtobjs(indx) = [];
      
      % Set the new filter list
      hFVT.setfilter(filtobjs);
      
    end
    
    
    function editfs(hFVT)
      %EDITFS Edit the Sampling Frequencies of the filters
 
      hdlg = getcomponent(hFVT, '-class', 'siggui.dfiltwfsdlg');
      
      % If there is no parameter dialog, create one.
      if isempty(hdlg)
        filtobj = get(hFVT, 'privFilters');
        
        hdlg = siggui.dfiltwfsdlg(filtobj);
        addcomponent(hFVT, hdlg);
        
        l = event.proplistener(hFVT, hFVT.findprop('Filters'), 'PostSet', @(s,e)lclfilter_listener(hdlg,e));
        sigsetappdata(hFVT.FigureHandle, 'fvtool', 'listeners', 'dfiltwfsdlg_listener', l);
      end
      
      if ~isrendered(hdlg)
        render(hdlg);
        hdlg.centerdlgonfig(hFVT.FigureHandle);
      end
      
      warnState = true;
      for idxFilt = 1:length(hdlg.Filters)
        df = getfdesign(hdlg.Filters(idxFilt).Filter);
        if ~isempty(df)
          if ~((strcmpi(df.Response, 'audio weighting') ||...
              strncmp(df.Response, 'Octave', 6)))
            warnState = false;
            break
          end
        else
          warnState = false;
          break
        end
      end
      if warnState
        hw = siggui.dontshowagaindlg;
        set(hw, ...
          'Name', 'Sampling Frequency', ...
          'Text', {['Changing the sampling frequency for audio weighting ',...
          'and/or octave filters to a different value from the one ',...
          'you used at design time results in filters that do not ',...
          'meet the specifications derived from the corresponding ',...
          'standard.']}, ...
          'PrefTag', 'FsSetAudioFilterWarning',...
          'Icon', 'warn',...
          'NoHelpButton', true);
        
        % The need2show method returns false if the user has checked the box
        % in the past.  If it returns true, render the dialog and make it
        % visible.
        if hw.need2show
          render(hw);
          set(hw, 'Visible','on');
          
          % Add a listener to the parent being deleted so that we can
          % destroy the dontshowagain dialog.
          addlistener(hFVT.FigureHandle, 'ObjectBeingDestroyed', ...
            @(hh, eventStruct)delete(hw));
        end
      end
      
      % If there is a parameter dialog, make it visible and bring it to the front.
      set(hdlg, 'Visible', 'on');
      
      % set the tag property of the sampling frequency dialog
      set(hdlg.FigureHandle, 'Tag', 'SamplingFrequencyDlg');
      figure(hdlg.FigureHandle);
      
    end
    
    function editparameters(this)
      %EDITPARAMETERS Edit the parameters for the Current Analysis
  
      hdlg = get(this, 'ParameterDlg');
      ca   = get(this, 'CurrentAnalysis');
      
      if isempty(ca)
        error(message('signal:siggui:fvtool:editparameters:noAnalysis'));
      end
      
      % If there is no parameter dialog, create one.
      if isempty(hdlg)
        if ~isempty(ca)
          hdlg = ca.setupparameterdlg;
          set(this, 'ParameterDlg', hdlg);
          
          this.DialogListeners = [ ...
            event.listener(hdlg, 'DialogBeingApplied', @(~,~)onDialogBeingApplied(this)); ...
            event.listener(hdlg, 'DialogApplied', @(~,~)onDialogApplied(this))];
          
          set(hdlg, 'Tool', 'fvtool');
          [wstr, wid] = lastwarn;
          set(hdlg, 'HelpLocation', {fullfile(docroot, 'toolbox','signal', 'signal.map'), ...
            'fvtool_analysis_parameters'});
          lastwarn(wstr, wid);
        end
      else
        
        if ~isrendered(hdlg)
          render(hdlg);
          hdlg.centerdlgonfig(this.FigureHandle);
          set(hdlg, 'HelpLocation', {fullfile(docroot, 'toolbox','signal', 'signal.map'), ...
            'fvtool_analysis_parameters'});
        end
        setupparameterdlg(ca, hdlg);
      end
      
      cshelpcontextmenu(hdlg.FigureHandle, handles2vector(hdlg), ...
        'fvtool_analysis_parameters', 'FDATool');
      
      % Make it visible and bring it to the front.
      set(hdlg, 'Visible', 'on');
      figure(hdlg.FigureHandle);
      
    end
    
    
    function enable_listener(hObj, ~)
      %ENABLE_LISTENER Listener to the enable property of FVTool

      siggui_enable_listener(hObj);
      
      enabState = get(hObj,'Enable');
      
      if strcmpi(enabState,'on')
        lcolor = [0 0 0];
        bcolor = [1 1 1];
      else
        bcolor = get(0,'DefaultUicontrolBackgroundColor');
        lcolor = [.4 .4 .4];
      end
      
      h = get(hObj, 'Handles');
      
      set(h.axes,'Color',bcolor);
      set(h.axes,'XColor',lcolor);
      set(h.axes,'YColor',lcolor);
      
      hText = findall(h.axes,'type','text');
      hLines = findall(h.axes,'type','line');
      set([hLines; hText],'Color',lcolor);
      
      hPatch = findall(h.axes,'type','patch');
      set(hPatch,'EdgeColor',lcolor);
      
    end
    
    
    function [Hd, index] = findfilters(hFVT, varargin) %#ok<INUSL>
      %FINDFILTERS Finds filters in a variable number of inputs

      % We want to make sure we dont get any  warnings.
      w = warning('off'); %#ok<WNOFF>
      
      Hd              = {};
      b               = [];
      index.object    = [];
      index.objectwfs = [];
      
      for indx = 1:length(varargin)
        
        % If the input is a filter, use it.
        if isa(varargin{indx}, 'dfilt.basefilter') || isa(varargin{indx}, 'dfilt.basefilterMCOS') ||...
            any(strcmp(class(varargin{indx}), {'dfilt.dfiltwfs'}))
          
          % If we have something in b, create the filter using it
          if ~isempty(b)
            Hd{end+1} = dfilt.dffir(b);
            b = [];
          end
          
          for jndx = 1:length(varargin{indx})
            Hd{end + 1} = varargin{indx}(jndx);
            if isa(varargin{indx}(jndx), 'dfilt.dfiltwfs')
              index.objectwfs = [index.objectwfs length(Hd)];
            end
            index.object = [index.object length(Hd)];
          end
          
          % If the input is numeric it is either a num or a den or an sos matrix
        elseif isnumeric(varargin{indx}) && all(size(varargin{indx})>[1 1])
          % Input is a matrix, check if it is a valid SOS matrix
          
          % First check if previous input was a numerator vector and add it to
          % the filters cell array before we add the SOS filter.
          if ~isempty(b)
            Hd{end+1} = dfilt.dffir(b);
            b = [];
          end
          
          if size(varargin{indx},2) ~= 6
            error(message('signal:signalanalysisbase:invalidinputsosmatrix'));
          end
          Hd{end+1} = dfilt.df2sos(varargin{indx}); %#ok<*AGROW>
          
        elseif isnumeric(varargin{indx})
          if isempty(b)
            b = varargin{indx};
          else
            % If b is not empty the new input must be the den
            Hd{end+1} = dfilt.df2t(b, varargin{indx});
            b = [];
          end
        elseif ~isempty(b)
          % If we find something else and we have a num, it must be FIR
          Hd{end+1} = dfilt.dffir(b);
          b = [];
        end
      end
      
      % Use any stored b to create a dffir filter
      if ~isempty(b)
        Hd{end+1} = dfilt.dffir(b);
      end
      
      for indx = 1:length(Hd)
        if ~isa(Hd{indx}, 'dfilt.dfiltwfs')
          Hd{indx} = dfilt.dfiltwfs(Hd{indx});
        end
      end
      
      Hd = [Hd{:}];
      
      warning(w);
      
    end
    
    function fix_submenu(this)
      %FIX_SUBMENU   Fix the overlay plot submenu.
  
      if get(this, 'SubMenuFixed'), return; end
      
      h = get(this, 'Handles');
      
      ha = get(this, 'CurrentAnalysis');
      
      if isa(ha, 'filtresp.tworesps') && strcmpi(ha.fvtool_tag, 'tworesps')
        ha = ha.Analyses(1);
      end
      
      tag  = get(ha, 'fvtool_tag');
      
      tags = fieldnames(h.menu.analyses);
      
      freqtags = {'magnitude', 'phase','grpdelay','phasedelay','magestimate','noisepower'};
      timetags = {'impulse', 'step'};
      
      if isempty(tag)
        ontags = {};
      else
        switch tag
          case freqtags
            ontags = intersect(tags, freqtags);
          case timetags
            ontags = timetags;
          otherwise
            ontags = {};
        end
      end
      
      for indx = 1:length(tags)
        if any(strcmpi(tags{indx}, ontags))
          enab = get(h.menu.analyses.(tags{indx}), 'Enable');
        else
          enab = 'Off';
        end

        if isfield(h.menu.righthand, tags{indx})
          set(h.menu.righthand.(tags{indx}), 'Enable', enab);
        end
      end
      
      set(this, 'SubMenuFixed', true);

    end
    
    
    function names = getallanalyses(this)
      %GETALLANALYSES   Get all the analyses tags.

      info  = rmfield(get(this, 'AnalysesInfo'), 'tworesps');
      names = fieldnames(info);

    end
    
    function [xdata, ydata] = getanalysisdata(hObj)
      %GETDATA Returns the analysis data in cell arrays

      [xdata, ydata] = getanalysisdata(hObj.CurrentAnalysis);

    end
    
    function h = getanalysisobject(hObj, tag, new, hPrm)
      %GETANALYSISOBJECT Return the specified analysis object
 
      if nargin < 2 
        tag = get(hObj, 'Analysis'); 
      end
      
      if nargin < 3 
        new = false; 
      end
      
      if new
        h = [];
      else
        h = getcomponent(hObj, 'fvtool_tag', tag);
      end
      
      % If the selected analysis doesn't exist.  Create it.
      if isempty(h)
        
        info = get(hObj, 'AnalysesInfo');
        
        if nargin < 4
          hPrm = get(hObj, 'Parameters');
          reuse = true;
        else
          reuse = false;
        end
        
        % Create the new object using the filters and parameters stored.
        opts = {hObj.Filters, hPrm};
        if iscell(info.(tag).fcn)
          h = feval(info.(tag).fcn{:}, opts{:});
        else
          h = feval(info.(tag).fcn, opts{:});
        end
        
        oldprm = get(hObj, 'Parameters');
        allprm = union(getparameter(h, '-all'), oldprm);
        
        % Find all the new parameters and make them use their saved defaults
        newprm = setdiff(allprm, oldprm);
        if ~isempty(newprm), usedefault(newprm, 'fvtool'); end
        
        if reuse
          set(hObj, 'Parameters', allprm);
        end
        
        % Add a special tag property so that we can find the analysis again.
        p = h.addprop('fvtool_tag');
        set(h, 'fvtool_tag', tag);
        p.Hidden = true;
        %     set(p, 'Visible', 'Off', 'AccessFlags.PublicSet', 'Off'); %xxx
        %     undo/redo fix
        
        % When the new flag is passed in we don't want to save the object.
        if ~new
          addcomponent(hObj, h);
        end
      end

    end
    
    function filters = getfilters(this, filters) %#ok<INUSD>
      %GETFILTERS   Preget function for the filters property.

      filters = this.privFilters;

    end
    
    function [qindx, dindx] = getindexoffilts(hFVT)
      % Return an index with the number of dfilt objects.

      G = get(hFVT, 'Filters');
      
      if isempty(G)
        qindx = [];
        dindx = [];
      else
        [qindx, dindx] = getfiltindx(G);
      end

    end
    
    function hPrm = getparameter(hFVT, tag)
      %GETPARAMETER Get a parameter from FVTool
      %   GETPARAMETER(hFVT, TAG) Returns the parameter whose tag is TAG from FVTool.
      %   If the parameter is not available from FVTool an empty matrix will be returned.

      hPrms = get(hFVT, 'Parameters');
      
      hPrm = [];
      if ~isempty(hPrms)
        hPrm = find(hPrms, 'Tag', tag);
      end

    end
    
    function s = getstate(hFVT)
      %GETSTATE Return the state of the Filter Visualization Tool

      s.currentAnalysis = get(hFVT, 'Analysis');
      s.OverlayedAnalysis  = get(hFVT, 'OverlayedAnalysis');
 
    end
    
    function legend(this, varargin)
      %LEGEND FVTool Legend.
      %   LEGEND(H,string1,string2,string3, ...) Bring up the FVTool legend using
      %   string1 as the name of the first filter, string2 as the name of the
      %   second filter, etc.
 
      if nargin > 1
          [varargin{:}] = convertStringsToChars(varargin{:});
      end

      if isa(this.CurrentAnalysis, 'sigresp.analysisaxis')
        legend(this.CurrentAnalysis, varargin{:});
        set(this, 'Legend', 'On');
      else
        legend(getanalysisobject(this,'magnitude'), varargin{:});
        set(this, 'Legend', 'On');
      end
      
    end
    
    function listeners(this,eventData, fcn, varargin)
      %LISTENERS Returns a structure of function handles to FVTool's listeners.
 
      feval(fcn, this, eventData, varargin{:});
      
    end
    
    function [hmenu, htoolbar] = registeranalysis(hFVT, lbl, tag, fcn, icon, accel, checkfcn)
      %REGISTERANALYSIS Register a new analysis with FVTool
      %   REGISTERANALYSIS(hFVT, LABEL, TAG, FCN) Register a new analysis with the
      %   session of FVTool associated with hFVT.  When the analysis is selected FCN
      %   will be feval'ed with hFVT as the first input argument.
      %
      %   REGISTERANALYSIS(hFVT, LABEL, TAG, FCN, ICON, ACCEL)
 
      narginchk(4,7);
      
      if nargin < 5, icon     = []; end
      if nargin < 6, accel    = ''; end
      if nargin < 7, checkfcn = []; end
      
      info = get(hFVT, 'AnalysesInfo');
      
      % If the tag is already in use, error out.
      if ~isempty(info) && isfield(info, tag)
        error(message('signal:siggui:fvtool:registeranalysis:InvalidParam', tag));
      end
      
      info.(tag) = lclbuildstruct(lbl, fcn, icon, accel, checkfcn);
      
      % Save the information in the object
      set(hFVT,'AnalysesInfo',info);
      
      % Announce a new analysis
      eventData = sigdatatypes.sigeventdataMCOS(hFVT, 'NewAnalysis', tag);
      notify(hFVT, 'NewAnalysis', eventData);
      
      % Return the handle to the new controls if the GUI is rendered
      if isrendered(hFVT)
        h        = get(hFVT,'Handles');
        if isfield(h.menu.analyses, tag)
          hmenu = h.menu.analyses.(tag);
        else
          hmenu = [];
        end
        if isfield(h.toolbar.analyses, tag)
          htoolbar = h.toolbar.analyses.(tag);
        else
          hmenu = [];
        end
      else
        hmenu    = [];
        htoolbar = [];
      end
      
    end
    
    function render_component(this, fcn, varargin)
      %RENDER_COMPONENT Render FVTool's components.
      
      % All of the render functions of fvtool are here as local functions
      % to save render time.

      feval(fcn, this, varargin{:});
      
    end
    
    function saveparameters(hFVT)
      %SAVEPARAMETERS Save the parameters for use by another FVTool
   
      if get(hFVT,'ParametersDirty')
        
        hPrms = get(hFVT, 'Parameters');
        
        % We need to loop over these because of the dynamic property
        for i = 1:length(hPrms)
          data(i) = get(hPrms(i));
        end
        
        setpref('SignalProcessingToolbox', 'FvtoolParameters', data);
        set(hFVT, 'ParametersDirty', 0);
      end
      
    end
    
    function out = setanalysis(hObj, out)
      %SETANALYSIS Set the analysis in FVTool
      %   SETANALYSIS(H, ANALYSIS) Set the analysis of FVTool to ANALYSIS.  If
      %   only one input argument is given this function will return all the
      %   available analyses.
 
      % This will be the overloaded set on the CurrentAnalysis property
      
      info  = get(hObj, 'AnalysesInfo');
      names = fieldnames(info);
      
      if ~isempty(out)
        
        % Look for the input analysis among those available.
        indx = strmatch(lower(out), lower(names)); % Make sure it is case insensitive
        
        if isempty(indx)
          
          % If no analyses are found, error
          error(message('signal:siggui:fvtool:setanalysis:invalidAnalysis', out));
        end
        
        % If there are more than 1 found, use the first
        indx = indx(1);
        
        out = names{indx};
      end
      
    end
    
    
    function setfilter(hFVT, varargin)
      %SETFILTER Set the filter in FVTool
      %   SETFILTER(hFVT, NUM, DEN) Set the filter in FVTool using the numerator
      %   NUM and the denominator DEN to create a Direct Form II Transposed filter.
      %
      %   SETFILTER(hFVT, NUM) Set the filter in FVTool using the numerator
      %   NUM to create a Direct Form II Transposed filter.
      %
      %   SETFILTER(hFVT, FILTOBJ) Set the filter in FVTool using the filter object
      %   FILTOBJ.
      %
      %   SETFILTER(hFVT, FILTOBJ, OPTS) Set the filter in FVTool according to
      %   the options in the structure OPTS.  OPTS can contain the field 'index'
      %   which specifies the index in the existing filter vector to set the new
      %   filter.
      %
      %   See also ADDFILTER.

      narginchk(2,inf)
      
      if nargin > 1
          [varargin{:}] = convertStringsToChars(varargin{:});
      end

      % If the input is numeric, use it to create a filter.
      
      opts = struct('index', []);
      
      if isempty(varargin{1})
        filtobj = [];
      else
        
        if isstruct(varargin{end})
          
          % If the last input is a structure, then we need at least 3 inputs
          % (hfvt, filter, structure)
          narginchk(3,inf);
          opts     = setstructfields(opts, varargin{end});
          varargin = varargin(1:end-1);
        end
        
        filtobj = hFVT.findfilters(varargin{:});
      end
      
      if ~isempty(opts.index)
        oldfilts = get(hFVT, 'Filters');
        
        % We allow the caller to give multiple indexes, one of which can be 1
        % greater than the current number of filters.  The caller could also
        % set the filters and then add a filter, but this would cause a double
        % update.
        if length(oldfilts) < max(opts.index) - 1
          error(message('signal:siggui:fvtool:setfilter:IdxOutOfBound'));
        end
        if length(filtobj) ~= length(opts.index)
          error(message('signal:siggui:fvtool:setfilter:InvalidDimensions'));
        end
        for indx = 1:length(opts.index)
          oldfilts(opts.index(indx)) = filtobj(indx);
        end
        filtobj = oldfilts;
      end
      
      % Send the newfilter event with the newfilt object.  This is done so that filter listeners
      % can be updated before the filter is actually set in the object.
      eventData = sigdatatypes.sigeventdataMCOS(hFVT, 'NewFilter', filtobj);
      notify(hFVT, 'NewFilter', eventData);
           
      hFVT.Filters = filtobj;
                     
    end
    
    
    function filters = setfilters(this, filters)
      %SETFILTERS   PreSet function for the filters.

      % Avoid zoom reset and update of axis scale by setting
      % UpdateAxisScaleSettings to false before changing the analysis. Then
      % restore to original state.
      currentFlagValue = this.UpdateAxisScaleSettings;
      this.UpdateAxisScaleSettings = false;
      
      old_n_filters   = length(this.Filters);
      old_isquantized = lclisquantized(this.Filters);
      
      set(this, 'privFilters', filters);
      resetfiltercache(this);
      
      ca = get(this, 'CurrentAnalysis');
      if ~isempty(ca)
        ca.Filters = this.Filters;
      end
      
      % If we are going from 1 filter to multiple filters or if we are going from
      % an unquantized filter to a quantized filter, turn on the legend.
      if old_n_filters == 1 && length(filters) > 1 || ...
          ~old_isquantized && lclisquantized(filters)
        set(this, 'Legend', 'On');
      end
      
      sendfiltrespwarnings(this);
      this.UpdateAxisScaleSettings = currentFlagValue;
      
    end
    
    function value = setpropval(this, value, prop)
      
      ca = get(this, 'CurrentAnalysis');
      
      if ~isempty(ca) && isprop(ca, prop)
        ca.(prop) = value;
      end
      
      hdlg = getcomponent(this, '-class', 'siggui.sosviewdlg');
      if ~isempty(value)
        setopts(hdlg, value);
      end
      
    end  % setprop
    
    function setstate(hFVT, s)
      %SETSTATE Set the state of the Filter Visualization Tool
 
      if ~isfield(s, 'OverlayedAnalysis')
        s.OverlayedAnalysis = '';
      end
      
      switch lower(s.currentAnalysis)
        case 'magresp'
          s.currentAnalysis = 'magnitude';
        case 'phaseresp'
          s.currentAnalysis = 'phase';
        case 'magnphaseresp'
          s.currentAnalysis = 'freq';
        case 'groupdelay'
          s.currentAnalysis = 'grpdelay';
        case 'impresp'
          s.currentAnalysis = 'impulse';
        case 'stepresp'
          s.currentAnalysis = 'step';
        case 'pzplot'
          s.currentAnalysis = 'polezero';
        case 'filtercoeffs'
          s.currentAnalysis = 'coefficients';
        case 'nlm'
          s.currentAnalysis = 'magestimate';
          s.OverlayedAnalysis  = 'noisepower';
      end
      
      set(hFVT, 'Analysis', s.currentAnalysis);
      set(hFVT, 'OverlayedAnalysis', s.OverlayedAnalysis);
      
    end
    
    function sosview(this)
      %SOSVIEW   Change the way we view SOS filters

      hdlg = getcomponent(this, '-class', 'siggui.sosviewdlg');
      
      % If the dialog has not been instantiate yet, create on.
      if isempty(hdlg)
        hdlg = siggui.sosviewdlg;
        addcomponent(this, hdlg);
        
        % Sync up the options stored in FVTool with the new dialog.
        opts_listener(this);
        
        % Add listeners to keep the dialog and fvtool in sync.
        l(1) = event.listener(hdlg, 'DialogApplied', @(s,e)lcldialogapplied_listener(this,e));
        l(2) = event.proplistener(this, this.findprop('SOSViewOpts'), 'PostSet', @(s,e)opts_listener(this,e));
        
        set(this, 'SosViewListeners', l);
      end
      
      % If the dialog is not rendered, render it and center it on FVTool.
      if ~isrendered(hdlg)
        render(hdlg);
        centerdlgonfig(hdlg, this);
      end
      
      set(hdlg, 'Visible', 'on');
      figure(hdlg.FigureHandle);
      
    end
    
    function thisrender(this, varargin)
      %RENDER Render the Filter Visualization Tool
      %   RENDER(this, hFig, POS) Render FVTool to the figure hFig in the frame
      %   specified by the position POS.  The axes position will by 130 pixels
      %   narrower and 83 pixels shorter than the frame.  It will also be 60 pixels
      %   to the right and 50 pixels higher.
      %
      %   For example a frame position of [300 200 400 250] would result in an axes
      %   position of [360 250 270 167].

      pos = parserenderinputs(this, varargin{:});
      
      % Use the render_component's local functions to save time.
      
      % Render the axes of FVTool
      if ~isempty(pos)
        sz = gui_sizes(this);
        pos = pos + [55 50 -130 -83]*sz.pixf;
      end
      render_component(this,'render_axes', pos);
      
      % Find or create a UIToolbar to render the buttons.
      render_component(this,'render_toolbar');
      
      % Find or create an Analysis menu.
      render_component(this,'render_analysis_menu',3);
      
      % Create th toolbar buttons
      render_component(this,'render_analysis_toolbar');
      
      render_component(this,'render_viewmenu');
      
      % Normalize all the units.
      setunits(this,'Normalized');
      
      % Install Listeners
      attachlisteners(this);
      listeners(this,[], 'postcurrentanalysis_listener');
      listeners(this,[], 'filter_listener');
      
    end
    
    function varargout = userdefinedmask(this)
      %USERDEFINEDMASK   User Defined Mask dialog interface.

      h = getcomponent(this, 'siggui.masklinedlg');
      
      if isempty(h)
        h = siggui.masklinedlg;
        addcomponent(this, h);
        
        opts_listener2(this);
        
        l(1) = event.listener(h, 'DialogApplied', @(s,e)apply_listener(this,e));
        l(2) = event.proplistener(this, this.findprop('UserDefinedMask'),'PostSet', @(s,e)opts_listener2(this,e));
        l(3) = event.listener(this, 'NewPlot', @(s,e)newplot_listener2(this,e));
        
        set(this, 'MaskListeners', l);
        
        newplot_listener2(this);
      end
      
      if ~isrendered(h)
        render(h);
        centerdlgonfig(h, this);
      end
      
      set(h, 'Visible', 'On');
      figure(h.FigureHandle);
      
      if nargout
        varargout = {h};
      end
      
    end
    
    
    function visible_listener(this, ~)
      %VISIBLE_LISTENER Listener to the visible property of FVTool

      h        = get(this,'Handles');
      visState = get(this,'Visible');
      
      set(h.menu.analysis,'Visible',visState);
      set(convert2vector(h.toolbar),'Visible',visState);
      set(this.CurrentAnalysis, 'Visible', visState);
      
      if strcmpi(visState, 'Off')
        hdlg = get(this, 'ParameterDlg');
        if ~isempty(hdlg)
          cancel(hdlg);
        end
      end
      
      
    end
    
    
    function zoom(this, optsflag, varargin)
      %ZOOM   Zoom into the axis.

      if nargin > 1
          optsflag = convertStringsToChars(optsflag);
      end

      if ischar(optsflag)
        switch lower(optsflag)
          case {'passband', 'stopband'}
            bandzoom(this, optsflag);
          case 'x'
            narginchk(3,3);
            x = varargin{1};
            y = get(getbottomaxes(this.CurrentAnalysis), 'YLim');
            lclzoom(this, x, y);
          case 'y'
            narginchk(3,3);
            x = get(getbottomaxes(this.CurrentAnalysis), 'XLim');
            y = varargin{1};
            lclzoom(this, x, y);
          case 'default'
            formataxislimits(this.CurrentAnalysis);
          otherwise
            error(message('signal:siggui:fvtool:zoom:invalidFlag'));
        end
      elseif isnumeric(optsflag)
        
        if length(optsflag) ~= 4
          error(message('signal:siggui:fvtool:zoom:invalidLimits'));
        end
        
        
        x = optsflag(1:2);
        y = optsflag(3:4);
        
        lclzoom(this, x, y);
      else
        error(message('signal:siggui:fvtool:zoom:invalidFlag'));
      end
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function notification_listener(hObj, eventData, varargin)
      %NOTIFICATION_LISTENER

      NTypes = {'ErrorOccurred', 'WarningOccurred', 'StatusChanged', 'FileDirty'};
      obmeta = metaclass(eventData);
      flag = contains('NotificationType',{obmeta.PropertyList.Name});
      if(~flag)
          return;
      end
      NType  = get(eventData, 'NotificationType');
        
        % Switch on the Notification type
        switch NType
          case NTypes{2} % 'WarningOccurred'
            lclcheckwarning(hObj, eventData, varargin{:});
          otherwise
            notify(hObj, 'Notification', eventData);
        end
   
    end
    
    function resetfiltercache(this)
      %RESETFILTERCACHE

      set(this, 'CachedFilters', []);
      
    end
    
    function sendfiltrespwarnings(this)
      %SENDFILTRESPWARNINGS

      frw = get(this, 'FiltRespWarnings');
      for indx = 1:length(frw)
        notification_listener(this, frw(indx), true);
      end
      set(this, 'FiltRespWarnings', []);
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

% -------------------------------------------------------------------------
function out = setparameters(this, out)

pname = 'ParameterListenerProp';
p = findprop(this, pname);
if isempty(p)
  
  % Create a dynamic property to store the listener.  We do this so that
  % it can be private, but we can still set it locally.  xxx
  p = this.addprop(pname);
  p.Hidden = true;
end

l = handle.listener(union(out, this.Parameters), 'NewValidValues', @(s,e)lclvalidvalues_listener(this,e));

 set(this, pname, l);
end  % setparameters


% -------------------------------------------------------------------------
function lclvalidvalues_listener(this, ~)

notify(this, 'NewParameters');
end  % lclvalidvalues_listener


function hPrms = getparams(hPrms)

if ispref('SignalProcessingToolbox', 'DefaultParameters')
  p = getpref('SignalProcessingToolbox', 'DefaultParameters');
  
  % Backwards compatibility.  The freqmode used to be save as 1 or 2, but now
  % must be resaved as 'on' or 'off';
  if ~isempty(p) && isfield(p, 'fvtool') && isfield(p.fvtool, 'freqmode')
    if isnumeric(p.fvtool.freqmode)
      if p.fvtool.freqmode == 1
        p.fvtool.freqmode = 'on';
      elseif p.fvtool.freqmode == 2
        p.fvtool.freqmode = 'off';
      end
      setpref('SignalProcessingToolbox', 'DefaultParameters', p);
    end
  end
end

if isempty(hPrms) || isempty(find(hPrms, 'Tag', 'freqmode'))
  hPrm = sigdatatypes.parameter('Normalized Frequency', 'freqmode', 'on/off', 'on');
  usedefault(hPrm, 'fvtool');
  if isempty(hPrms) 
    hPrms = hPrm;
  else
    hPrms = [hPrms(:); hPrm]; 
  end
end
end  % getparams


%-------------------------------------------------------------------
function [Hd, hPrms] = parseinputs(this, varargin)
% Parse FVTool's inputs
%
%   Outputs:
%     filt        - Cell array of dfilt object(s)
%     analysisStr - Analysis string (e.g., phase, impulse)
%     optinputs   - Structure of optional input arguments

hPrms = [];
if nargin < 2
  Hd    = [];
else
  
  for indx = 1:length(varargin)
    if isa(varargin{indx}, 'sigdatatypes.parameter')
      hPrms = varargin{indx};
      break
    end
  end
  
  Hd = this.findfilters(varargin{:});
end
end  % parseinputs


%-------------------------------------------------------------------
function installanalyses(this)

labels = {getString(message('signal:sigtools:siggui:MagnitudeResponse')), ...
  getString(message('signal:sigtools:siggui:PhaseResponse')), ...
  getString(message('signal:sigtools:siggui:MagnitudeAndPhaseResponses')), ...
  getString(message('signal:sigtools:siggui:GroupDelayResponse')), ...
  getString(message('signal:sigtools:siggui:PhaseDelay')), ...
  getString(message('signal:sigtools:siggui:ImpulseResponse')), ...
  getString(message('signal:sigtools:siggui:StepResponse')), ...
  getString(message('signal:sigtools:siggui:PoleZeroPlot')), ...
  getString(message('signal:sigtools:siggui:FilterCoefficients')), ...
  getString(message('signal:sigtools:siggui:FilterInformation')), ...
  ''};
tags = {'magnitude', 'phase', 'freq', 'grpdelay', 'phasedelay', ...
  'impulse', 'step', 'polezero', 'coefficients', 'info', 'tworesps'};
fcns = {'filtresp.magnitude', 'filtresp.phasez', @lclmagnphase, 'filtresp.grpdelay', ...
  'filtresp.phasedelay', 'filtresp.impz', 'filtresp.stepz', 'filtresp.zplane', ...
  'filtresp.coefficients', 'filtresp.info', {@lcltworesps, this}};

load(fullfile(matlabroot, 'toolbox','signal','sigtools','private','filtdes_icons'));

% Cell array of cdata (properties) for the toolbar icons
pushbtns = {bmp.mag, ...
  bmp.phase, ...
  bmp.magnphase, ...
  bmp.grpdelay, ...
  bmp.phasedelay, ...
  bmp.impulse, ...
  bmp.step, ...
  bmp.polezero, ...
  bmp.coeffs, ...
  bmp.info, ...
  []};

accels = {'M', '', '', 'G', '', 'R', '', '', '', '', ''};

% Loop over the analyses and install them into FVTool
for i = 1:length(labels)
  s.(tags{i}).label = labels{i};
  s.(tags{i}).fcn   = fcns{i};
  s.(tags{i}).icon  = pushbtns{i};
  s.(tags{i}).accel = accels{i};
  s.(tags{i}).check = [];
end

set(this, 'AnalysesInfo', s);
end  % installanalyses


% ---------------------------------------------------------------
function h2 = lclmagnphase(varargin)

h    = filtresp.magnitude(varargin{:});
h(2) = filtresp.phasez(varargin{:}, getparameter(h));

h(1).IsOverlayedOn = true;
h(2).IsOverlayedOn = true;

h2   = filtresp.tworesps(h);
end  % lclmagnphase


% ---------------------------------------------------------------
function h2 = lcltworesps(this, varargin)

f = get(this, 'Analysis');
s = get(this, 'OverlayedAnalysis');

h    = getanalysisobject(this, f, true);
h(2) = getanalysisobject(this, s, true);

h(1).IsOverlayedOn = true;
h(2).IsOverlayedOn = true;

h2 = filtresp.tworesps(h);
end  % lcltworesps


%-------------------------------------------------------------------------
function analysis_cb(hcbo, eventStruct, hObj) %#ok<INUSL>
%ANALYSIS_CB Callback for the analysis menu item and pushbutton.

hFig = get(hObj, 'FigureHandle');
p = getptr(hFig);
setptr(hFig, 'watch');
lastwarn('');

% Set the current analysis to the tag of the HG object.
analysis = get(hcbo,'Tag');

set(hObj, 'Analysis', analysis);

% Make sure that the toolbar button remains pressed
if strcmpi('uitoggletool', get(hcbo,'Type'))
  set(hcbo, 'State', 'On');
end

set(hFig, p{:});

end

%-------------------------------------------------------------------------
function righthand_cb(hcbo, eventStruct, hObj) %#ok<INUSL>

hFig = get(hObj, 'FigureHandle');
p = getptr(hFig);
setptr(hFig, 'watch');
lastwarn('');

analysis = get(hcbo, 'Tag'); analysis = analysis(11:end);

set(hObj, 'OverlayedAnalysis', analysis);

set(hFig, p{:});

end

% ---------------------------------------------------------------
function lclfilter_listener(hdlg, eventData)

set(hdlg, 'Filters', eventData.AffectedObject.Filters);

end

% ---------------------------------------------------------------
function onDialogBeingApplied(this)

this.UpdateAxisScaleSettings = false;

end

% ---------------------------------------------------------------
function onDialogApplied(this)

this.UpdateAxisScaleSettings = true;

end


% --------------------------------------------------------------------
function analysis_listener(this, eventData, prop) %#ok<INUSD>
%ANALYSIS_LISTENER Listener for the Current Analysis property

% Avoid zoom reset and update of axis scale by setting
% UpdateAxisScaleSettings to false before changing the analysis. Then
% restore to original state.
currentFlagValue = this.UpdateAxisScaleSettings;
this.UpdateAxisScaleSettings = false;


tag  = get(this, 'Analysis');

if isempty(tag)
  newa = [];
  
else
  
  % Get the new analysis object.
  sa = get(this, 'OverlayedAnalysis');
  if isempty(sa)
    newa = getanalysisobject(this);
  else
    try
      newa = buildtworesps(this);
    catch me %#ok<NASGU>
      set(this, 'OverlayedAnalysis', '');
      return; % Return because the OverlayedAnalysis listener will take care of this.
    end
  end
end

set(this, 'CurrentAnalysis', newa);

% Make sure that we check the correct string.  This wasn't being updated
% for Two Resps, because the listener wasn't being called.
if isrendered(this)
  drawnow;
  h = get(this, 'Handles');
  set(convert2vector(h.menu.analyses), 'Checked', 'Off');
  set(convert2vector(h.toolbar.analyses), 'State', 'Off');
  if ~isempty(tag)
    set(h.menu.analyses.(tag), 'Checked', 'On');
    set(h.toolbar.analyses.(tag), 'State', 'On');
  end
end

set(this, 'SubMenuFixed', false);

sendfiltrespwarnings(this);

this.UpdateAxisScaleSettings = currentFlagValue;

end

% --------------------------------------------------------------------
function secondanalysis_listener(this, eventData) %#ok<*DEFNU>

% Avoid zoom reset and update of axis scale by setting
% UpdateAxisScaleSettings to false before changing the analysis. Then
% restore to original state.
currentFlagValue = this.UpdateAxisScaleSettings;
this.UpdateAxisScaleSettings = false;

s = get(this, 'OverlayedAnalysis');
if isempty(s)
  analysis_listener(this, eventData);
  s = 'none';
else
  
  try
    
    % If we can build a tworesps with the 2nd response use it.
    ht = buildtworesps(this);
    set(this, 'CurrentAnalysis', ht);
  catch me %#ok<NASGU>
    
    % If we cannot ignore it.
    set(this, 'OverlayedAnalysis', '');
    analysis_listener(this, eventData);
    s = 'none';
  end
end

if isrendered(this)
  h  = get(this, 'Handles');
  
  set(h.menu.righthand.(s), 'Checked', 'On');
  set(convert2vector(rmfield(h.menu.righthand, s)), 'Checked', 'Off');
end

% Send the warnings once everything is done.
sendfiltrespwarnings(this);

this.UpdateAxisScaleSettings = currentFlagValue;

end

% --------------------------------------------------------------------
function precurrentanalysis_listener(this, eventData, varargin) %#ok<INUSD>

ca = get(this, 'CurrentAnalysis');
h  = get(this, 'Handles');

sendstatus(this, [getString(message('signal:sigtools:siggui:ComputingResponse')) ' ...']);

if ~isempty(ca)
  
  hdlg = get(this, 'ParameterDlg');
  rmcomponent(ca, hdlg);
  if iscell(ca.WhenRenderedListeners)
    for i = 1:length(ca.WhenRenderedListeners)
      delete(ca.WhenRenderedListeners{i});
    end
  else
    delete(ca.WhenRenderedListeners);
  end
  
  unrender(ca);
end
set([h.axes h.listbox], 'Visible', 'Off');
b = hggetbehavior(h.axes(2), 'Zoom');
b.Enable = false;
b = hggetbehavior(h.axes(1), 'Zoom');
b.Enable = false;

set(convert2vector(h.menu.analyses), 'Checked', 'Off');
set(convert2vector(h.toolbar.analyses), 'State', 'Off');

end

% --------------------------------------------------------------------
function postcurrentanalysis_listener(this, eventData)

ca   = get(this, 'CurrentAnalysis');
h    = get(this, 'Handles');

tag = get(this, 'Analysis');

zoomBehavior1 = hggetbehavior(h.axes(1), 'Zoom');
zoomBehavior2 = hggetbehavior(h.axes(2), 'Zoom');

if isempty(tag)
  zoomBehavior1.Enable = false;
  zoomBehavior2.Enable = false;
  return;
end

% Check the current analysis
set(h.menu.analyses.(tag), 'Checked', 'On');
set(h.toolbar.analyses.(tag), 'State', 'On');

if isempty(ca)
  enabState = 'Off';
  l = [];
else
    
l = [event.listener(ca,'NewPlot', @(~,e)listeners(this,e,'newplot_listener')),...
  event.proplistener(ca,ca.findprop('Legend'), 'PostSet', @(~,e)analysislegend_listener(this,e))];

  % Sync up the filters
  ca.FastUpdate = this.FastUpdate;
  ca.Filters = this.Filters;
  ca.ShowReference = this.ShowReference;
  ca.PolyphaseView = this.PolyphaseView;
  ca.SOSViewOpts = this.SOSViewOpts;
  
  % Render the new analysis depending on what class it is.
  if isa(ca, 'sigresp.analysisaxis')
    set(ca, 'Legend', this.Legend, 'Grid', this.Grid);
    if isprop(ca, 'UserDefinedMask'), set(ca, 'UserDefinedMask', this.UserDefinedMask); end
    render(ca, h.axes);
    enabState = 'On';
  elseif isa(ca, 'sigresp.listboxanalysis')
    render(ca, h.listbox);
    enabState = 'Off';
  else
    render(ca, [h.axes, h.listbox]);
    enabState = 'Off';
  end
  
  % Sync up the filters
  set(ca, 'Visible', this.Visible);
end

if any(strcmp(get(h.axes, 'Visible'), 'on')) || strcmp(tag,'magnitude')
  zoomBehavior1.Enable = true;
  zoomBehavior2.Enable = true;
end

% Set up the parameter dialog.
hdlg = get(this, 'ParameterDlg');
if ~isempty(hdlg)
  
  if isempty(ca)
    set(hdlg, 'Parameters', [], 'Label', 'Analysis Parameters');
  else
    if isrendered(hdlg)
      setupparameterdlg(ca, hdlg);
      cshelpcontextmenu(hdlg.FigureHandle, handles2vector(hdlg), ...
        'fvtool_analysis_parameters', 'FDATool');
    end
  end
end

% Disable the grid/legend menu items if the analysis object does not use
% usesaxes.
hview = h.menu.view;
he = [hview.grid, hview.legend];
set(he, 'Enable', enabState);

set(this, 'CurrentAnalysisListener', l);

displaymask_listener(this, eventData);

sendstatus(this, [getString(message('signal:sigtools:siggui:ComputingResponse')) ...
  ' ... ' getString(message('signal:sigtools:siggui:Done'))]);


sendfiltrespwarnings(this);
updatezoommenus(this);

% Reset zoom state
for idx = 1:length(h.axes)
  zoom(h.axes(idx),'reset')
end

end

% --------------------------------------------------------------------
function filter_listener(this, eventData) %#ok

% Get the analysis info that contains the check function.
aInfo = get(this, 'AnalysesInfo');
fn = fieldnames(aInfo);
fn = setdiff(fn, 'tworesps'); % Remove tworesps
h = get(this, 'Handles');

% Loop over each analysis and check that the filters are valid.
for indx = 1:length(fn)
  if ~isempty(aInfo.(fn{indx}).check) && ~feval(aInfo.(fn{indx}).check, this.Filters)
    
    % Disable the menu and toolbars if the analysis isn't valid.
    set([h.toolbar.analyses.(fn{indx}) h.menu.analyses.(fn{indx})], 'Enable', 'Off');
    
    % If we are on an invalid analysis go back to magnitude.
    if strcmpi(this.Analysis, fn{indx})
      set(this, 'Analysis', 'magnitude');
    end
  else
    set([h.toolbar.analyses.(fn{indx}) h.menu.analyses.(fn{indx})], 'Enable', 'On');
  end
end

set(this, 'SubMenuFixed', false);
fix_submenu(this);

end

% --------------------------------------------------------------------
function analysislegend_listener(this, eventData) %#ok<INUSD>

set(this, 'Legend', get(this.CurrentAnalysis, 'Legend'));

end

% --------------------------------------------------------------------
function show_listener(this, eventData) %#ok<INUSD>

h = get(this, 'Handles');

% This should never change when the handle doesn't exist.

set(h.menu.view.showreference, 'Checked', get(this, 'ShowReference'));
set(h.menu.view.polyphaseview, 'Checked', get(this, 'PolyphaseView'));

end

% --------------------------------------------------------------------
function newanalysis_eventcb(this, eventData)

tag = eventData.Data;

% Render the new button and menuitem
render_component(this, 'render_analysis_button', tag);
render_component(this, 'render_analysis_menuitem', tag);

end

% --------------------------------------------------------------------
function newplot_listener(this, eventData)

displaymask_listener(this, eventData)
updatezoommenus(this);
notify(this, 'NewPlot', eventData);

end

% --------------------------------------------------------------------
function displaymask_listener(this, eventData) %#ok<INUSD>

ha = get(this, 'CurrentAnalysis');
h  = get(this, 'Handles');

if isempty(ha) || ~enablemask(ha)
  enabState = 'Off';
  checked   = 'Off';
else
  enabState = 'On';
  checked   = this.DisplayMask;
end

set(h.menu.view.displaymask, 'Enable', enabState, 'Checked', checked);

end

% -------------------------------------------------------------------
function legend_listener(this, eventData) %#ok<INUSD>

h = get(this, 'Handles');

visState = get(this,'Legend');

% Change the state of the legend toggle button
if isfield(h.toolbar, 'legend')
  set(h.toolbar.legend,'State',visState);
end
set(h.menu.view.legend, 'Checked', visState);

end

% -------------------------------------------------------------------
function grid_listener(this, eventData) %#ok<INUSD>

grid = get(this, 'Grid');

h = get(this, 'Handles');

set(h.menu.view.grid, 'Checked', grid);

if isfield(h.toolbar, 'grid')
  set(h.toolbar.grid, 'State', grid);
end

end

% -------------------------------------------------------------------
function fseditable_listener(this, eventData) %#ok<INUSD>

fse = get(this, 'FsEditable');

h = get(this, 'Handles');

hfs = h.menu.params.fs;

set(hfs(ishghandle(hfs)), 'Visible', fse);

hdlg = getcomponent(this, '-class', 'siggui.dfiltwfsdlgMCOS');
if ~isempty(h)
  set(hdlg, 'Enable', fse, 'Filters', get(this, 'Filters'));
end

end

% -------------------------------------------------------------------
function axesgrid_listener(this, eventData)

set(this, 'Grid', get(eventData.AffectedObject, eventData.Source.Name));

end

% -------------------------------------------------------------------
function axesxscale_listener(this, eventData)

% Check if callback come from the axes properties editor. If so, then
% update the analysis parameters frequency scale popup and reset the zoom
% state.

% If the UpdateAxisScaleSettings flag is true, then it means that user is
% changing the scale through the axes properties editor. We need to update
% the scale dialog and reset the zoom.
if this.UpdateAxisScaleSettings
  paramStruct = param2struct(this.Parameters);
  ff = fields(paramStruct);
  idx = find(strcmp(ff,'freqscale')==true);
  if strcmpi(get(eventData.AffectedObject,'XScale'),'log')
    setvalue(this.Parameters(idx),'Log')
  else
    setvalue(this.Parameters(idx),'Linear')
  end
  zoom(eventData.AffectedObject, 'reset');
end

end

% -------------------------------------------------------------------
function ht = buildtworesps(this)
%Build the two responses object for the 2nd analysis.

f = get(this, 'Analysis');
s = get(this, 'OverlayedAnalysis');

ht    = getanalysisobject(this, 'tworesps');
ha    = getanalysisobject(this, f, 'new');

axisParam = getxaxisparams(ha);
ha(2) = getanalysisobject(this, s, 'new', axisParam);

ht.Analyses = ha;
for i = 1:length(ht.Analyses) 
  ht.Analyses(i).IsOverlayedOn = true;
end

end

% -------------------------------------------------------------------
function updatezoommenus(this, varargin)

ca = get(this, 'CurrentAnalysis');

passEnab = 'Off';
stopEnab = 'Off';

if ~isempty(ca)
  Hd = get(ca.Filters, 'Filter');
  if iscell(Hd)
    Hd = [Hd{:}];
  end
  if isempty(Hd)
    x = nan;
    y = nan;
  else
    for indx = 1:length(Hd)
      hdesign = getfdesign(Hd(indx));
      hmethod = getfmethod(Hd(indx));
      if isempty(hdesign) || isempty(hmethod)
        x = nan;
        y = nan;
      elseif ~haspassbandzoom(hdesign)
        x = nan;
        y = nan;
      else
        x = 1;
        y = 1;
      end
    end
  end
  if ~any([isnan(x) isnan(y)]) && isa(ca, 'filtresp.magnitude')
    passEnab = 'On';
  elseif enablemask(ca) && length(Hd) == 1 && isprop(Hd, 'MaskInfo')
    mi = get(Hd, 'MaskInfo');
    bands = mi.bands;
    for indx = 1:length(bands)
      
      if isfield(bands{indx}, 'magfcn')
        switch bands{indx}.magfcn
          case {'cpass', 'pass', 'wpass'}
            passEnab = 'On';
          case {'wstop', 'stop'}
            stopEnab = 'On';
        end
      end
    end
  end
end

h = get(this, 'Handles');

set(h.menu.view.passband, 'Enable', passEnab);
set(h.menu.view.stopband, 'Enable', stopEnab);



end


% --------------------------------------------------------------
function lclcheckwarning(hObj, eventData, varargin)

if isa(eventData.Source, 'sigresp.abstractanalysis') && nargin < 3
  
  % Cache the warnings thrown from filtresp.abstractresp objects for
  % later use.  We do this to prevent flicker in the axes.  These
  % warnings will be thrown when the axes is done drawing.
  frw = get(hObj, 'FiltRespWarnings');
  if isempty(frw)
    frw = eventData;
  else
    frw(end+1) = eventData;
  end
  set(hObj, 'FiltRespWarnings', frw);
else
  
  lstr = eventData.Data.WarningString;
  lid  = eventData.Data.WarningID;
  
  % If there is a warning to display, don't display the finished message
  lid = fliplr(strtok(fliplr(lid), ':'));
  
  if any(strcmpi(lid, {'syntaxchanged', 'NextPlotNew', 'useLegendMethod'})) || ...
      ~isempty(findstr(lower(lstr), 'axes limit range too small'))
    return;
  else
    switch lstr
      case getString(message('MATLAB:Axes:NegativeDataInLogAxis'))
        eventData.Data.WarningString = ...
          getString(message('signal:siggui:fvtool:setanalysis:NegfreqIgnoredwhenusinglogscale'));
    end
  end
  
  notify(hObj, 'Notification', eventData);
  
end

end

% ----------------------------------------------------------
function s = lclbuildstruct(lbl, fcn, icon, accel, checkfcn)

s.label = lbl;
s.fcn   = fcn;
s.icon  = icon;
s.accel = accel;
s.check = checkfcn;
end

%-------------------------------------------------------------------
function render_analysisparamsmenu(this, hp, sep)

narginchk(2,3);
if nargin < 3, sep = 'On'; end

% Add a menu item to get at the analysis parameters
cbs = callbacks(this);

h = get(this, 'Handles');

if ~isfield(h, 'menu') || ~isfield(h.menu, 'params')
  h.menu.params.analysis = []; h.menu.params.fs = []; h.menu.params.srr = [];
end

h.menu.params.analysis(end+1) = uimenu(hp, ...
  'Label', getString(message('signal:sigtools:siggui:AnalysisParameters')), ...
  'Callback', cbs.editparams, ...
  'Separator', sep, ...
  'Tag', 'fvtool_editanalysis');
h.menu.params.fs(end+1) = uimenu(hp, ...
  'Label', getString(message('signal:sigtools:siggui:SamplingFrequency2')), ...
  'Callback', cbs.editfs, ...
  'Visible', this.FsEditable, ...
  'Tag', 'fvtool_fs');

set(this, 'Handles', h);

end

% ----------------------------------------------------------------
function render_analysis_menu(this, position) 
%RENDER_ANALYSIS_MENU Render an "Analysis" menu.

render_toplevel(this, position);
render_parameters(this);

% Loop over the tags and render the analysis submenu
info = get(this, 'AnalysesInfo');
tags = fieldnames(info);
for i = 1:length(tags)
  render_analysis_menuitem(this, tags{i});
end

end

% ----------------------------------------------------------------
function render_parameters(this)

h = get(this, 'Handles');

% We arent using addmenu here, because we would have to determine which
% menu is currently the analysis menu and determine where to place the
% menu items.  It's easier to just call UIMENU

hp  = h.menu.analysis;
cbs = callbacks(this);

h.menu.righthand.main = uimenu(hp, ...
  'Label', getString(message('signal:sigtools:siggui:OverlayAnalysis')), ...
  'Separator', 'On', ...
  'Callback', {@lclfix_submenu, this}, ...
  'Tag', 'fvtool_righthandyaxis');
h.menu.righthand.none = uimenu(h.menu.righthand.main, ...
  'Label', getString(message('signal:sigtools:siggui:None')), ...
  'Tag', 'righthand_', ...
  'Checked', 'On', ...
  'Callback', cbs.righthand);

set(this, 'Handles', h);

render_analysisparamsmenu(this, hp);

end

% ----------------------------------------------------------------
function render_viewmenu(this, pos) 

hFig = get(this, 'FigureHandle');
h    = get(this,'Handles');
cbs  = callbacks(this);

h.menu.view.main = findobj(hFig, 'type','uimenu','tag','view');

if isempty(h.menu.view.main)
  if nargin < 2
    pos = length(findobj(hFig, 'type', 'uimenu', 'parent', hFig))+1;
  end
  h.menu.view.main = addmenu(hFig, pos, '&View', '', 'view', 'Off', '');
end

soscb = {cbs.method, this, 'sosview'};

lbls = {getString(message('signal:sigtools:siggui:Grid')), getString(message('signal:sigtools:siggui:Legend')), getString(message('signal:sigtools:siggui:SpecificationMask')), ...
  [getString(message('signal:sigtools:siggui:UserdefinedSpectralMask')) '...'], getString(message('signal:sigtools:siggui:Passband')), getString(message('signal:sigtools:siggui:Stopband'))};
pos  = [0 0 0 0 repmat(length(allchild(h.menu.view.main)), 1, 2)];
chk  = {this.Grid, this.Legend, this.DisplayMask, 'Off', 'Off', 'Off'};
tags = {'grid', 'legend', 'displaymask', 'userdefinedmask', 'passband', 'stopband'};
cbs  = {{@checkmenu_cb, this}, {@checkmenu_cb, this}, {@checkmenu_cb, this}, ...
  {cbs.method, this, 'userdefinedmask'}, {cbs.method, this, @lclbandzoom, [], 'pass'}, ...
  {cbs.method, this, @lclbandzoom, [], 'stop'}};
sep  = {'Off', 'Off', 'Off', 'Off', 'On', 'Off'};

allowplugins = getappdata(hFig, 'allowplugins');
if isempty(allowplugins)
  allowplugins = true;
end

if allowplugins && isfdtbxinstalled
  lbls = {lbls{1:4}, getString(message('signal:sigtools:siggui:ShowReferenceFilters')), ...
    getString(message('signal:sigtools:siggui:PolyphaseView')), lbls{5:6}, [getString(message('signal:sigtools:siggui:SOSViewSettings')) ' ...']};
  pos  = [pos(1:4) 0 0 pos(5:6) pos(5)];
  chk  = {chk{1:4}, this.ShowReference, this.PolyphaseView, chk{5:6}, 'Off'};
  tags = {tags{1:4}, 'showreference', 'polyphaseview', tags{5:6}, 'sosview'};
  cbs  = {cbs{1:4}, cbs{1:2}, cbs{5:6}, soscb};
  sep  = {sep{1:4}, 'Off', 'Off', sep{5:6}, 'On'};
end

if ~isempty(allchild(h.menu.view.main))
  hfirst = findobj(h.menu.view.main, 'position', 1, 'parent', h.menu.view.main);
  set(hfirst, 'Separator', 'on');
end

for indx = 1:length(lbls)
  h.menu.view.(tags{indx}) = uimenu(h.menu.view.main, ...
    'Position', indx + pos(indx), ...
    'Label', lbls{indx}, ...
    'Tag', ['fvtool_' tags{indx}], ...
    'Checked', chk{indx}, ...
    'Callback', cbs{indx}, ...
    'Enable', 'On', ...
    'Separator', sep{indx});
end

set([h.menu.view.passband h.menu.view.stopband h.menu.view.displaymask], ...
  'Enable', 'Off');

set(this, 'Handles', h);

end

% ----------------------------------------------------------------
function render_toplevel(this, position)

hFig = get(this,'FigureHandle');
h    = get(this,'Handles');

% Render the Analysis menu items
h.menu.analysis = findobj(hFig, 'type', 'uimenu', 'tag', 'analysis');

% If there is no 'analysis' menu, create one.
if isempty(h.menu.analysis)
  h.menu.analysis = addmenu(hFig,position,getString(message('signal:sigtools:siggui:Analysis')),'','analysis','Off','');
  %     drawnow; % Not sure why this is here
end

h.menu.analyses = [];

set(this,'Handles',h);

end

% ----------------------------------------------------------------
function render_analysis_menuitem(this, tag)
%RENDER_ANALYSIS_BUTTON Render an analysis button
%   RENDER_ANALYSIS_BUTTON(this, TAG) Render the analysis button associated
%   with the tag TAG.

% Get the handle information for rendering
h    = get(this, 'Handles');
cbs  = callbacks(this);

% Get the CData information
info = get(this,'AnalysesInfo');
info = info.(tag);

% If there is no label provided, don't render a menu.
if isempty(info.label), return; end

position = get(findobj(h.menu.analysis, 'tag', 'fvtool_righthandyaxis'), 'Position');

sep = 'off';
if position > 1 && isempty(h.menu.analyses), sep = 'on'; end

inputs = {'Label',info.label};

h.menu.analyses.(tag) = uimenu(inputs{:}, ...
  'Accelerator',info.accel, ...
  'Parent',   h.menu.analysis,...
  'Callback', cbs.analysis,...
  'Tag',      tag,...
  'Separator', sep, ...
  'Position',  position); % This position will make the buttons render in order.

if length(get(h.menu.righthand.main, 'Children')) == 1
  sep = 'On';
else
  sep = 'Off';
end

h.menu.righthand.(tag) = uimenu(inputs{:}, ...
  'Parent',   h.menu.righthand.main, ...
  'Callback', cbs.righthand, ...
  'Tag',      sprintf('righthand_%s', tag), ...
  'Separator', sep);

set(this, 'Handles', h);

end

% ----------------------------------------------------------------
function render_analysis_toolbar(this) 
%RENDER_TOOLBAR Render the toolbar for FVTool.

% Loop over the tags and render the analysis toolbar
info = get(this, 'AnalysesInfo');
tags = fieldnames(info);
for i = 1:length(tags)
  render_analysis_button(this, tags{i});
end

end

% ----------------------------------------------------------------
function render_toolbar(this)
%RENDER_TOOLBAR Render the toolbar if none exists

h = get(this,'Handles');

hFig = get(this,'FigureHandle');

% Look for a toolbar to use.
aut = findall(hFig, 'type', 'uitoolbar', 'tag', 'analysistoolbar');
ut  = setdiff(findobj(hFig, 'type', 'uitoolbar'), aut);
if isempty(ut)
  
  % If a toolbar is not available, create one.
  ut = uitoolbar(hFig);
elseif length(ut) > 1
  
  % If there is more than one toolbar, use the parent of the newanalysis
  % toggle button.
  ut = get(findall(ut, 'tag', 'newanalysis'), 'Parent');
end
h.toolbar.analysis  = aut;
h.toolbar.figure    = ut;

set(this, 'Handles', h);

end

% ----------------------------------------------------------------
function render_analysis_button(this, tag)
%RENDER_ANALYSIS_BUTTON Render an analysis toolbar button

% Get the handle information for rendering
h     = get(this, 'Handles');
cbs   = callbacks(this);

% Get the CData information
info = get(this,'AnalysesInfo');
info = info.(tag);

% If no icon is given, do not render a toggle button
if isempty(info.icon), return; end

if ishghandle(h.toolbar.analysis)
  hut = h.toolbar.analysis;
else
  hut = h.toolbar.figure;
end

% Determine if there should be a separator
if ~(isempty(allchild(hut)) || isfield(h.toolbar, 'analyses'))
  sep = 'On';
else
  sep = 'Off';
end

h.toolbar.analyses.(tag) = uitoggletool('CData',info.icon, ...
  'Parent',          hut, ...
  'ClickedCallback', cbs.analysis, ...
  'Tag',             tag, ...
  'Separator',       sep, ...
  'TooltipString',   info.label);

set(this, 'Handles', h);

end


% ----------------------------------------------------------------
function render_axes(this, pos) 
%RENDER_AXES Render the axes for the FVTool

h    = get(this,'Handles');
hFig = get(this,'FigureHandle');

sigsetappdata(hFig, 'fvtool', 'handle', this);

defpos = get(0, 'DefaultAxesPosition');
defpos(3) = defpos(3)*.975;

% Create axes in the default position.
h.axes(2) = axes('Parent',hFig,...
  'Units','Normalized',...
  'Visible',this.Visible,...
  'ActivePositionProperty', 'position', ...
  'Position', defpos, ...
  'Tag','fvtool_axes_1');
h.axes(1) = axes('Parent',hFig,...
  'Units','Normalized',...
  'Visible',this.Visible,...
  'ActivePositionProperty', 'position', ...
  'Position', defpos, ...
  'HandleVisibility', 'Callback', ...
  'Tag','fvtool_axes_2');

% Disable AxesToolbar
h.axes(1).Toolbar = [];
h.axes(2).Toolbar = [];

% Link the yticks for the 2 axes, but not the ylimits.
setappdata(h.axes(2),'graphicsPlotyyPeer',h.axes(1));
setappdata(h.axes(1),'graphicsPlotyyPeer',h.axes(2));

% Link the 2 axes XLim and DataAspectRatioMode properties to prevent axis
% resize on zoom.
hlink(1) = linkprop(h.axes,'DataAspectRatioMode');
hlink(2) = linkprop(h.axes,'XLim');
hlink(3) = linkprop(h.axes, 'XScale');
setappdata(h.axes(1),'hlink',hlink);

h.listbox = uicontrol('Parent',hFig,...
  'Units','Pixels',...
  'Style','Listbox',...
  'Visible',this.Visible,...
  'Tag','fvtool_listbox',...
  'BackgroundColor','w');

fdaddcontextmenu(hFig, h.listbox,'fdatool_filtercoefficients_viewer');

% If we have received a position use it.
if nargin == 2 && ~isempty(pos)
  set(h.axes, 'Units', 'Pixels', 'Position', pos);
  set(h.listbox, 'Position', pos);
else
  
  if ispc, fontname = 'MS Sans Serif';
  else     fontname = 'monospaced'; end
  
  % Make sure that the listbox is the same size as the axes.
  set(h.listbox, ...
    'FontName', fontname, ...
    'Units',    get(0, 'DefaultAxesUnits'), ...
    'Position', defpos);
end

set(this,'Handles',h);

hc = uicontextmenu('Parent', hFig);

set(h.axes, 'UIContextMenu', hc);

render_analysisparamsmenu(this, hc, 'Off');

end

% -------------------------------------------------------------------
function checkmenu_cb(hcbo, eventStruct, this) %#ok

prop = strrep(get(hcbo, 'Tag'), 'fvtool_', '');

if strcmp(prop,'legend')
  prop = 'Legend';
end

if strcmp(prop,'polyphaseview')
  prop = 'PolyphaseView';
end

if strcmpi(get(this, prop), 'On')
  check = 'off';
else
  check = 'on';
end
% Remove 'fvtool_' from the tag to get the property name.
set(this, prop, check);

end

% -------------------------------------------------------------------
function lclfix_submenu(hcbo, eventStruct, this) %#ok

% Needs to be a method to have access to private props.
fix_submenu(this);

end


% -------------------------------------------------------------------
function lclbandzoom(this, band)
%LCLBANDZOOM zooms in on the passband or the stopband of the filter.

zoom(this, [band 'band']);

end

% -------------------------------------------------------------------------
function b = lclisquantized(filters)

% Return true if any of the filters are quantized.
b = false;
if isempty(filters), return; end
for indx = 1:length(filters)
  b = isquantized(filters(indx).Filter) || b;
end

end


% -------------------------------------------------------------------------
function opts_listener(this, ~)

hdlg = getcomponent(this, '-class', 'siggui.sosviewdlg');
opts = get(this, 'SOSViewOpts');
if ~isempty(opts)
  setopts(hdlg, opts);
end

end

% -------------------------------------------------------------------------
function lcldialogapplied_listener(this, eventData)

% If the current filter is not a single SOS filter warn that we will be
% ignoring the settings.
Hd = get(this, 'Filters');

% Check if we will actually use the settings for the current filter.
if length(Hd) ~= 1
  warnstate = true;
elseif ~isa(Hd.Filter, 'dfilt.abstractsos')
  warnstate = true;
else
  warnstate = false;
end

% If we aren't going to use the settings put up a dontshowagaindlg.
if warnstate
  h = siggui.dontshowagaindlg;
  set(h, ...
    'Name', 'SOS View', ...
    'Text', {getString(message('signal:sigtools:fvtool:notification_listener:sosviewwarning'))}, ...
    'PrefTag', 'sosviewwarning');
  
  % The need2show method returns false if the user has checked the box in
  % the past.  If it returns true, render the dialog and make it visible.
  if h.need2show
    
    render(h);
    set(h, 'Visible','on');
    
    % Add a listener to the parent being deleted so that we can
    % destroy the dontshowagain dialog.
    addlistener(this.FigureHandle, 'ObjectBeingDestroyed', ...
      @(hh, eventStruct) delete(h));
  end
end

this.SOSViewOpts = setpropval(this,copy(getopts(eventData.Source, this.SOSViewOpts)),'SOSViewOpts');

end

% --------------------------------------------------------------------
function attachlisteners(this)

l.handle(1) =  event.proplistener(this, this.findprop('Filters'),         'PostSet', @(~, ev) listeners(this, ev, 'filter_listener'));
l.handle(2) =  event.proplistener(this, this.findprop('ShowReference'),   'PostSet', @(~, ev) listeners(this, ev, 'show_listener'));
l.handle(3) =  event.proplistener(this, this.findprop('PolyphaseView'),   'PostSet', @(~, ev) listeners(this, ev, 'show_listener'));
l.handle(4) =  event.proplistener(this, this.findprop('CurrentAnalysis'), 'PreSet',  @(~, ev) listeners(this,  ev, 'precurrentanalysis_listener','Pre_Set'));
l.handle(5) =  event.proplistener(this, this.findprop('CurrentAnalysis'), 'PostSet', @(~, ev) listeners(this, ev, 'postcurrentanalysis_listener'));
l.handle(6) =  event.proplistener(this, this.findprop('DisplayMask'),     'PostSet', @(~, ev) listeners(this, ev, 'displaymask_listener'));
l.handle(7) =  event.listener(this, 'NewAnalysis',                                   @(~, ev) listeners(this, ev, 'newanalysis_eventcb'));
l.handle(8) =  event.proplistener(this, this.findprop('Grid'),            'PostSet', @(~, ev) listeners(this, ev, 'grid_listener'));
l.handle(9) =  event.proplistener(this, this.findprop('Legend'),          'PostSet', @(~, ev) listeners(this, ev, 'legend_listener'));
l.handle(10) = event.proplistener(this, this.findprop('FsEditable'),      'PostSet', @(~, ev) listeners(this, ev, 'fseditable_listener'));

h  = get(this, 'Handles');
l.event = [ ...
  event.proplistener(h.axes(1), h.axes(1).findprop('XGrid'), 'PostSet', @(~, e) listeners(this, e, 'axesgrid_listener')) ...
  event.proplistener(h.axes(1), h.axes(1).findprop('YGrid'), 'PostSet', @(~, e) listeners(this, e, 'axesgrid_listener')) ...
  event.proplistener(h.axes(2), h.axes(2).findprop('XGrid'), 'PostSet', @(~, e) listeners(this, e, 'axesgrid_listener')) ...
  event.proplistener(h.axes(2), h.axes(2).findprop('YGrid'), 'PostSet', @(~, e) listeners(this, e, 'axesgrid_listener')) ...
  event.proplistener(h.axes(1), h.axes(1).findprop('XScale'),'PostSet', @(~, e) listeners(this, e, 'axesxscale_listener')) ...
  event.proplistener(h.axes(2), h.axes(2).findprop('XScale'),'PostSet', @(~, e) listeners(this, e, 'axesxscale_listener'))];

set(this,'WhenRenderedListeners',l);

end

% -------------------------------------------------------------------------
function newplot_listener2(this, ~)

hdlg = getcomponent(this, 'siggui.masklinedlg');
if ~strcmpi(this.Analysis, 'magnitude')
  close(hdlg);
  return;
end

eu = getappdata(this.Handles.axes(2), 'EngUnitsFactor');

if ~isempty(eu)
  
  % Get the units from the contained object.
  units = getunits(this.CurrentAnalysis);
  
  if isempty(units)
    units = 'Hz';
  end
  set(hdlg, 'FrequencyUnits', units);
end

end


% -------------------------------------------------------------------------
function opts_listener2(this, ~)

hdlg = getcomponent(this, '-class', 'siggui.masklinedlg');
opts = get(this, 'UserDefinedMask');
if ~isempty(opts)
  setmaskline(hdlg, opts);
end

end

% -------------------------------------------------------------------------
function apply_listener(this, eventData)

h = eventData.Source;

set(this, 'UserDefinedMask', getmaskline(h));

end

% -------------------------------------------------------------------------
function lclzoom(this, x, y)

hBottomAxes = getbottomaxes(this.CurrentAnalysis);
if any(isnan(y)) || diff(y) == 0
  set(hBottomAxes, 'XLim', x);
else
  set(hBottomAxes, 'XLim', x, 'YLim', y);
end

end

% -------------------------------------------------------------------------
function bandzoom(this, band)

Hd = get(this, 'Filters');

if strcmpi(get(getparameter(this, 'freqmode'), 'Value'), 'off')
  fs = get(Hd, 'Fs');
  if iscell(fs)
    fs = fs{1};
  end
  fs = engunits(fs/2)*2;
else
  fs = 2;
end

% Get the filter (DFILT) out of the dfiltwfs.
Hd = get(Hd, 'Filter');

if iscell(Hd)
  Hd = [Hd{:}];
end

ca = get(this, 'CurrentAnalysis');

if ~isa(ca, 'filtresp.magnitude')
  error(message('signal:siggui:fvtool:zoom:invalidResponse', band));
end

magunits = get(ca, 'MagnitudeDisplay');
switch lower(magunits)
  case 'magnitude (db)'
    magunits = 'db';
  case {'magnitude', 'zero-phase'}
    magunits = 'linear';
  case 'magnitude squared'
    magunits = 'squared';
end

if strcmpi(band, 'passband')
  [x, y] = passbandzoom(Hd, magunits, fs);
else
  x = nan;
  y = nan;
end
if any([isnan(x) isnan(y)])
  
  if ~isprop(Hd, 'MaskInfo')
    error(message('signal:siggui:fvtool:zoom:noFDESIGN', band));
  end
  
  mi = get(Hd, 'MaskInfo');
  b  = mi.bands;
  
  % Find the index of all bands that apply
  indx = [];
  for i = 1:length(b)
    if isfield(b{i}, 'magfcn')
      if ~isempty(findstr(b{i}.magfcn, band(1:4)))
        if any(strcmpi(b{i}.magfcn, {'cpass', 'wpass', 'wstop'}))
          band = b{i}.magfcn;
        end
        indx = [indx i]; 
      end
    end
  end
  
  % Get the frequency and amplitude information from the bands
  if length(indx) == 1
    
    f = b{indx}.frequency;
    if ~any(strcmpi(b{indx}.magfcn, {'wstop', 'wpass'}))
      a = b{indx}.amplitude;
    end
  else
    
    b = [b{indx}];
    f = [b.frequency];
    f = [min(f(:)) max(f(:))];
    a = [b.amplitude];
    a = a(:);
  end
  
  % Tweak the amplitude information depending on the type of band that we are
  % dealing with.  This will move the zoom out a little for a better view.
  switch band
    case {'pass' 'passband'}
      
      a = max(a)*1.20;
      
      switch lower(mi.magunits)
        case 'db'
          a = [-a a]/2;
          
        case {'linear', 'squared'}
          a = [1-a 1+a];
      end
    case 'cpass'
      a = max(a)*1.20;
      
      switch lower(mi.magunits)
        case 'db'
          a = [-a a/10];
          
        case {'linear', 'squared'}
          a = [1-a 1+a];
      end
      
      % For the weights we need to get the data itself to get the amplitude.
    case 'wpass'
      [x,y] = getanalysisdata(this);
      indx = find(x{1} > f(1) & x{1} < f(2));
      a = [min(y{1}(indx))*.9 max(y{1}(indx))*1.1];
    case 'wstop'
      [x,y] = getanalysisdata(this);
      indx = find(x{1} > f(1) & x{1} < f(2));
      a = [0 max(y{1}(indx))]*1.2; %#ok
    case {'stop' 'stopband'}
      
      [~,y] = getanalysisdata(this);
      
      switch lower(mi.magunits)
        case 'db'
          a = [min(y{1}) -min(a)*.8];
        case {'linear', 'squared'}
          a = [0 min(a)+.1];
      end
  end
  
  % Zoom the frequency out 5%
  f(1) = f(1)-(f(2)-f(1))*.05;
  f(2) = f(2)+(f(2)-f(1))*.05;
  
  % Make sure that the frequencies stay within the [0, pi) range.
  if f(1) < 0, f(1) = 0; end
  if f(2) > mi.fs/2, f(2) = mi.fs/2; end
  
  x = f*fs/mi.fs;
  y = a;
  
end

lclzoom(this, x, y);

end
