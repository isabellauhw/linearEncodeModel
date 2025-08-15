classdef freqz < sigresp.freqaxiswfreqrange
  %sigresp.freqz class
  %   sigresp.freqz extends sigresp.freqaxiswfreqrange.
  %
  %    sigresp.freqz properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       FrequencyScale - Property is of type 'string'
  %       NormalizedFrequency - Property is of type 'string'
  %       FrequencyRange - Property is of type 'string'
  %       MagnitudeDisplay - Property is of type 'string'
  %       Spectrum - Property is of type 'dspdata.abstractfreqresp'
  %
  %    sigresp.freqz methods:
  %       attachlisteners -   Attach the custom listeners.
  %       freqmode_listener -   Listener for the freqmode parameter (Frequency Units).
  %       freqz_construct - Abstract frequency response class.
  %       freqz_freqmode_listener -   "Super" class freqmode_listener.
  %       getdatainputs -   Returns the inputs to GETDATA
  %       getfreqrangeopts -    Frequency range options based on the frequency units.
  %       getfreqrangevaluestag -   Returns the tag of the frequency range property.
  %       getlegendstrings - Returns the legend strings.
  %       getmagdisplaytag -   Return the tag of the MagnitudeDisplay property.
  %       getmaxfs -   Method to get the Fs from the spectrum object.
  %       getspectrum -   PreGet function for the spectrum
  %       gettoolname -   Get the toolname.
  %       getylabels -   Method to get the list of strings to be used for the ylabels.
  %       objspecificdraw -   Draw and set up axis for the frequency response.
  %       plot -   Plot the frequency response.
  %       plotline -   Set up the axes and plot the line.
  %       setfreqrangeopts -   Sets the valid frequency range options.
  %       setspectrum -   Pre set function for the spectrum
  %       setsptfigure - Set the default figure properties for Signal Toolbox GUIs.
  %       update_range -   Update the values of the Frequency Range Values.
  %       updateylabel -   Update the ylabel based on choice of frequency axis units.
  
  %   Copyright 2015-2017 The MathWorks, Inc.

  properties (AbortSet, SetObservable, GetObservable)
    %MAGNITUDEDISPLAY Property is of type 'string'
    MagnitudeDisplay = '';
    %SPECTRUM Property is of type 'dspdata.abstractfreqresp'
    Spectrum = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %POWERRESPONSELISTENERS Property is of type 'handle.listener vector'
    PowerResponseListeners = [];
    %PRIVSPECTRUM Property is of type 'dspdata.abstractfreqresp'
    privSpectrum = [];
  end
  
  
  methods  % constructor block
    function hresp = freqz(varargin)
      %FREQZ Construct a discrete-time frequency response object.
      %    FREQZ(H) constructs a frequency response object with the spectrum
      %    specified by the object H.  H must be an object that extends
      %    DSPDATA.ABSTRACTFREQRESP.

      % Create a response object.
      % hresp = sigresp.freqz;
      freqz_construct(hresp,varargin{:});
      hresp.Tag  = 'freqz';
      hresp.Name = 'Frequency Response';  % Title string
      
      
    end  % freqz
    
  end  % constructor block
  
  methods
    function value = get.MagnitudeDisplay(obj)
      value = getmag(obj,obj.MagnitudeDisplay);
    end
    function set.MagnitudeDisplay(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','MagnitudeDisplay')
      obj.MagnitudeDisplay = setmag(obj,value);
    end
    
    function value = get.Spectrum(obj)
      value = getspectrum(obj,obj.Spectrum);
    end
    function set.Spectrum(obj,value)
      % DataType = 'dspdata.abstractfreqresp'
      validateattributes(value,{'dspdata.abstractfreqresp'}, {'scalar'},'','Spectrum')
      obj.Spectrum = setspectrum(obj,value);
    end
    
    function set.PowerResponseListeners(obj,value)
      % DataType = 'handle.listener vector'
      validateattributes(value,{'prop.listener'}, {'vector'},'','PowerResponseListeners')
      obj.PowerResponseListeners = value;
    end
    
    function set.privSpectrum(obj,value)
      % DataType = 'dspdata.abstractfreqresp'
      validateattributes(value,{'dspdata.abstractfreqresp'}, {'scalar'},'','privSpectrum')
      obj.privSpectrum = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function attachlisteners(this)
      %ATTACHLISTENERS   Attach the custom listeners.

      l = event.proplistener(this, this.findprop('Spectrum'), 'PostSet', ...
        @(s,e)spectrum_listener1(s,e));
      
      set(this, 'WhenRenderedListeners', l);
      
    end
    
    
    function allPrm = freqz_construct(this,Spectrum,varargin)
      %FREQZ_CONSTRUCT Abstract frequency response class.
      
      if nargin > 1
        if ~isa(Spectrum, 'dspdata.abstractfreqresp')
          varargin = {Spectrum, varargin{:}};
          Spectrum = [];
        end
      else
        Spectrum = [];
      end
      
      allPrm = this.freqaxiswfreqrange_construct(varargin{:});
      
      % Convert between on/off and true/false data types for NormalizedFrequency.
      if Spectrum.NormalizedFrequency
        normfreq = 'on';
      else
        normfreq = 'off';
      end
      
      if ~isempty(Spectrum)
        set(this,...
          'NormalizedFrequency',normfreq); %,...
        %         'FrequencyUnits',Spectrum.Metadata.FrequencyUnits);
        
        setfreqrange(this,Spectrum);
      end
      
      % Ylabels for power response object.
      ylabels = getylabels(this);
      createparameter(this, allPrm, 'Magnitude Display',...
        getmagdisplaytag(this),ylabels,2);
      
      % Add a frequency range parameter object that is a static text box.
      %createparameter(hObj, allPrm, name, tag, varargin)
      name = 'Freq. Range Values';
      createparameter(this,allPrm,name,getfreqrangevaluestag(this),@lcl_ischar,'[0  1]');
      set(this, 'StaticParameters', {getfreqrangevaluestag(this)});
      
      % Create a listeners for properties of the response object.  Use
      % getparameter to create a listener for parameter objects.
      l = [ ...
        event.proplistener(this,this.findprop('Spectrum'), ...
        'PostSet', @(s,e)spectrum_listener(s,e)), ...
        event.proplistener(this,this.findprop('FrequencyRange'), ...
        'PostSet',@(s,e)freqrange_listener(s,e)), ...
        ];
      
      
      set(this, 'PowerResponseListeners', l);
      
      this.Spectrum = Spectrum;
      
      usedefault(this.Parameters, gettoolname(this));
      
    end
    
    
    function freqz_freqmode_listener(this, eventData)
      %FREQZ_FREQMODE_LISTENER   "Super" class freqmode_listener.

      % Call "super listener"
      freqaxis_freqmode_listener(this,eventData);
      
      % Set the correct frequency range options.
      setfreqrangeopts(this,eventData);
      
    end
    
    
    function datainputs = getdatainputs(this)
      %GETDATAINPUTS   Returns the inputs to GETDATA

      datainputs{1} = false;  % Is density selected in ylabel?
      datainputs{2} = ~isempty(strfind(this.MagnitudeDisplay, 'dB'));
      datainputs{3} = strcmpi(this.NormalizedFrequency, 'on');
      
      freqopts = lower(getfreqrangeopts(this));
      
      centerdc = false;
      switch lower(this.FrequencyRange)
        case freqopts{1}
          datainputs{4} = 'half';
          
        case freqopts{2}
          datainputs{4} = 'whole';
          
        case freqopts{3}
          datainputs{4} = 'whole';
          centerdc = true;
      end
      datainputs{5} = centerdc;
      
      
    end
    
    
    function rangeopts = getfreqrangeopts(this, normalizedStatus, nfft)
      %GETFREQRANGEOPTS    Frequency range options based on the frequency units.

      if nargin < 3
        if isempty(this.Spectrum)
          nfft = 0;
        else
          nfft = length(this.Spectrum.Data);
        end
        if nargin < 2
          normalizedStatus = this.NormalizedFrequency;
        end
      end
      
      endPt = ']';      % Even case, include nyquist point. Use this by default.
      if rem(nfft,2)
        endPt = ')';  % Odd case, don't include nyquist point.
      end
      
      if strcmpi(normalizedStatus, 'on')
        rangeopts = {sprintf('[0, pi%c',endPt), '[0, 2pi)', sprintf('(-pi, pi%c',endPt)};
      else
        rangeopts = {sprintf('[0, Fs/2%c',endPt), '[0, Fs)', sprintf('(-Fs/2, Fs/2%c',endPt)};
      end
      
    end
    
    
    function tag = getfreqrangevaluestag(this, freqrangevaluestag)
      %GETFREQRANGEVALUESTAG   Returns the tag of the frequency range property.

      tag = 'freqrangepowerresp';
      
    end
    
    function strs = getlegendstrings(this, varargin)
      %GETLEGENDSTRINGS Returns the legend strings.

      for k = 1:length(getline(this))
        strs{k} = getString(message('signal:sigtools:sigresp:Response0numberinteger',k));
      end
      
    end
    
    
    function tag = getmagdisplaytag(this)
      %GETMAGDISPLAYTAG   Return the tag of the MagnitudeDisplay property.

      tag = 'MagDisplay';
      
    end
    
    
    function fs = getmaxfs(this)
      %GETMAXFS   Method to get the Fs from the spectrum object.

      if isempty(this.Spectrum)
        fs = [];
      else
        fs = getfs(this.Spectrum);
      end
      
    end
    
    
    function spectrum = getspectrum(this, spectrum)
      %GETSPECTRUM   PreGet function for the spectrum

      spectrum = this.privSpectrum;
      
    end
    
    function toolname = gettoolname(this)
      %GETTOOLNAME   Get the toolname.

      toolname = 'spectrumplot';
      
    end
    
    
    function ylabels = getylabels(this)
      %GETYLABELS   Method to get the list of strings to be used for the ylabels.

      ylabels = {...
        getString(message('signal:sigtools:sigresp:Magnitude')), ...
        getString(message('signal:sigtools:sigresp:MagnitudedB'))};
      
    end
    
    
    function [m, xunits] = objspecificdraw(this)
      %OBJSPECIFICDRAW   Draw and set up axis for the frequency response.

      xunits='';
      m=1;
      
      if isempty(this.Spectrum), return; end
      
      inputs = getdatainputs(this);
      
      [H,W] = getdata(this.Spectrum, inputs{:});
      
      if isempty(H), return; end
      
      if ~iscell(H), H = {H}; W = {W}; end
      
      if strcmpi(this.NormalizedFrequency,'off')
        % Determine the correct engineering units to use for the x-axis.
        update_range(this,W{:});  % Doesn't need a cell array.
        [W, m, xunits] = cellengunits(W);
      else
        for indx = 1:length(W)
          W{indx} = W{indx}/pi;
        end
        update_range(this,W{:});  % Doesn't need a cell array.
      end
      plotline(this,W,H);
      
    end
    
    function plot(this)
      %PLOT   Plot the frequency response.
      %     This method adds context menus to the x- and y-labels, adds menu
      %     and context menu access to the analysis parameters dialog box, and
      %     sets up the figure properties.

      % Make sure we reuse existing figures that have newplot set to reuse.
      cax = newplot;
      hFig = get(0, 'CurrentFigure');
      set(hFig,'NextPlot','replace');
      
      render(this, cax);
      %set(this,'legend','on');
      
      % Add Signal Tbx menus and toolbar.
      tagStr = 'SAP'; % Spectral Analysis Plot
      if ~strcmpi(get(hFig,'Tag'),tagStr)
        setsptfigure(this,hFig);
        set(hFig,'Tag','SAP');  % Bread crumb to prevent calling setsptfigure.
      end
      
      % Add Analysis Parameter menu.
      render_analysisparammenu(this,hFig,[2,6]);
      
      % Install the context menu on the axis to access the analysis parameters.
      add_cs_parameters(this);
      
      set(this,'Visible','on');
      set(hFig, 'Visible', 'On');
      
      % Set up a listener to listen to error and warning events. Gets destroyed
      % when figure is "unrendered".
      hlistener = event.listener(this, 'Notification', @(s,e)notification_listener(s,e));
      this.WhenRenderedListeners = union(this.WhenRenderedListeners,hlistener);
      
    end
    
    
    function plotline(this,W,H)
      %PLOTLINE   Set up the axes and plot the line.

      hFig = this.FigureHandle;
      
      % Plot the spectrum and set ylabel.
      h = get(this, 'Handles');
      h.line = freqplotter(h.axes, W, H);
      
      ylbl = get(this, 'MagnitudeDisplay');
      hylbl = ylabel(h.axes, ylbl);
      
      % Install the context menu for changing units of the Y-axis.
      if ~ishandlefield(this, 'magcsmenu')
        h.magcsmenu = contextmenu(getparameter(this, getmagdisplaytag(this)), hylbl);
      end
      set(this, 'Handles', h);  % Store handles to new HG objects created.
      
    end
    
    
    function setfreqrangeopts(this,eventData)
      %SETFREQRANGEOPTS   Sets the valid frequency range options.

      hprm_freqmode = getparameter(this, 'freqmode');
      normalizedStatus = getsettings(hprm_freqmode, eventData);
      
      rangeopts = getfreqrangeopts(this,normalizedStatus);
      
      hprm = getparameter(this, getfreqrangetag(this));
      if ~isempty(hprm)
        setvalidvalues(hprm, rangeopts);
      end
      
      
    end
    
    
    function spectrum = setspectrum(this, spectrum)
      %SETSPECTRUM   Pre set function for the spectrum

      this.privSpectrum = spectrum;
      
      % Check metadata of new spectrum to update the units, i.e., update ylabel.
      setvalidvalues(getparameter(this, getmagdisplaytag(this)), getylabels(this));
      
      % [EOF]
      
    end
    
    
    function setsptfigure(this,hFig)
      %SETSPTFIGURE Set the default figure properties for Signal Toolbox GUIs.

      set(hFig,'MenuBar','None',...
        'ToolBar','None', ...
        'WindowButtonDownFcn', [], ...
        'WindowButtonMotionFcn', [], ...
        'WindowButtonUpFcn', []);
      
      % Create the menus
      render_menus(hFig);
      
      % Create the toolbar
      render_toolbar(hFig);
      
    end
    
    
    function update_range(this,W)
      %UPDATE_RANGE   Update the values of the Frequency Range Values.

      hPrm = getparameter(this,getfreqrangevaluestag(this));
      if isempty(this.Spectrum) | isempty(hPrm)
        % Return if still initializing.
        return;
      end
      
      if nargin < 2
        inputs = getdatainputs(this);
        [H, W] = getdata(this.Spectrum, inputs{:});
      end
      
      range = [min(W) max(W)];
      if strcmpi(get(getparameter(this, 'freqmode'),'Value'),'on')
        str = sprintf('[%1.2g  %1.2g] x pi', range);
      else
        str = sprintf('[%1.3g  %1.3g]',range);
      end
      
      if isrendered(this)
        set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'Off');
      end
      setvalue(hPrm,str);
      if isrendered(this)
        set(this.UsesAxes_WhenRenderedListeners, 'Enabled', 'On');
      end
      
    end
    
    
    function updateylabel(this, eventData)
      %UPDATEYLABEL   Update the ylabel based on choice of frequency axis units.
 
      if isempty(eventData) | strcmpi(eventData.Type,'NewValue')
        
        %  Update the Ylabel if choice is density (i.e., /freq) to make sure
        %  the ylabel is consistent with the frequency axis units.
        
        % Get the handle to the parameter object and get the Ylabel valid values.
        hprm_magdisp  = getparameter(this, getmagdisplaytag(this));
        Ylabel        = this.MagnitudeDisplay;
        ylabelChoices = get(hprm_magdisp,'ValidValues');
        
        % Update the ylabel based on the new value of the x-axis units.
        if length(ylabelChoices) > 2 % Only for PSDs
          
          hprm_freqmode = getparameter(this, 'freqmode');
          normalizedmode = getsettings(hprm_freqmode, eventData);
          
          if strcmpi(normalizedmode,'off') & strcmpi(ylabelChoices{3},Ylabel)  % psd/rad/sample
            % Change Ylabel to psd/Hz.  Set parameter object directly.
            setvalue(hprm_magdisp,ylabelChoices{2});
            
          elseif strcmpi(normalizedmode,'on') & strcmpi(ylabelChoices{2},Ylabel) % psd/hz,
            % Change Ylabel to psd/rad/sample.  Set parameter object directly.
            setvalue(hprm_magdisp,ylabelChoices{3});
          end
        end
      end
      
    end
    
  end  %% public methods
  
end  % classdef

function out = setmag(this, out)

hPrm = getparameter(this, getmagdisplaytag(this));
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setmag


% -------------------------------------------------------
function out = getmag(this, out)

hPrm = getparameter(this, getmagdisplaytag(this));
if ~isempty(hPrm)
  out = get(hPrm, 'Value');
else
  out = '';
end
end  % getmag


% -------------------------------------------------------------------------
function spectrum_listener1(this, eventData)

draw(this);

end


%--------------------------------------------------------------------------
function spectrum_listener(this, eventData)

update_range(this);
setfreqrangeopts(this, []);

end

%--------------------------------------------------------------------------
function lcl_ischar(userrange)

if ~isempty(userrange) & ~ischar(userrange)
  error(message('signal:sigresp:freqz:freqz_construct:MustBeAString'));
end

end

%--------------------------------------------------------------------------
function freqrange_listener(this, eventData)
%FREQRANGE_LISTENER   Listener for the FrequencyRange property.

% Update the frequency range static text when a new frequency range is
% selected.
update_range(this);

end

%--------------------------------------------------------------------------
function setfreqrange(this,hpsd)
%SETFREQRANGE Set the frequency range.
%             Set the range based on the frequency units and spectrum type.

% Get all possible frequency range options based on the units.
rangeOpts = getfreqrangeopts(this);

% Determine frequency range based on spectrum type.
% Using idx assumes rangeopts is in the following order:
%    1-half, 2-wholepos, 3-negnpos

if ishalfnyqinterval(hpsd)
  idx = 1;  % Half the Nyquist interval.
elseif getcenterdc(hpsd)
  idx = 3;  % Negative and positive frequencies.
else
  idx = 2;  % Full Nyquist interval: [0, Fs) or [0, pi).
end
this.FrequencyRange = rangeOpts{idx};

end

%--------------------------------------------------------------------------
function notification_listener(hresp, eventData)
%NOTIFICATION_LISTENER Listener for error/warnings etc.

switch lower(eventData.NotificationType)
  case 'erroroccurred'
    err = get(eventData, 'Data');
    str = getString(message('signal:sigresp:freqz:plot:SAError'));
    error(hresp,str,err.ErrorString); % error is a method of hresp not the error function
    
  case 'warningoccurred'
    warn = get(eventData, 'Data');
    str = getString(message('signal:sigresp:freqz:plot:SAWarning'));
    warning(hresp,str,warn.WarningString); % warning is a method of hresp not the warning function
end

end

%--------------------------------------------------------------------------
function [str,cb,tag,sep,accel] = analysisprm_menudescription(this)

str  = {getString(message('signal:sigtools:sigresp:AnalysisParameters'))};
cb   = {{@render_paramdlg,this}};
tag  = {'analysisparam'};
sep   = {'On'};
accel = {''};

end

%--------------------------------------------------------------------------
function hanalysisparammenu = render_analysisparammenu(this,hFig,position)
%RENDER_ANALYSISPARAMMENU Render the Analysis Parameter menu.

[str,cb,tag,sep,accel] = analysisprm_menudescription(this);

hm = findobj(findobj(hFig, 'type', 'uimenu', 'Position', position(1), ...
  'Parent', hFig), 'tag', tag{1});
if isempty(hm)
  hm = addmenu(hFig,position,str,cb,tag,sep,accel);
else
  set(hm, 'Callback', cb{1});
end

% Store handles in order for them to be deleted when the plot is unrendered.
h = get(this, 'Handles');
h.menu.params.dlg = hm;
set(this, 'Handles', h);

end

%--------------------------------------------------------------------------
function render_paramdlg(hcbo, eventStruct,hObj)

h = hObj.setupparameterdlg;
set(h, 'Visible', 'On');
figure(h.FigureHandle);

end


%--------------------------------------------------------------------------
function add_cs_parameters(this)
%ADD_CS_PARAMETERS   Add a context sensitive menu to the axis.

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');

hc = uicontextmenu('Parent', hFig);
set(h.axes, 'UIContextMenu', hc);

[str,cb,tag,sep,accel] = analysisprm_menudescription(this);

h.menu.params.analysis = uimenu(hc, ...
  'Label', str{1}, ...
  'Callback', cb{1}, ...
  'Tag', [tag{1},'csmenu']);

% Save handles to CS objects in the handles structure so that it can be
% deleted properly.
h.menu.params.contextmenu = hc;
set(this, 'Handles', h);

end


%-------------------------------------------------------------------
function  render_menus(hFig)

% Render the "File" menu
render_sptfilemenu(hFig);

% Render the "Edit" menu
render_spteditmenu(hFig);

% Render the "Insert" menu
render_sptinsertmenu(hFig,3);

% Render the "Tools" menu
render_spttoolsmenu(hFig,4);

% Render the "Window" menu
render_sptwindowmenu(hFig,5);

% Render a Signal Processing Toolbox "Help" menu
render_spthelpmenu(hFig,6);

end

%-------------------------------------------------------------------
function render_toolbar(hFig)

hui = uitoolbar('Parent',hFig);

% Render Print buttons (Print, Print Preview)
render_sptprintbtns(hui);

% Render the annotation buttons (Edit Plot, Insert Arrow, etc)
render_sptscribebtns(hui);

% Render the zoom buttons
render_zoombtns(hFig);

end

% [EOF]
