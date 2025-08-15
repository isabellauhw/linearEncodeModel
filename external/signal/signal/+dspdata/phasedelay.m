classdef phasedelay < dspdata.abstractfiltfreqrespMCOS
  %dspdata.phasedelay class
  %   dspdata.phasedelay extends dspdata.abstractfiltfreqresp.
  %
  %    dspdata.phasedelay properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %
  %    dspdata.phasedelay methods:
  %       gettitle -   Get the title.
  %       getylabel -   Get the ylabel.
  
  
  
  methods  % constructor block
    function this = phasedelay(varargin)
      %PHASEDELAY   Construct a PHASEDELAY object.

      narginchk(0,8);
      
      % Create and initialize object.
      % this = dspdata.phasedelay;
      
      set(this,'Name','Phase Delay');
      
      % Construct a metadata object.
      set(this,'Metadata',dspdata.powermetadataMCOS);
      set(this.Metadata,'FrequencyUnits','Hz');
      % From the help of TFESTIMATE and MSCOHERE we are deducing that there are
      % no units for the magnitude:
      %
      % The magnitude squared coherence Cxy is given by
      %         Cxy = (abs(Pxy).^2)./(Pxx.*Pyy)
      set(this.Metadata,'DataUnits','');
      
      % Initialize Data and Frequencies with defaults or user specified values.
      initialize(this,varargin{:});
      
      
    end  % phasedelay
    
  end  % constructor block
  
  methods  %% public methods
    function titlestr = gettitle(this)
      %GETTITLE   Get the title.
      titlestr = 'Phase Delay';
    end    
    
    function ylbl = getylabel(this)
      %GETYLABEL   Get the ylabel.

      if this.NormalizedFrequency
        ylbl = getString(message('signal:dspdata:dspdata:PhaseDelaySamples'));
      else
        ylbl = getString(message('signal:dspdata:dspdata:PhaseDelayRadiansHz'));
      end
      
    end    
    
  end  %% public methods
  
end  % classdef

