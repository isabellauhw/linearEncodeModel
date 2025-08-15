classdef powerresp < sigresp.freqz
  %sigresp.powerresp class
  %   sigresp.powerresp extends sigresp.freqz.
  %
  %    sigresp.powerresp properties:
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
  %    sigresp.powerresp methods:
  %       freqmode_listener -   Listener for the freqmode (Frequency Units) parameter.
  %       frequnits_listener -   Listener to the frequnits parameter.
  %       getdatainputs -   Returns the inputs to GETDATA
  %       getylabels - Method to get the list of strings to be used for the ylabels.
  %       updateylabel -   Update the ylabel based on choice of frequency axis units.
  
  %   Copyright 2015-2017 The MathWorks, Inc.
  
  
  methods  % constructor block
    function this = powerresp(varargin)
      %POWERRESP Construct a power response object.
      %    POWERRESP(H) constructs a power response (PSD) object with the power
      %    spectrum specified by the object H.  H must be an object that extends
      %    DSPDATA.ABSTRACTPS.

      
      % Create a response object.
      % this = sigresp.powerresp;
      freqz_construct(this,varargin{:});
      
      % Assign properties.
      this.Tag  = 'powerresp';
      this.Name = 'Power Spectrum Response';  % Title string
      
      % Create a listeners for properties of the response object.  Use
      % getparameter to create a listener for parameter objects.
      existinglisteners = this.PowerResponseListeners;
      l = [existinglisteners; ...
        event.listener(getparameter(this, 'frequnits'),...
        'NewValue',@(s,e)frequnits_listener(s,e))];
      
      %     handle.listener(getparameter(this,this.getmagdisplaytag),...
      %     'NewValue',@magnitudedisplay_listener); ...
      
      %     set(l, 'CallbackTarget', this);
      set(this, 'PowerResponseListeners', l);
      
      % At this point the freq units are correct because we get them from the PSD
      % data object, so force an update on the ylabel.
      freqmode_listener(this,[]);
    end  % powerresp
    
    
    %--------------------------------------------------------------------------
    
  end  % constructor block
  
  methods  %% public methods
    function freqmode_listener(this, eventData)
      %FREQMODE_LISTENER   Listener for the freqmode (Frequency Units) parameter.

      freqz_freqmode_listener(this,eventData);
      
      % Set the ylabel to match frequency units.
      updateylabel(this,eventData);
      
      
    end
    
    
    function frequnits_listener(this, eventData)
      %FREQUNITS_LISTENER   Listener to the frequnits parameter.

      setvalidvalues(getparameter(this, getmagdisplaytag(this)), getylabels(this));
      
    end
    
    
    function datainputs = getdatainputs(this)
      %GETDATAINPUTS   Returns the inputs to GETDATA

      datainputs{1} = isempty(strfind(this.MagnitudeDisplay, 'normalized '));
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
      datainputs{5} = true; % centerdc
      
      
    end
    
    
    function ylabels = getylabels(this, eventData)
      % GETYLABELS Method to get the list of strings to be used for the ylabels.

      if isempty(this.Spectrum)
        dataunits = '';
      else
        dataunits = sprintf(' (%s)', this.Spectrum.Metadata.DataUnits);
      end
      
      if nargin > 1
        nf = getsettings(getparameter(this, 'freqmode'), eventData);
      else
        nf = get(this, 'NormalizedFrequency');
      end
      
      if strcmpi(nf, 'On')
        frequ = getString(message('signal:sigtools:sigresp:Radsample'));
        dataunits = strrep(dataunits, 'Hz', frequ);
      else
        frequ = 'Hz';
      end
      
      lblStr = getString(message('signal:sigtools:sigresp:Powerfrequency'));
      ylabels = {...
        sprintf('%s%s', lblStr, dataunits),...       %linear /Hz
        sprintf('%s (dB/%s)', lblStr, frequ), ...    %dB/Hz
        sprintf(['%s%s (' getString(message('signal:sigtools:sigresp:normalizedTo')) ' 1 %s)'], lblStr, dataunits, frequ),... %linear (normalized to 1Hz)
        sprintf(['%s (dB/%s) (' getString(message('signal:sigtools:sigresp:normalizedTo')) ' 1 %s)'], lblStr,frequ, frequ)};  %linear dB
      
      
    end
    
    
    function updateylabel(this, eventData)
      %UPDATEYLABEL   Update the ylabel based on choice of frequency axis units.

      hprm = getparameter(this, getmagdisplaytag(this));
      if isempty(hprm), return; end
      
      ylabels = getylabels(this, eventData);
      
      setvalidvalues(hprm, ylabels);
      
      % if isempty(eventData) | strcmpi(eventData.Type,'NewValue'),
      %
      %     %  Update the Ylabel if choice is density (i.e., /freq) to make sure
      %     %  the ylabel is consistent with the frequency axis units.
      %
      %     % Get the handle to the parameter object and get the Ylabel valid values.
      %     hprm_magdisp  = getparameter(this, getmagdisplaytag(this));
      %     Ylabel        = this.MagnitudeDisplay;
      %     ylabelChoices = get(hprm_magdisp,'ValidValues');
      %
      %     % Update the ylabel based on the new value of the x-axis units.
      %     if ~isempty(ylabelChoices),  % Avoid initialization emptys
      %
      %         hprm_freqmode = getparameter(this, 'freqmode');
      %         normalizedmode = getsettings(hprm_freqmode, eventData);
      %
      %         if strcmpi(normalizedmode,'off') & strcmpi(ylabelChoices{3},Ylabel),  % psd/rad/sample
      %             % Change Ylabel to psd/Hz.  Set parameter object directly.
      %             setvalue(hprm_magdisp,ylabelChoices{2});
      %
      %         elseif strcmpi(normalizedmode,'on') & any(strcmpi(ylabelChoices(1:2),Ylabel)), % psd/hz,
      %             % Change Ylabel to psd/rad/sample.  Set parameter object directly.
      %             setvalue(hprm_magdisp,ylabelChoices{3});
      %         end
      %     end
      % end
      
      
    end
    
  end  %% public methods
  
end  % classdef

function magnitudedisplay_listener(this, eventData)
%MAGNITUDEDISPLAY_LISTENER   Listener for the MagnitudeDisplay property.

% Disable the listener that would fire the redraw, because we're already
% firing the redraw for the magntidue display.
cacheState = [];
if isrendered(this)
  l = get(this, 'UsesAxes_WhenRenderedListeners');
  cacheState = get(l(1),'Enabled');
else
  l = [];
end
set(l,'Enabled','Off');

hprm_magdisp  = getparameter(this, getmagdisplaytag(this));
newYlabel     = getsettings(hprm_magdisp, eventData);  % Gets GUI value.
ylabelChoices = get(hprm_magdisp,'ValidValues');

if length(ylabelChoices) > 2 % Only for PSDs
  
  normalizedUnits = this.NormalizedFrequency;
  
  if  strcmpi(normalizedUnits,'on') & any(strcmpi(ylabelChoices(1:2),newYlabel)) % psd/hz
    % Change x-axis to Hz if it was normalized.
    this.NormalizedFrequency = 'off';
    
  elseif  strcmpi(normalizedUnits,'off') & strcmpi(ylabelChoices{3},newYlabel)  % psd/rad/sample
    % Change x-axis to rad/sample if it was hz.
    this.NormalizedFrequency = 'on';
  end
end

set(l,'Enabled',cacheState);
end  % magnitudedisplay_listener


