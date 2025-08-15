classdef freqz < dspdata.abstractfreqrespwspectrumrangeMCOS
  %dspdata.freqz class
  %   dspdata.freqz extends dspdata.abstractfreqrespwspectrumrange.
  %
  %    dspdata.freqz properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %
  %    dspdata.freqz methods:
  %       plotindb -   Returns true.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  methods  % constructor block
    function this = freqz(varargin)
      %FREQZ   Discrete-time frequency response object.

      narginchk(0,8);
      
      % Create object and set the properties specific to this object.
      % this = dspdata.freqz;
      set(this,'Name','Transfer Function Estimate');
      
      % Construct a metadata object.
      set(this,'Metadata',dspdata.powermetadataMCOS);
      set(this.Metadata,'FrequencyUnits','Hz');
      set(this.Metadata,'DataUnits','');
      
      % Initialize Data and Frequencies with defaults or user specified values.
      initialize(this,varargin{:});
    end  % freqz
    
    
    %--------------------------------------------------------------------------
    
  end  % constructor block
  
  methods  %% public methods
    function b = plotindb(this)
      %PLOTINDB   Returns true.
      
      b = true;
    end
    
  end  %% public methods
  
end  % classdef

function validate(spectrumRange)
% This error checking should be done in the object's set method, but for
% enum datatypes UDD first checks the list before calling the set method.

validStrs = {'half','whole'};
if ~ischar(spectrumRange) | ~any(strcmpi(spectrumRange,validStrs))
  error(message('signal:dspdata:freqz:freqz:invalidSpectrumRange', 'SpectrumRange', validStrs{ 1 }, validStrs{ 2 }));
end
end  % validate


