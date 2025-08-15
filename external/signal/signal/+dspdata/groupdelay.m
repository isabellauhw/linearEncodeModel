classdef groupdelay < dspdata.abstractfiltfreqrespMCOS
  %dspdata.groupdelay class
  %   dspdata.groupdelay extends dspdata.abstractfiltfreqresp.
  %
  %    dspdata.groupdelay properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %
  %    dspdata.groupdelay methods:
  %       gettitle -   Get the title.
  %       getylabel -   Get the ylabel.
  
  
  
  methods  % constructor block
    function this = groupdelay(varargin)
      %GROUPDELAY   Construct a GROUPDELAY object.
 
      narginchk(0,8);
      
      % Create and initialize object.
      % this = dspdata.groupdelay;
      
      set(this,'Name','Group Delay');
      
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
      
      
    end  % groupdelay
    
  end  % constructor block
  
  methods  %% public methods
    function title = gettitle(this)
      %GETTITLE   Get the title.

      title = getString(message('signal:dspdata:dspdata:GroupDelay'));
      
    end
    
    
    function ylbl = getylabel(this)
      %GETYLABEL   Get the ylabel.

      if this.NormalizedFrequency
        ylbl = getString(message('signal:dspdata:dspdata:GroupDelayinSamples'));
      else
        ylbl = getString(message('signal:dspdata:dspdata:GroupDelayinSeconds'));
      end
      
    end
    
  end  %% public methods
  
end  % classdef

