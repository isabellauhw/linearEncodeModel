classdef cpsd < dspdata.abstractfreqrespwspectrumtypeMCOS
  %dspdata.cpsd class
  %   dspdata.cpsd extends dspdata.abstractfreqrespwspectrumtype.
  %
  %    dspdata.cpsd properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumType - Property is of type 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
  %
  %    dspdata.cpsd methods:
  %       convert2db -   COnvert the data to dB.
  %       isdensity -   True if the object contains density data.
  %       plotindb -   Returns true.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  
  methods  % constructor block
    function this = cpsd(varargin)
      %CPSD   Construct a CPSD object.

      narginchk(0,8);
      
      % Create object and set the properties specific to this object.
      % this = dspdata.cpsd;
      set(this,'Name','Cross Power Spectral Density');
      
      % Construct a metadata object.
      set(this,'Metadata',dspdata.powermetadataMCOS);
      set(this.Metadata,...
        'FrequencyUnits','Hz',...
        'DataUnits','volts^2/Hz');
      
      % Initialize Data and Frequencies with defaults or user specified values.
      initialize(this,varargin{:});
            
    end  % cpsd
    
  end  % constructor block
  
  methods  %% public methods
    function data = convert2db(this, data)
      %CONVERT2DB   COnvert the data to dB.

      if nargin < 2
        data = get(this, 'Data');
      end
      
      ws = warning; % Cache warning state
      warning off   % Avoid "Log of zero" warnings
      data = db(abs(data), 'power');  % Call the Convert to decibels engine
      warning(ws);  % Reset warning state
      
    end
    
    
    function b = isdensity(this)
      %ISDENSITY   True if the object contains density data.

      b = true;
      
    end
        
    function b = plotindb(this)
      %PLOTINDB   Returns true.

      b = true;
      
    end
        
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function [H, W] = thiscomputeresp4freqrange(this, H, W, isdensity, isdb)
      %THISCOMPUTERESP4FREQRANGE

      H = abs(H);
      
      % Catch the case when user requested to view the data in PS form, i.e, PSD
      % w/out dividing by Fs.  This is only a feature of the plotted PSD.
      if ~isdensity
        if this.NormalizedFrequency
          Fs = 2*pi;
        else
          Fs = this.getfs;
        end
        H = H*Fs;    % Don't divide by Fs, essentially create a "PS".
      end
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

