classdef winviewer < siggui.sigguiMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.winviewer class
  %   siggui.winviewer extends siggui.siggui.
  %
  %    siggui.winviewer properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Timedomain - Property is of type 'on/off'
  %       Legend - Property is of type 'on/off'
  %       Freqdomain - Property is of type 'on/off'
  %       Names - Property is of type 'mxArray'
  %       FreqDisplayMode - Property is of type 'string'
  %       TimeDisplayMode - Property is of type 'string'
  %       ParameterDlg - Property is of type 'siggui.siggui' (read only)
  %       Parameters - Property is of type 'sigdatatypes.parameter vector' (read only)
  %
  %    siggui.winviewer methods:
  %       addparameter - Add a parameter to winviewer
  %       boldcurrentwin - Bold the current window
  %       callbacks - Callbacks for contextmenu of the window viewer component
  %       copyaxes -   Copy the axes.
  %       copyfigure -   Copy the axes to a figure and put on the clipboard.
  %       destroy - Delete the winviewer object
  %       display_measurements - Display the measurements
  %       editparameters - Edit the parameters
  %       getfs - Returns the sampling frequency specified in winviewer
  %       getparameter - Get a parameter from the winviewer object
  %       legend_listener - Callback executed by listener to the Legend property.
  %       measure_currentwin - Measure the currentwindow
  %       newcurrentwinindex_eventcb - NEWCURRETWININDEX_EVENTCB
  %       plot - Plot datas in the Time and Frequency domains.
  %       print -   Print the figure.
  %       printpreview -   Display preview of figure to be printed
  %       spectralwin - Compute the equivalent spectral window
  %       thisrender - Render the window viewer component
  %       timefreq_listener - Callback executed by listener to the Timedomain/Freqdomain properties.
  %       update_viewer - Callback executed by listener to the Fs, Frequnits,
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %FREQDOMAIN Property is of type 'on/off'
    Freqdomain = 'on'
    %NAMES Property is of type 'mxArray'
    Names = [];
    %FREQDISPLAYMODE Property is of type 'string'
    FreqDisplayMode = '';
    %TIMEDISPLAYMODE Property is of type 'string'
    TimeDisplayMode = '';
  end
  
  properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
    %PARAMETERDLG Property is of type 'siggui.siggui' (read only)
    ParameterDlg = [];
    %PARAMETERS Property is of type 'sigdatatypes.parameter vector' (read only)
    Parameters = [];
  end
  
  properties (SetObservable, GetObservable)
    %TIMEDOMAIN Property is of type 'on/off'
    Timedomain = 'on'
    %LEGEND Property is of type 'on/off'
    Legend = 'off'
  end
  
  
  methods  % constructor block
    function hView = winviewer(hPrm)
      %WINVIEWER Constructor for the winviewer object.
      
      %   Author(s): V.Pellissier
      
      % Install analysis parameters
      if nargin < 1, hPrm = []; end
      
      for indx = 1:length(hPrm)
        addparameter(hView, hPrm(indx), true);
      end
      
      installanalysisparameters(hView);
      
      % Set up the default
      hView.Version = 1;
      
    end  % winviewer
    

    function set.Timedomain(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Timedomain');
      obj.Timedomain = value;
    end
    
    function set.Legend(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Legend');
      obj.Legend = value;
    end
    
    function set.Freqdomain(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','Freqdomain');
      obj.Freqdomain = value;
    end
    
    function set.Names(obj,value)
      obj.Names = value;
    end
    
    function value = get.FreqDisplayMode(obj)
      value = getfreqmode(obj,obj.FreqDisplayMode);
    end
    function set.FreqDisplayMode(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','FreqDisplayMode')
      obj.FreqDisplayMode = setfreqmode(obj,value);
    end
    
    function value = get.TimeDisplayMode(obj)
      value = gettimemode(obj,obj.TimeDisplayMode);
    end
    function set.TimeDisplayMode(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','TimeDisplayMode')
      obj.TimeDisplayMode = settimemode(obj,value);
    end
    
    function set.ParameterDlg(obj,value)
      % DataType = 'siggui.siggui'
      validateattributes(value,{'siggui.sigguiMCOS'}, {'scalar'},'','ParameterDlg')
      obj.ParameterDlg = value;
    end
    
    function set.Parameters(obj,value)
      % DataType = 'sigdatatypes.parameter vector'
      validateattributes(value,{'sigdatatypes.parameter'}, {'vector'},'','Parameters')
      obj.Parameters = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    
    function addparameter(hView, hPrm, dontoverwrite)
      %ADDPARAMETER Add a parameter to winviewer
      %   ADDPARAMETER(hView, hPRM) Add a parameter object (hPRM) to winviewer (hView).
      %   These parameters can then be used across multiple analyses.
      %
      %   See also GETPARAMETER.
      
      %   Author(s): V. Pellissier
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      hPrms = hView.Parameters;
      
      if isempty(hPrms)
        hPrms = hPrm;
      elseif ~isempty(find(hPrms, 'tag', hPrm.tag))
        warning(message('signal:siggui:winviewer:addparameter:GUIWarn'));
        return;
      else
        hPrms(end+1) = hPrm;
      end
      
      if nargin < 3
        usedefault(hPrms, 'winviewer');
      end
      
      hView.Parameters = hPrms;
      
    end
    
    function boldcurrentwin(hView, index)
      %BOLDCURRENTWIN Bold the current window
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      if ~isrendered(hView)
        return
      end
      
      % Get the line handles
      hndls = get(hView, 'Handles');
      haxtd = hndls.axes.td;
      haxfd = hndls.axes.fd;
      htline = findobj(haxtd, 'Tag' , 'tline');
      hfline = findobj(haxfd, 'Tag' , 'fline');
      
      if index > length(htline)
        error(message('signal:siggui:winviewer:boldcurrentwin:IdxOutOfBound'));
      end
      
      % Unbold all
      set(htline, 'LineWidth', 1);
      set(hfline, 'LineWidth', 1);
      
      if ~isempty(index)
        
        % Bold the current window
        if index>0 & length(htline) > 1
          set(htline(index), 'LineWidth', 2);
          set(hfline(index), 'LineWidth', 2);
        end
      end
      
    end
    
    function cbs = callbacks(hView)
      %CALLBACKS Callbacks for contextmenu of the window viewer component
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2011 The MathWorks, Inc.
      
      % This can be a private method
      
      cbs.set_timedomain   = {@timedomain_cbs, hView};
      cbs.set_freqdomain   = {@freqdomain_cbs, hView};
      cbs.set_frespunits   = {@frespunits_cbs, hView};
      cbs.analysisparam    = {@analysisparam_cbs, hView};
      cbs.legend_on        = {@legend_oncbs, hView};
      cbs.legend_off       = {@legend_offcbs, hView};
      cbs.legend           = {@legend_cbs, hView};
      
    end
    
    function hFig = copyaxes(this, varargin)
      %COPYAXES   Copy the axes.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      
      hAxes = sigutils.copyAxes(this.Parent, ...
        @(hOld, hNew) lclCopyAxes(this, hNew), varargin{:});
      
      if ~isempty(hAxes)
        hFig = ancestor(hAxes(1), 'figure');
      else
        hFig = [];
      end
      
    end
    
    function copyfigure(this)
      %COPYFIGURE   Copy the axes to a figure and put on the clipboard.
      
      %   Author(s): J. Schickler
      %   Copyright 2005 The MathWorks, Inc.
      
      hFig = copyaxes(this);
      
      editmenufcn(hFig, 'EditCopyFigure');
      
      close(hFig);
      
    end
    
    function destroy(hView)
      %DESTROY Delete the winviewer object
      
      %   Author(s): V. Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Destroy the parameterdlg if needed
      paramdlg = get(hView, 'ParameterDlg');
      if ~isempty(paramdlg)
        destroy(paramdlg);
      end
      
      % R13
      % super::destroy(hView);
      % hBListeners = get(hView,'BaseListeners');
      %
      % % Check for cell arrays to allow for vector inputs
      % if iscell(hBListeners),
      %     hBListeners = [hBListeners{:}];
      % end
      %
      % delete(hBListeners);
      delete(hView);
      
    end
    
    function display_measurements(hView, FLoss, RSAttenuation, MLWidth)
      %DISPLAY_MEASUREMENTS Display the measurements
      
      %   Copyright 1988-2014 The MathWorks, Inc.
      
      if ~isrendered(hView)
        return
      end
      
      hndls = get(hView, 'Handles');
      
      if isempty(FLoss) || isnan(FLoss)
        FLoss = '- -';
      else
        FLoss = [num2str(FLoss) ' %'];
      end
      
      if isempty(RSAttenuation) || isnan(RSAttenuation)
        RSAttenuation = '- -';
      else
        RSAttenuation = [num2str(RSAttenuation) ' dB'];
      end
      
      % Display the results
      set(hndls.text(1), 'String', ...
        sprintf([getString(message('signal:sigtools:siggui:LeakageFactor')) ': %s'], FLoss));
      
      set(hndls.text(2), 'String', ...
        sprintf([getString(message('signal:sigtools:siggui:RelativeSidelobeAttenuationDB')) ': %s'], RSAttenuation));
      
      hPrm = getparameter(hView, 'freqmode');
      if strcmpi(hPrm.Value, 'Hz') && ~isempty(MLWidth) && ~isnan(MLWidth)
        [MLWidth,eu] = convert2engstrs(MLWidth);
        set(hndls.text(3), 'String', ...
          sprintf([getString(message('signal:sigtools:siggui:MainlobeWidth3dB')) ': %s %sHz'], MLWidth, eu));
      else
        if isempty(MLWidth) || isnan(MLWidth)
          set(hndls.text(3), 'String', sprintf([getString(message('signal:sigtools:siggui:MainlobeWidth3dB')) ': %s'], '- -'));
        else
          set(hndls.text(3), 'String', ...
            sprintf([getString(message('signal:sigtools:siggui:MainlobeWidth3dB')) ': %s'], num2str(MLWidth,'%0.5g')));
        end
      end
      if (isunix)
        set(hndls.text,'FontSize',8);
      end
      
    end
    
    function editparameters(hView)
      %EDITPARAMETERS Edit the parameters
      
      %   Copyright 1988-2012 The MathWorks, Inc.
      
      hdlg = get(hView, 'ParameterDlg');
      
      % If there is no parameter dialog, create one.
      if isempty(hdlg)
        hdlg = siggui.parameterdlgMCOS(hView.Parameters, ...
          getString(message('signal:sigtools:siggui:AnalysisParametersTitle')), ...
          getString(message('signal:sigtools:siggui:MagnitudeResponse')));
        hView.ParameterDlg = hdlg;
        set(hdlg, 'Tool', 'winviewer');
        set(hdlg, 'HelpLocation', {fullfile(docroot, '/toolbox/signal/', 'signal.map'), ...
          'wintool_analysis_parameters'});
      end
      
      value = get(getparameter(hView, 'freqmode'), 'Value');
      if strcmpi(value, 'normalized')
        % Disable Sampling
        disableparameter(hdlg, 'sampfreq');
      else
        % Enable Sampling
        enableparameter(hdlg, 'sampfreq');
      end
      
      if ~isrendered(hdlg)
        render(hdlg);
        centerdlgonfig(hdlg, hView);
      end
      
      % If there is a parameter dialog, make it visible and bring it to the front.
      set(hdlg, 'Visible', 'on');
      figure(hdlg.FigureHandle);
      
    end
    
    function [fs, xunits, multiplier] = getfs(hView, varargin)
      %GETFS Returns the sampling frequency specified in winviewer
      %   [FS, XUNITS, M] = GETFS(hView, FREQTIME) Returns the sampling frequency FS specified
      %   in the winviewer associated with hView.  XUNITS is a string which contains the
      %   units of the sampling frequency, i.e. 'Hz', 'kHz', 'MHz'.  If winviewer
      %   is in 'Normalized' display mode, 'rad/sample' will be returned in XUNITS
      %   and FS will be empty.  M is the multiplier used to convert the Fs from the
      %   units in XUNITS to Hz.  FREQTIME is either 'freq' or 'time', depending on which
      %   you want the function to return.  If 'time' is specified, the sampling time will
      %   be returned.  'freq' is the default FREQTIME.
      %
      %   GETFS(hView, LINEARFLAG) Returns the sampling frequency specified in winviewer
      %   ignoring the 'FreqDisplayMode' property if LINEARFLAG is 1.
      
      %   Author(s): V. Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(1,3);
      
      [freqtime, linearflag] = parse_inputs(varargin{:});
      
      fs = get(getparameter(hView, 'sampfreq'), 'Value');
      
      if strcmpi(freqtime, 'freq')
        if ~linearflag, linearflag = ~strcmpi(hView.FreqDisplayMode, 'Normalized'); end
        [fs, xunits, multiplier] = lclgetfs(fs, linearflag);
      else
        if ~linearflag, linearflag = ~strcmpi(hView.FreqDisplayMode, 'Normalized'); end
        [fs, xunits, multiplier] = lclgetts(fs, linearflag);
      end
      
    end
    
    
    function hPrm = getparameter(hView, tag)
      %GETPARAMETER Get a parameter from the winviewer object
      %   GETPARAMETER(hView, TAG) Returns the parameter whose tag is TAG from the winviewer object.
      %   If the parameter is not available from the winviewer object an empty matrix will be returned.
      
      %   Author(s): V. Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      hPrms = get(hView, 'Parameters');
      
      hPrm = [];
      if ~isempty(hPrms)
        hPrm = find(hPrms, 'Tag', tag);
      end
      
      
    end
    
    function legend_listener(hView, eventData)
      %LEGEND_LISTENER Callback executed by listener to the Legend property.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      window_names = get(hView, 'Names');
      
      % Old legend
      hFig = get(hView, 'FigureHandle');
      holdlegend = findall(hFig, 'Tag', 'legend');
      
      % Get the handle to the freq axes and the legend menus
      hndls = get(hView, 'Handles');
      legendmenus = findobj([hndls.contextmenu hndls.menu], 'Tag', 'legendmenu');
      haxfd = hndls.axes.fd;
      
      
      legendState = get(hView, 'Legend');
      switch legendState
        case 'on'
          
          if isempty(window_names)
            % If there's no data is the Viewer
            delete(holdlegend);
            
            % Disable legend menus and toggle
            set([hndls.legendbtn; legendmenus], 'Enable', 'off');
            
          else
            % Save the position of the old legend
            legpos = get(holdlegend, 'Position');
            
            % Create a new legend
            hlegend = legend(haxfd, window_names);
            
            % Restore the position of the top-left corner of the legend
            newpos = get(hlegend, 'Position');
            if ~isempty(legpos)
              topleft = [legpos(1) legpos(2)+legpos(4)];
              newpos(1) = topleft(1);
              newpos(2) = topleft(2)-newpos(4);
              set(hlegend, 'Position', newpos);
            end
            
            % Enable legend menus and toggle
            set([hndls.legendbtn; legendmenus], 'Enable', 'on');
            
          end
          
        case 'off'
          
          if ~isempty(holdlegend)
            legend(haxfd, 'hide');
          end
          
      end
      
      % Check/Uncheck the menus
      set(legendmenus, 'Checked', legendState);
      
      % Set the state of the toogle button
      set(hndls.legendbtn, 'State' , legendState);
      
      % If there's no axes visible
      td = get(hView, 'Timedomain');
      fd = get(hView, 'Freqdomain');
      if strcmpi(td, 'off') & strcmpi(fd, 'off')
        % Hide the legend
        legend(haxfd, 'hide');
        % Disable legend menus and toggle
        set([hndls.legendbtn; legendmenus], 'Enable', 'off');
      else
        % Enable legend menus and toggle
        set([hndls.legendbtn; legendmenus], 'Enable', 'on');
      end
      
      % Disable the ButtonDownFcn so that the legend is not editable
      hleg = findall(hFig, 'Tag', 'legend');
      hchild = get(hleg, 'Children');
      set(hchild, 'ButtonDownFcn', '');
      
      
    end
    
    function [FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, index)
      %MEASURE_CURRENTWIN Measure the currentwindow
      
      %   Copyright 1988-2014 The MathWorks, Inc.
      
      if ~isrendered(hView)
        FLoss = [];
        RSAttenuation  = [];
        MLWidth = [];
        return
      end
      
      hndls = get(hView, 'Handles');
      
      if ~isempty(index)
        % Get the data
        haxtd = hndls.axes.td;
        htline = findobj(haxtd, 'Tag' , 'tline');
        t = get(htline(index), 'XData'); %#ok<NASGU>
        data = get(htline(index), 'YData');
        [f, fresp] = computefresp(hView, data(:));
        
        % Do the measurement
        % Loss Factor (%)
        FLoss = LossFactor(fresp);
        % Main Lobe Width (at -3dB)
        MLWidth = bandwidth(f, fresp);
        % Relative Side Lobe Attenuation (dB)
        RSAttenuation = attenuation(fresp);
      else
        % If there's no data in the viewer
        MLWidth = [];
        RSAttenuation = [];
        FLoss = [];
      end
      
    end
    
    
    function newcurrentwinindex_eventcb(hView, eventData)
      %NEWCURRETWININDEX_EVENTCB
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Callback executed by the listener to an event thrown by another component.
      % The Data property stores an index of the selection
      index = eventData.Data;
      
      % Bold the current window
      boldcurrentwin(hView, index);
      
      % Measure the current window
      [FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, index);
      
      % Display the measurements
      display_measurements(hView, FLoss, RSAttenuation, MLWidth);
      
    end
    
    function plot(this, t, data, f, fresp)
      %PLOT Plot datas in the Time and Frequency domains.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2005 The MathWorks, Inc.
      
      if ~isrendered(this)
        return;
      end
      
      hFig  = get(this, 'FigureHandle');
      hndls = get(this, 'Handles');
      haxtd = hndls.axes.td;
      haxfd = hndls.axes.fd;
      
      % Clean the axes
      clean_axes(haxtd, haxfd, hndls);
      
      if ~isempty(data)
        % xlabels
        [xtstr, xfstr, tmultiplier, fmultiplier] = define_xlabel(this);
        t = t*tmultiplier;
        f = f*fmultiplier;
        
        % ylabels
        [ytstr, yfstr] = define_ylabel(this);
        
        % Turn HandleVisibility 'on' (because the 'line' function use gca)
        hvisibility = get(hFig, 'HandleVisibility');
        set(hFig, 'HandleVisibility', 'on');
        
        % Time domain
        set(hFig, 'CurrentAxes', haxtd);
        htline = line(t, data, 'Tag', 'tline', 'Parent', haxtd);
        set(hndls.axes.tdxlabel, 'String', xtstr);
        set(hndls.axes.tdylabel, 'String', ytstr);
        
        % Freq domain
        set(hFig, 'CurrentAxes', haxfd);
        hfline = line(f, fresp, 'Tag', 'fline', 'Parent', haxfd);
        set(hndls.axes.fdxlabel, 'String', xfstr);
        set(hndls.axes.fdylabel, 'String', yfstr);
        
        % Restore HandleVisibility
        set(hFig, 'HandleVisibility', hvisibility);
        
        % Axes limits
        if strncmpi(siggetappdata(hFig, 'siggui', 'ZoomState'), 'zoom', 4)
          % Restore the zoom state of the figure
          setzoomstate(hFig);
        end
        if length(t) == 1 || isequal(diff(t), 0)
          t = [t(1)-1 t(1)+1];
        end
        set(haxtd, 'XLim', [t(1) t(end)], 'YLim', [0 1.1]);
        % This is for user-defined windows
        if max(max(data))>1 | min(min(data))<0
          set(haxtd, 'YLimMode', 'auto');
        end
        set(haxfd, 'XLim', [f(1) f(end)], 'YLimMode', 'auto');
        
        % X Scale
        set(haxfd, 'XScale', get(getparameter(this, 'freqscale'), 'Value'));
        
        % Install the Data Markers
        set([htline hfline], 'ButtonDownFcn', @setdatamarkers);
        
        % Refresh legend
        this.Legend = this.Legend;
        
        % Enable state of the "Frequency Specifications"
        enabState = 'on';
        
        figure(hFig);
        
      else
        
        % Enable state of the "Frequency Specifications"
        enabState = 'off';
        
      end
      
      % Enable/Disable the "Frequency Specifications" item of
      % the contextmenu and the "view" menu
      hmenus = findobj([hndls.contextmenu hndls.menu], 'Tag', 'frequnits');
      set(hmenus, 'Enable', enabState);
      
      % Enable/Disable the dialog box
      analysisdialog = get(this, 'ParameterDlg');
      if ~isempty(analysisdialog) && isrendered(analysisdialog)
        set(analysisdialog, 'Enable', enabState);
        a = findobj(analysisdialog.Parent,'Tag','sampfreq_editbox');
        b = findobj(analysisdialog.Parent,'Tag','freqmode_specpopup');
        if strcmpi(b.String{b.Value},'Normalized')
          set(a, 'BackgroundColor', get(0,'DefaultUicontrolBackgroundColor'), 'Enable', 'off');
        end       
      end
      
      % Fire timefreq_listener
      this.Timedomain = this.Timedomain;
      
    end
    
    function print(this, varargin)
      %PRINT   Print the figure.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      hFig_print = copyaxes(this);
      
      if isempty(hFig_print)
        warning(message('signal:siggui:winviewer:print:GUIWarn'));
        return;
      end
      
      if nargin > 1
        set(hFig_print, varargin{:});
      end
      
      hFig = get(this, 'FigureHandle');
      
      setptr(hFig,'watch');        % Set mouse cursor to watch.
      printdlg(hFig_print);
      setptr(hFig,'arrow');        % Reset mouse pointer.
      close(hFig_print);
      
    end
    
    function printpreview(this, varargin)
      %PRINTPREVIEW   Display preview of figure to be printed
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2014 The MathWorks, Inc.
      
      hFig = copyaxes(this);
      
      if isempty(hFig)
        warning(message('signal:siggui:winviewer:printpreview:GUIWarn'));
        return;
      end
      
      if nargin > 1
        set(hFig, varargin{:});
      end
      
      printpreview(hFig)
      
      if ishandle(hFig)
        delete(hFig);
      end
      
    end
    
    function [t, f, fresp] = spectralwin(this, data)
      %SPECTRALWIN Compute the equivalent spectral window
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2011 The MathWorks, Inc.
      
      if isempty(data)
        t = [];
        f =[];
        fresp = [];
        return;
      end
      
      [N,M] = size(data);
      Nfft = getparameter(this, 'nfft');
      Nfft = Nfft.Value;
      
      % Force the Nfft to be a power of two greater or equal to the number of
      % elements, unless the user specified the NFFT.
      if Nfft < N && Nfft == 512
        Nfft = 2.^nextpow2(numel(data));
      end
      
      % Remove  NaN
      data(isnan(data)) = 0;
      
      % Normalization
      % data = data ./ (ones(N,1)*sum(data));
      
      % Range
      freqrange = getparameter(this, 'unitcircle');
      index = find(strcmpi(freqrange.Value, freqrange.ValidValues));
      if index == 1
        Nfft = 2*Nfft;
      end
      
      % Padding
      P = round((Nfft-N)/2);
      datapad = data;
      if P>0
        datapad = [zeros(P,M); data; zeros(Nfft-N-P, M)];
      end
      
      for col=1:M
        fresp(:,col) = freqz(datapad(:,col),1,Nfft,'whole');
      end
      f = (0:Nfft-1)/Nfft*2;
      
      
      if rem(Nfft,2)
        % Nfft odd
        L=(Nfft-1)/2;
      else
        % Nfft even
        L = Nfft/2;
      end
      
      if strcmpi(get(getparameter(this, 'normmag'), 'Value'), 'on')
        for indx = 1:size(fresp, 2)
          fresp(:, indx) = fresp(:, indx)/max(fresp(:, indx));
        end
      end
      
      % Y Units
      p  = getparameter(this, 'magnitude');
      possibleUnits = p.ValidValues;
      FrespUnits = p.Value;
      if strcmpi(FrespUnits, possibleUnits{1})
        % Magnitude
        fresp = abs(fresp);
      elseif strcmpi(FrespUnits, possibleUnits{2})
        % Magnitude(dB)
        fresp = convert2db(fresp);
      elseif strcmpi(FrespUnits, possibleUnits{3})
        % Magnitude Squared
        fresp = abs(convert2sq(fresp));
      elseif  strcmpi(FrespUnits, possibleUnits{4})
        fresp = [];
        % Zero-phase
        for i=1:M
          w = warning('off'); %#ok<*WNOFF>
          if index == 1 || index == 2
            fresp(:,i) = zerophase(data(:,i), 1, Nfft, 'whole'); %#ok<*AGROW>
          else
            ww = linspace(-pi, pi, Nfft);
            fresp(:,i) = zerophase(data(:,i), 1, ww(:), 'whole');
          end
          warning(w);
        end
        
        % Reapply the normalization.
        if strcmpi(get(getparameter(this, 'normmag'), 'Value'), 'on')
          for indx = 1:size(fresp, 2)
            fresp(:, indx) = fresp(:, indx)/max(fresp(:, indx));
          end
        end
      end
      
      if index == 1
        % Keep only the positive frequencies
        f = (0:L-1)/Nfft*2;
        fresp = fresp(1:L, :);
      elseif index == 3
        fresp = fftshift(fresp,1);
        f = f - f(L+1);
      end
      
      % Frequency units
      fs = getparameter(this, 'sampfreq');
      t = 1:size(data,1);
      if ~isempty(fs.Value)
        t = t/fs.Value;
        f = f*fs.Value/2;
        freqmode = getparameter(this, 'freqmode');
        if strcmpi(freqmode.Value, 'Normalized')
          t = t * fs.Value;
          f = 2*f/fs.Value;
        end
      end
      
    end
    
    function thisrender(this, hFig, pos, index)
      %THISRENDER Render the window viewer component
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2010 The MathWorks, Inc.
      
      if nargin < 4, index = 2; end
      if nargin < 3, pos   = []; end
      if nargin < 2, hFig  = gcf; end
      
      % In matlab online, we replaced the default menubar and toolbar
      % with a toolstrip. Thus the MenuBar property of the figure is set to
      % none. But since winviewer needs the default menubar and toolbar, it
      % has to set the menubar back to figure in order to get the default
      % menubar and toolbar. 
      if strcmp(hFig.MenuBarMode,'auto')
          hFig.MenuBar = 'figure';
          hFig.MenuBarMode = 'auto';
      end
      
      sz = gui_sizes(this);
      if isempty(pos)
        pos = [10 10 659 320]*sz.pixf;
      end
      
      hPanel = uipanel('Parent', hFig, ...
        'Units', 'Pixels', ...
        'Position', pos, ...
        'Visible', 'Off', ...
        'Title', getString(message('signal:sigtools:siggui:WindowViewer')));
      
      hLayout = siglayout.gridbaglayout(hPanel);
      
      set(hLayout, ...
        'HorizontalGap', 5, ...
        'VerticalGap', 5, ...
        'VerticalWeights', [1 0]);
      
      hc = uicontainer('Parent', hPanel);
      
      hLayout.add(hc, 1, 1:3, ...
        'Fill', 'Both', ...
        'TopInset', 10*sz.pixf);
      
      % Time Domain
      h.axes.td = axes('Parent', hc, ...
        'Box', 'on', ...
        'Color', 'White', ...
        'FontSize', sz.fontsize, ...
        'Tag', 'timedomain', ...
        'XGrid', 'on', ...
        'YGrid', 'on');
      
      % Frequency domain
      h.axes.fd = axes('Parent', hc, ...
        'Box', 'on', ...
        'Color', 'White', ...
        'FontSize', sz.fontsize, ...
        'Tag', 'freqdomain', ...
        'XGrid', 'on', ...
        'YGrid', 'on');
      
      % XLabels
      h.axes.tdxlabel = get(h.axes.td,'XLabel');
      h.axes.fdxlabel = get(h.axes.fd,'XLabel');
      
      % YLabels
      h.axes.tdylabel = get(h.axes.td,'YLabel');
      h.axes.fdylabel = get(h.axes.fd,'YLabel');
      % Need to initialize YLabel to create a contextmenu using addunitsmenu
      p  = getparameter(this, 'magnitude');
      set(h.axes.fdylabel, 'String', getTranslatedString('signal:sigtools:siggui',p.Value));
      % Titles
      h.axes.tdtitle = get(h.axes.td, 'Title');
      set(h.axes.tdtitle, 'String', getString(message('signal:sigtools:siggui:TimeDomain')));
      h.axes.fdtitle = get(h.axes.fd, 'Title');
      set(h.axes.fdtitle, 'String', getString(message('signal:sigtools:siggui:FrequencyDomain')));
      
      % Set graphical properties of xlabels and titles
      set([h.axes.tdxlabel ...
        h.axes.fdxlabel ...
        h.axes.tdylabel ...
        h.axes.fdylabel ...
        h.axes.tdtitle ...
        h.axes.fdtitle], ...
        'FontSize', sz.fontsize, 'Color', 'Black')
      
      % Define the strings
      Str = {[getString(message('signal:sigtools:siggui:LeakageFactor')) ': '], ...
        [getString(message('signal:sigtools:siggui:RelativeSidelobeAttenuationDB')) ': '], ...
        [getString(message('signal:sigtools:siggui:MainlobeWidth3dB')) ': ']};
      
      for indx = 1:3
        h.text(indx) = uicontrol(hPanel, ...
          'Style',               'text', ...
          'ForegroundColor',     [0.4  0.4 0.4], ...
          'Enable',              'on', ...
          'HorizontalAlignment', 'center', ...
          'String',              Str{indx}, ...
          'Tag',                 'measurements');
        
        hLayout.add(h.text(indx), 2, indx, ...
          'Fill', 'Horizontal', ...
          'MinimumHeight', sz.uh);
      end
      
      % Add the menus
      hMag = getparameter(this, 'magnitude');
      hcontextmenu = contextmenu(hMag, h.axes.fdylabel);
      h.frespunits = get(hcontextmenu, 'Children');
      
      [hfdcontextmenu, hfdmenus] = addfreqcsmenu(this, h.axes.fdxlabel);
      [htdcontextmenu, htdmenus] = addtimecsmenu(this, h.axes.tdxlabel);
      
      cb = callbacks(this);
      hfreqspecs = uimenu(hfdcontextmenu, ...
        'Label', [getString(message('signal:sigtools:siggui:AnalysisParams')) '...'], ...
        'Callback', cb.analysisparam, ...
        'Separator', 'on');
      set(h.axes.fdxlabel, 'UIContextMenu', hfdcontextmenu);
      
      hfreqspecs = uimenu(htdcontextmenu, ...
        'Label', [getString(message('signal:sigtools:siggui:AnalysisParams')) '...'], ...
        'Callback', cb.analysisparam, ...
        'Separator', 'on');
      set(h.axes.tdxlabel, 'UIContextMenu', htdcontextmenu);
      
      % Add a listener on the Frequency Display Parameter to control
      % the Range and Sampling parameters
      freqmode = getparameter(this, 'freqmode');
      l = handle.listener(freqmode, 'UserModified', @freqmodemodified_eventcb);
      l(2) = handle.listener(freqmode, freqmode.findprop('Value'), ...
        'PropertyPostSet', @freqmodemodified_eventcb);
      freqmodemodified_eventcb(this, [])
      
      % Add a listener on the Frequency Display Parameter to update
      % the checked status of the context menus
      freqmode = getparameter(this, 'freqmode');
      l(3) = handle.listener(freqmode, freqmode.findprop('Value'), ...
        'PropertyPostSet', @freqmodenewvalue_eventcb);
      
      set(l, 'CallbackTarget', this);
      setappdata(hFig, 'freqmode_listener', l);
      
      
      % Add a listener on the Sampling Frequency Parameter to update
      % Fs value in the context menu item
      sampfreq = getparameter(this, 'sampfreq');
      l = handle.listener(sampfreq, sampfreq.findprop('Value'), ...
        'PropertyPostSet', @sampfreqmodified_eventcb);
      set(l, 'CallbackTarget', this);
      setappdata(hFig, 'sampfreq_listener', l);
      
      h.freqspecs = [hfdmenus htdmenus];
      
      % Get the View menu parameters.
      [strs,cbs,tags,sep,accel] = getviewparams(this);
      
      % Render the context menu items
      thiscontextmenu = uicontextmenu('Parent', hFig);
      N = length(strs);
      for i=1:N
        h.contextmenu(i) = uimenu(thiscontextmenu, ...
          'Label', strs{i}, ...
          'Callback', cbs{i}, ...
          'Tag', tags{i}, ...
          'Separator', sep{i}, ...
          'Accelerator', accel{i});
      end
      
      % Add context-sensitve help
      tag = ['WT?wintool_winviewer_frame'];
      toolname = 'WinTool';
      h.contextmenu(N+1) = uimenu(thiscontextmenu, ...
        'Label', getString(message('signal:sigtools:siggui:WhatsThis')),...
        'Callback', {@cshelpengine,toolname,tag}, ...
        'Separator', 'on', ...
        'Tag', tag);
      
      set([hc hPanel], 'UIContextMenu', thiscontextmenu);
      
      % Get the View menu parameters.
      [strs,cbs,tags,sep,accel] = getviewparams(this);
      % Add a 'View' root
      strs  = [{getString(message('signal:sigtools:siggui:Viewamp'))} strs];
      cbs   = [{''} cbs];
      tags  = [{'view'} tags];
      sep   = [{'Off'} sep];
      accel = [{'I'} accel];
      
      % Render the View menu items
      h.menu = addmenu(hFig,index,strs,cbs,tags,sep,accel);
      
      % Add the legend toggle button
      hparent = findall(ancestor(hFig, 'figure'),'Type','uitoolbar');
      if isempty(hparent)
        hparent = uitoolbar('Parent', ancestor(hFig, 'figure'));
      end
      
      % Structure of all local callback functions
      cbs = callbacks(this);
      
      h.legendbtn = render_legendonoffbtn(hparent, '', cbs.legend_on, cbs.legend_off);
      
      % Create the listeners
      listener = cell(3,1);
      listener{1}    = event.proplistener(this, [this.findprop('Timedomain') ...
        this.findprop('Freqdomain')], 'PostSet', @(s,e)timefreq_listener(this));
      listener{2}    = event.proplistener(this, this.findprop('Legend'),'PostSet',@(s,e)legend_listener(this));
      hPrms = get(this, 'Parameters');
      hPrms = hPrms(:);
      listener{3} = handle.listener(hPrms, 'NewValue', @update_viewer);
      
      % Set this to be the input argument to these listeners
      set(listener{3},'CallbackTarget', this);
      
      % Save the listeners
      this.WhenRenderedListeners =  listener;
      this.Handles = h;
      this.FigureHandle = hFig;
      this.Container = hPanel;
      
      % Add context-sensitive help
      cshelpcontextmenu(hFig, h.text, ...
        'wintool_winviewer_frame', 'WinTool');
      cshelpcontextmenu(hFig, [h.axes.td, h.axes.fd], ...
        'wintool_winviewer_frame', 'WinTool');
      
      % Fire timefreq_listener
      timefreq_listener(this);
      
    end
    
    
    function timefreq_listener(hView, eventData)
      %TIMEFREQ_LISTENER Callback executed by listener to the Timedomain/Freqdomain properties.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2014 The MathWorks, Inc.
      
      % Resize axes, set visibility
      stretch_axes(hView);
      
      % Update the 'View' menu and the context menu
      update_viewmenus(hView);
    end
    
    
    function update_viewer(hView, eventData)
      %UPDATE_VIEWER Callback executed by listener to the Fs, Frequnits,
      %Spectralwintype and Spectralscale properties.
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Get the data
      [data, index] = get_data(hView);
      
      % Compute the spectral window
      [t, f, fresp] = spectralwin(hView, data);
      
      % Plot
      plot(hView, t, data, f, fresp);
      
      % Bold the current window
      boldcurrentwin(hView, index);
      
      % Measure the current window
      [FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, index);
      
      % Display the measurements
      display_measurements(hView, FLoss, RSAttenuation, MLWidth);
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function newselection_eventcb(hView, eventData)
      %NEWSELECTION_EVENTCB
      
      %   Author(s): V.Pellissier
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Callback executed by the listener to an event thrown by another component.
      % The Data property stores a vector of handles of winspecs objects
      s = eventData.Data;
      selectedwin = s.selectedwindows;
      
      % Get the data of the selected windows
      data = get_selection_data(hView, selectedwin);
      
      % Compute the spectral window
      [t, f, fresp] = spectralwin(hView, data);
      
      % Plot
      plot(hView, t, data, f, fresp);
      
      % Bold the current window
      currentwinindex = [];
      if ~isempty(s.currentindex)
        currentwinindex = find(s.currentindex == s.selection);
      end
      boldcurrentwin(hView, currentwinindex);
      
      % Measure the current window
      [FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, currentwinindex);
      
      % Display the measurements
      display_measurements(hView, FLoss, RSAttenuation, MLWidth);
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = setfreqmode(hView, value)

out = value;
hFs = getparameter(hView, 'freqmode');
if ~isempty(hFs), setvalue(hFs, value); end
end  % setfreqmode


% -------------------------------------------------------------------------
function out = getfreqmode(hView, value)

hFs = getparameter(hView, 'freqmode');
out = get(hFs, 'Value');
end  % getfreqmode


% -------------------------------------------------------------------------
function out = settimemode(hView, value)

out = value;
hFs = getparameter(hView, 'freqmode');
if ~isempty(hFs)
  if strcmpi(value, 'Samples')
    setvalue(hFs, 'Normalized');
  else
    setvalue(hFs, 'Hz');
  end
end
end  % settimemode


% -------------------------------------------------------------------------
function out = gettimemode(hView, value)

hFs = getparameter(hView, 'freqmode');
if strcmpi(get(hFs, 'Value'), 'Normalized')
  out = 'Samples';
else
  out = 'Time';
end
end  % gettimemode


% [EOF]
function installanalysisparameters(hView)

% Turn warnings off because ADDPARAMETER may warn if the parameter already
% exists.
w = warning('off');

hNFFT = sigdatatypes.parameter('Number of points', 'nfft', [1 1 inf], 512);
addparameter(hView, hNFFT);

opts = {'[0, pi)', '[0, 2pi)', '[-pi, pi)'};
hUnit = sigdatatypes.parameter('Range', 'unitcircle', opts);
addparameter(hView, hUnit);
setvalidvalues(hUnit, opts);

hMag  = sigdatatypes.parameter('Response', 'magnitude', ...
  {'Magnitude', 'Magnitude (dB)', 'Magnitude squared', 'Zero-phase'}, ...
  'Magnitude (db)');
addparameter(hView, hMag);

addparameter(hView, sigdatatypes.parameter('Frequency Units', ...
  'freqmode', {'Normalized', 'Hz'}));

addparameter(hView, sigdatatypes.parameter('Frequency Scale', ...
  'freqscale', {'Linear', 'Log'}));

addparameter(hView, sigdatatypes.parameter('Sampling Frequency', ...
  'sampfreq', [0 inf], 1));

addparameter(hView, sigdatatypes.parameter('Normalize Magnitude', ...
  'normmag', 'on/off', 'off'));

usedefault(hNFFT, 'winviewer');

warning(w);
end  % installanalysisparameters


%-------------------------------------------------------------------------
function timedomain_cbs(hcbo, eventstruct, hView)
%TIMEDOMAIN_CBS Callback of the 'Time Domain' menu

timedomain = get(hView, 'Timedomain');
if strcmpi(timedomain, 'on')
  set(hView, 'Timedomain', 'off');
else
  set(hView, 'Timedomain', 'on');
end

end


%-------------------------------------------------------------------------
function freqdomain_cbs(hcbo, eventstruct, hView)
%FREQDOMAIN_CBS Callback of the 'Frequency Domain' menu

freqdomain = get(hView, 'Freqdomain');
if strcmpi(freqdomain, 'on')
  set(hView, 'Freqdomain', 'off');
else
  set(hView, 'Freqdomain', 'on');
end

end


%-------------------------------------------------------------------------
function frespunits_cbs(hcbo, eventstruct, hView)
%FRESPUNITS_CBS Callback of the Frequency YLabel contextmenu

frespunits = eventstruct.NewValue;
if ~isempty(frespunits)
  p  = getparameter(hView, 'magnitude');
  allunits = p.ValidValues;
  if ~isempty(strmatch(eventstruct.NewValue, allunits))
    p.Value = eventstruct.NewValue;
  end
end

end


%-------------------------------------------------------------------------
function analysisparam_cbs(hcbo, eventstruct, hView)
%ANALYSISPARAM_CBS Callback of the XLabels contextmenu

editparameters(hView);

end


%-------------------------------------------------------------------------
function legend_oncbs(hcbo, eventstruct, hView)
%LEGEND_ONCBS On-callback of the legend toggle button

set(hView, 'Legend', 'on');
set(hcbo,'TooltipString', getString(message('signal:sigtools:render_legendonoffbtn:TurnLegendOff')));

end


%-------------------------------------------------------------------------
function legend_offcbs(hcbo, eventstruct, hView)
%LEGEND_OFFCBS Off-callback of the legend toggle button

set(hView, 'Legend', 'off');
set(hcbo,'TooltipString', getString(message('signal:sigtools:render_legendonoffbtn:TurnLegendOn')));

end


%-------------------------------------------------------------------------
function legend_cbs(hcbo, eventstruct, hView)
%LEGEND_CBS Callback of the legend menu

legendState = get(hcbo, 'Checked');
possibleStates = {'on','off'};
% Find the other state
index = find(strcmpi(legendState, possibleStates)==0);
set(hView, 'Legend', possibleStates{index});

end


% -------------------------------------------------------------------------
function hax = lclCopyAxes(this, hFigNew)
 
isf = strcmpi(this.Freqdomain, 'On');
ist = strcmpi(this.Timedomain, 'On');

if ~isf && ~ist
  hax = [];
  return;
end

h = get(this, 'Handles');

if ist && isf
  
  hax(1) = copyobj(h.axes.td, hFigNew);
  hax(2) = copyobj(h.axes.fd, hFigNew);
  
  set(hax(1), 'Position', [0.13 0.11 0.33466 0.815]);
  set(hax(2), 'Position', [0.57 0.11 0.33466 0.815]);
  
elseif ist
  
  hax = copyobj(h.axes.td, hFigNew);
  
  set(hax, 'Position', [0.1300 0.1100 0.7750 0.8150]);
else
  
  hax = copyobj(h.axes.fd, hFigNew);
  
  set(hax, 'Position', [0.1300 0.1100 0.7750 0.8150]);
end

hleg = findobj(this.FigureHandle, 'Tag', 'legend');

if ~isempty(hleg) && strcmpi(hleg.Visible,'on')
  
  hlegnew = legend(hax(end),hleg.String);
  
end

end


% -------------------------------------------------------------------
function [fs, xunits, multiplier] = lclgetfs(fs, linearflag)

if linearflag
  [fs, multiplier, u] = engunits(fs);
  xunits = [u 'Hz'];
else
  fs = [];
  xunits = 'rad/sample';
  multiplier = 1;
end

end

% -------------------------------------------------------------------
function [ts, xunits, multiplier] = lclgetts(fs, linearflag)

if linearflag
  [ts, multiplier, xunits] = engunits(1/fs, 'time');
else
  ts = [];
  xunits = 'samples';
  multiplier = 1;
end

end

% -------------------------------------------------------------------
function [freqtime, linearflag] = parse_inputs(varargin)

freqtime   = 'freq';
linearflag = 0;

for indx = 1:length(varargin)
  if ischar(varargin{indx})
    freqtime = varargin{indx};
  elseif isnumeric(varargin{indx})
    linearflag = varargin{indx};
  end
end

end

%---------------------------------------------------------------------
function [f, fresp] = computefresp(hView, data)

M = 1;
N = length(data);
Nfft = getparameter(hView, 'nfft');
Nfft = Nfft.Value;

% Remove  NaN
data(isnan(data)) = 0;

% Normalization
% data = data ./ (ones(N,1)*sum(data));

% Padding
P = round((Nfft-N)/2);
datapad = data;
if P>0
  datapad = [zeros(P,M); data; zeros(Nfft-N-P, M)];
end

% Make sure that there enough points in the frequency domain for reasonnable accuracy of the measurements
Nfft = max(16*2^nextpow2(N),Nfft);
fresp = freqz(datapad,1,Nfft,'whole');
f = (0:Nfft-1)/Nfft*2;

if rem(Nfft,2)
  % Nfft odd
  L=(Nfft-1)/2;
else
  % Nfft even
  L = Nfft/2;
end

% Frequency units
fs = getparameter(hView, 'sampfreq');
if ~isempty(fs.Value)
  f = f*fs.Value/2;
  freqmode = getparameter(hView, 'freqmode');
  if strcmpi(freqmode.Value, 'Normalized')
    f = 2*f/fs.Value;
  end
end

% Keep only the positive frequencies
f = f(1:L);
fresp = fresp(1:L);

end

%--------------------------------------------------------------------
function FLoss = LossFactor(fresp)
%POWERLOSS Compute the loss factor(%) of a frequency response
% We define the loss factor by the ratio of side lobe power over
% total power

% Determine -3dB index
frespdb = convert2db(fresp);
initValue = find((frespdb-frespdb(1))>=-3, 1, 'last' );

% Take derivative of freq response
d = diff(abs(fresp));

% Initialize to NaN in calse the frequency response is strictly positive
FLoss = NaN;

if ~isempty(initValue)
  % Start measuring at the 3dB point to make sure we avoid looking for
  % positive slopes on the window's flat region.
  firstzero = find(d(initValue:end)>0);
  if ~isempty(firstzero)
    firstzero = firstzero(1)+initValue-1;
    FLoss = 1 - (sum(abs(fresp(1:firstzero).^2))/sum(abs(fresp.^2)));
    % Keep 2 digits after the coma
    FLoss = round(1e4*FLoss)/1e2;
  end
end

end

%--------------------------------------------------------------------
function MLWidth = bandwidth(f, fresp)
%BANDWIDTH Measure the bandwidth at -3dB
%   Determine the resolution power

fresp = convert2db(fresp);
% The 3dB are relative to the maximum
MLWidth = 2*f(find((fresp-fresp(1))>=-3, 1, 'last' ));

end

%--------------------------------------------------------------------
function RSAttenuation = attenuation(fresp)
%ATTENUATION Relative side lobe attenuation (dB)
%   Determine the rejection power of the window

fresp = convert2db(fresp);
% Find the peaks in fresp
ind = findpeaks(fresp);
% Peak Amplitudes
fpeakamps = fresp(ind);
% Reject mainlobe peak if present, keep highest peak
RSAttenuation = max(fpeakamps(fpeakamps<fresp(1)))-fresp(1);
% Keep 1 digit after the coma
RSAttenuation = round(10*RSAttenuation)/10;

end

%--------------------------------------------------------------------
function ind = findpeaks(fresp)
% Find the local maximum

deriv = diff(fresp);
% Looking for transition from positive to negative
ind = find(diff(sign(deriv))==-2);
% Add 1 to compensate the diff
ind = ind + 1;
% Keep the 10 first peaks
if length(ind)>=10
  ind = ind(1:10);
end

end

%---------------------------------------------------------------------
function data = get_selection_data(hView, selectedwin)
%GET_DATA

data = [];
names = [];
if ~isempty(selectedwin)
  N = length(selectedwin);
  % Define the maximum length of the selected windows
  for i=1:N
    winlength(i) = length(selectedwin(i).Data);
  end
  M = max(winlength);
  data = NaN*ones(M,N);
  % Get data - each window is store in a column of the data matrix
  % Reverse order (first window of selection stored in the last column)
  % for graphical reason (colororder)
  for i=1:N
    data(1:winlength(i),N-i+1) = get(selectedwin(i), 'Data');
    names{N-i+1} = strrep(get(selectedwin(i), 'Name'), '_', '\_');
  end
end
set(hView, 'Names', names);

end


%---------------------------------------------------------------------
function clean_axes(haxtd, haxfd, hndls)
%CLEAN_AXES Delete the lines and remove xlabels and ylabels

delete(findall(allchild(haxtd), 'Tag', 'tline'));
delete(findall(allchild(haxfd), 'Tag', 'fline'));
set(hndls.axes.tdxlabel, 'String', '');
set(hndls.axes.tdylabel, 'String', '');
set(hndls.axes.fdxlabel, 'String', '');
set(hndls.axes.fdylabel, 'String', '');

end

%---------------------------------------------------------------------
function [xtstr, xfstr, tmultiplier, fmultiplier] = define_xlabel(this)
%DEFINE_XLABEL Define the xlabel strings

frequnits = getfrequnitstrs;
[fs, xfunits, fmultiplier] = getfs(this, 'freq');
[tfs, xtunits, tmultiplier] = getfs(this, 'time');
if strcmpi(get(getparameter(this, 'freqmode'), 'Value'), 'normalized')
  xtstr = getString(message('signal:sigtools:siggui:Samples'));
  xfstr = frequnits{1};
else
  xtstr = getString(message('signal:sigtools:siggui:Time', xtunits));
  xfstr = getString(message('signal:sigtools:siggui:Frequency', xfunits));
end

end

%---------------------------------------------------------------------
function [ytstr, yfstr] = define_ylabel(this)
%DEFINE_YLABEL Define the ylabel strings

ytstr = getString(message('signal:sigtools:siggui:Amplitude'));
p  = getparameter(this, 'magnitude');
yfstr = p.Value;
yfstr = getTranslatedString('signal:sigtools:siggui',yfstr);
if strcmpi(get(getparameter(this, 'normmag'), 'Value'), 'on')
  yfstr = sprintf('%s',getString(message('signal:sigtools:siggui:Normalized', yfstr)));
end

end


function onParentFigClosing(src, evt, figPreview) %#ok
if ishandle(figPreview)
  close(figPreview);
end

end


% -----------------------------------------------------------
function freqmodemodified_eventcb(this, eventData)

hDlg = get(this, 'ParameterDlg');

if isfield(get(eventData), 'Data')
  value = eventData.Data;
else
  hPrm = getparameter(this, 'freqmode');
  value = hPrm.Value;
end

if strcmpi(value, 'normalized')
  opts = {'[0, pi)', '[0, 2pi)', '[-pi, pi)'};
else
  opts = {'[0, Fs/2)', '[0, Fs)', '[-Fs/2, Fs/2)'};
end

if ~isempty(hDlg)
  
  if strcmpi(value, 'normalized')
    % Disable Sampling
    disableparameter(hDlg, 'sampfreq');
  else
    % Enable Sampling
    enableparameter(hDlg, 'sampfreq');
  end
  
end

% Set valid values of Range
setvalidvalues(getparameter(this, 'unitcircle'), opts);

end

% -----------------------------------------------------------
function freqmodenewvalue_eventcb(this, eventData)

hndls = get(this, 'Handles');
set(hndls.freqspecs, 'Checked', 'off');

hPrm = getparameter(this, 'freqmode');
value = hPrm.Value;

% Update the checked status of the menu items
if strcmpi(value, 'normalized')
  set(hndls.freqspecs([1 3]), 'Checked', 'on');
else
  set(hndls.freqspecs([2 4]), 'Checked', 'on');
end

end

% -----------------------------------------------------------
function sampfreqmodified_eventcb(this, eventData)

% Update Fs value in the context menu item
hndls = get(this, 'Handles');
[fs, xunits, multiplier] = getfs(this, 1);
set(hndls.freqspecs(2), 'Label', ...
  [getString(message('signal:sigtools:siggui:LinearFrequency')) ' (Fs = ' num2str(fs) xunits ')']);
end

%--------------------------------------------------------------------------
function [strs,cbs,tags,sep,accel] = getviewparams(this)
% Get the "View" menu parameters.

% Get the View menu labels
strs = {getString(message('signal:sigtools:siggui:TimeDomain')), ...
  getString(message('signal:sigtools:siggui:FrequencyDomain')), ...
  getString(message('signal:sigtools:siggui:Legnd')), ...
  getString(message('signal:sigtools:siggui:AnalysisParams'))};


% Define the CallBacks
cb = callbacks(this);
cbs = {cb.set_timedomain, ...
  cb.set_freqdomain, ...
  cb.legend, ...
  cb.analysisparam};

% Get the Tags
tags = {'timedomain', ...
  'freqdomain', ...
  'legendmenu', ...
  'frequnits'};

% Get the Separator flags
sep = {'Off', 'Off', 'On', 'On'};

% Get the Accelerators
accel = {'', '', '', '', ''};

end

%---------------------------------------------------------------------
function stretch_axes(hView)
%STRETCH_AXES Resize axes, set visibility

td = get(hView, 'Timedomain');
fd = get(hView, 'Freqdomain');

hndls = get(hView, 'Handles');
haxtd = hndls.axes.td;
haxfd = hndls.axes.fd;

% Resize axes, set visibility
axtdPos = get(haxtd, 'OuterPosition');
% Normalized values
axx1 = 0;
axx2 = 0.5; % second axes (Frequency Domain)
axy = axtdPos(2);
axw1 = 0.5; % when there are two axes
axw2 = 1; % one axes only
axh = axtdPos(4);

if strcmpi(td, 'on') & strcmpi(fd, 'on')
  % Time axes
  % Add normalized factor to preserve spacing ratio
  set(haxtd, ...
    'OuterPosition', [axx1 axy axw1 axh], ...
    'Visible',       'On');
  set(allchild(haxtd), 'Visible', 'On');
  
  % Frequency axes
  set(haxfd, ...
    'OuterPosition', [axx2 axy axw1 axh], ...
    'Visible',       'On');
  set(allchild(haxfd), 'Visible', 'On');
  
elseif strcmpi(td, 'on')
  % Only time axes
  set(haxtd, ...
    'OuterPosition', [axx1 axy axw2 axh], ...
    'Visible',       'On');
  set(allchild(haxtd), 'Visible', 'On');
  
  % Turn freq axes invisible
  set(findobj(haxfd), 'Visible' , 'off');
  
elseif strcmpi(fd, 'on')
  % Only frequency axes
  set(haxfd, ...
    'OuterPosition', [axx1 axy axw2 axh], ...
    'Visible',       'on');
  set(allchild(haxfd), 'Visible', 'On');
  
  % Turn time axes invisible
  set(findobj(haxtd), 'Visible' , 'off');
else
  % None
  set(findobj(haxtd), 'Visible' , 'off');
  set(findobj(haxfd), 'Visible' , 'off');
end

% Refresh legend
hView.Legend  = hView.Legend;

end


%---------------------------------------------------------------------
function update_viewmenus(hView)
%UPDATE_VIEWMENUS Update the 'View' menu and the context menu

td = get(hView, 'Timedomain');
fd = get(hView, 'Freqdomain');

hndls = get(hView, 'Handles');

% Time domain
timemenu = findobj([hndls.contextmenu hndls.menu], 'Tag', 'timedomain');
set(timemenu, 'Checked', td);

% Frequency domain
freqmenu = findobj([hndls.contextmenu hndls.menu], 'Tag', 'freqdomain');
set(freqmenu, 'Checked', fd);

% Enable/Disable the frequency YLabel contextmenu
hfline = findobj(hndls.axes.fd, 'Tag' , 'fline');
if isempty(hfline)
  % If  there's no data in the viewer
  enabState = 'off';
else
  enabState =  fd;
end
set(hndls.frespunits, 'Enable', enabState);

end


%---------------------------------------------------------------------
function [data, index] = get_data(hView)
%GET_DATA Get the data from the axes

hndls = get(hView, 'Handles');
haxtd = hndls.axes.td;

htline = findobj(haxtd, 'Tag' , 'tline');
N = length(htline);

% Get data
for i=1:N
  data(:,N-i+1) = get(htline(i), 'YData')';
  index(i) = get(htline(i), 'LineWidth')';
end

index = find(index == max(index));

end
