classdef magnitude < dspdata.abstractfreqrespwspectrumrangeMCOS
  %dspdata.magnitude class
  %   dspdata.magnitude extends dspdata.abstractfreqrespwspectrumrange.
  %
  %    dspdata.magnitude properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %
  %    dspdata.magnitude methods:
  %       validatedata -   Validate the data
  
    
  methods  % constructor block
    function this = magnitude(varargin)
      %MAGNITUDE   Construct a MAGNITUDE object.

      narginchk(0,8);
      
      % Create and initialize object.
      % this = dspdata.magnitude;
      
      set(this,'Name','Magnitude');
      
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
      
      
    end  % magnitude
    
  end  % constructor block
  
  methods  %% public methods
    function validatedata(this, data)
      %VALIDATEDATA   Validate the data

      if nargin < 2
        data = get(this, 'Data');
      end
      
      % Check that the data is real.
      if any(~isreal(data(:)))
        error(message('signal:dspdata:magnitude:validatedata:invalidComplexData', 'DSPDATA.PSD'));
      end
      
      % Check that the data is positive.
      if any(data(:) < 0)
        error(message('signal:dspdata:magnitude:validatedata:invalidNegativeData', 'DSPDATA.PSD'));
      end
      
    end
    
  end  %% public methods
  
end  % classdef

