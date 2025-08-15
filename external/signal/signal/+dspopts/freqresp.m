classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) freqresp < dspopts.abstractfreqrespMCOS
  %dspopts.freqresp class
  %   dspopts.freqresp extends dspopts.abstractfreqresp.
  %
  %    dspopts.freqresp properties:
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray'
  %       CenterDC - Property is of type 'mxArray'
  %       FreqPoints - Property is of type 'psdFreqPointsType enumeration: {'All','User Defined'}'
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %       NFFT - Property is of type 'mxArray'
  %       FrequencySpecification - Property is of type 'NFFTorFreqVec enumeration: {'NFFT','FrequencyVector'}'
  %       FrequencyVector - Property is of type 'double_vector user-defined'
  %
  %    dspopts.freqresp methods:
  %       disp -   Display this object.
  %       freqzinputs -   Return a cell with the inputs for FREQZ, PHASEZ, etc.
  %       get_frequencyvector -   PreGet function for the 'frequencyvector' property.
  %       set_frequencyvector -   PreSet function for the 'frequencyvector' property.
  %       set_nfft -   PreSet function for the 'nfft' property.

%   Copyright 2015-2018 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %NFFT Property is of type 'mxArray'
    NFFT = 'nextpow2';
    %FREQUENCYSPECIFICATION Property is of type 'NFFTorFreqVec enumeration: {'NFFT','FrequencyVector'}'
    FrequencySpecification = 'NFFT';
    %FREQUENCYVECTOR Property is of type 'double_vector user-defined'
    FrequencyVector = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVFREQUENCYVECTOR Property is of type 'double_vector user-defined'
    privFrequencyVector = linspace( 0, 1, 512 );
  end
  
  
  methods  % constructor block
    function this = freqresp(varargin)
      %FREQRESP   Construct a FREQRESP object.
      [varargin{:}] = convertStringsToChars(varargin{:});
      
      % this = dspopts.freqresp;
      this.NFFT = 8192;  % Avoid having NFFT set to "new" default 'Nextpow2'.
      
      % We need to special case the constructor to allow users to specify the
      % freequency vector without having to specify the frequencyspecification
      % first.  This would be burdensome.
      
      for indx = 1:3:length(varargin)
        if any(strncmpi(varargin{indx}, {'NFFT', 'FrequencyVector'}, length(varargin{indx})))
          varargin = {varargin{1:indx-1}, ...
            'FrequencySpecification', varargin{indx}, ...
            varargin{indx:end}};
        end
      end
      
      if nargin
        set(this, varargin{:});
      end
      
      
    end  % freqresp
    
  end  % constructor block
  
  methods
    function set.NFFT(obj,value)
      obj.NFFT = set_nfft(obj,value);
    end
    
    function set.FrequencySpecification(obj,value)
      % Enumerated DataType = 'NFFTorFreqVec enumeration: {'NFFT','FrequencyVector'}'
      value = validatestring(value,{'NFFT','FrequencyVector'},'','FrequencySpecification');
      obj.FrequencySpecification = value;
    end
    
    function value = get.FrequencyVector(obj)
      value = get_frequencyvector(obj,obj.FrequencyVector);
    end
    function set.FrequencyVector(obj,value)
      % User-defined DataType = 'double_vector user-defined'
      obj.FrequencyVector = set_frequencyvector(obj,value);
    end
    
    function set.privFrequencyVector(obj,value)
      % User-defined DataType = 'double_vector user-defined'
      obj.privFrequencyVector = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function disp(this)
      %DISP   Display this object.

      p = {'NormalizedFrequency'};
      
      if ~this.NormalizedFrequency
        p = {p{:}, 'Fs'};
      end
      
      p = {p{:}, 'FrequencySpecification'};
      
      if strcmpi(this.FrequencySpecification, 'NFFT')
        p = {p{:}, 'NFFT', 'SpectrumRange', 'CenterDC'};
      else
        p = {p{:}, 'FrequencyVector'};
      end
      
      siguddutils('dispstr', this, p);

    end
    
    
    function c = freqzinputs(this)
      %FREQZINPUTS   Return a cell with the inputs for FREQZ, PHASEZ, etc.

      switch lower(this.FrequencySpecification)
        case 'nfft'
          c = {this.NFFT, this.SpectrumRange};
        case 'frequencyvector'
          c = {this.FrequencyVector};
      end
      
      if ~this.NormalizedFrequency
        c = {c{:}, this.Fs};
      end

    end
    
    
    function fv = get_frequencyvector(this, fv) %#ok
      %GET_FREQUENCYVECTOR   PreGet function for the 'frequencyvector' property.
  
      fv = get(this, 'privFrequencyVector');

    end
    
    
    function fv = set_frequencyvector(this, fv)
      %SET_FREQUENCYVECTOR   PreSet function for the 'frequencyvector' property.

      set(this, 'FrequencySpecification', 'FrequencyVector');
      
      % if strcmpi(this.FrequencySpecification, 'NFFT')
      %     siguddutils('readonlyerror', 'FrequencyVector', ...
      %         'FrequencySpecification', 'FrequencyVector');
      % end
      
      set(this, 'privFrequencyVector', fv);
      
      fv = [];
 
    end
        
    function nfft = set_nfft(this, nfft)
      %SET_NFFT   PreSet function for the 'nfft' property.

      set(this, 'FrequencySpecification', 'NFFT');
      
      if ischar(nfft) || ~isscalar(nfft) || nfft<=0 || rem(nfft,1)
        error(message('signal:dspopts:freqresp:set_nfft:invalidDataType', 'NFFT', 'NFFT'));
      end
      % [EOF]
      
    end
    
    function varargout = set(obj,varargin)      
      [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});            
    end
    
    function values = getAllowedStringValues(~,prop)
      % This function gives the the valid string values for object properties.
      
      switch prop
        case 'FrequencySpecification'
          values = {...
            'NFFT'
            'FrequencyVector'};
          
        otherwise
          values = {};
      end
      
    end
    
  end  %% public methods
  
end  % classdef

