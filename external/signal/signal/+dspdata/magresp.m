classdef magresp < dspdata.abstractfiltfreqrespMCOS
  %dspdata.magresp class
  %   dspdata.magresp extends dspdata.abstractfiltfreqresp.
  %
  %    dspdata.magresp properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %
  %    dspdata.magresp methods:
  %       gettitle -   Get the title.
  %       plotindb -   Returns true.
  %       responseobj -   Magresp response object.
  
  
  
  methods  % constructor block
    function this = magresp(varargin)
      %MAGRESP   Construct a MAGRESP object.

      narginchk(0, 8);
      
      % this = dspdata.magresp;
      
      set(this, 'Name', 'Magnitude Response');
      
      % Construct a metadata object.
      set(this,'Metadata',dspdata.powermetadataMCOS);
      set(this.Metadata,...
        'FrequencyUnits','Hz',...
        'DataUnits','volts^2/Hz');
      
      % Initialize Data and Frequencies with defaults or user specified values.
      initialize(this,varargin{:});
      
      
    end  % magresp
    
  end  % constructor block
  
  methods  %% public methods
    function titlestr = gettitle(this)
      %GETTITLE   Get the title.

      titlestr = getString(message('signal:dspdata:dspdata:MagnitudeResponse'));
      
    end
    
    
    function b = plotindb(this)
      %PLOTINDB   Returns true.

      b = true;
      
    end
    
    
    function hresp = responseobj(this)
      %RESPONSEOBJ   Magresp response object.
      %
      % This is a private method.

      % Create the response object.
      hresp = sigresp.freqz(this);
      
    end
    
  end  %% public methods
  
end  % classdef

