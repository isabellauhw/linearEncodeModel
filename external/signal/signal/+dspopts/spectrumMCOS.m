classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) spectrumMCOS < dspopts.abstractspectrumwfreqpointsMCOS
  %dspopts.spectrum class
  %   dspopts.spectrum extends dspopts.abstractspectrumwfreqpoints.
  %
  %    dspopts.spectrum properties:
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray'
  %       CenterDC - Property is of type 'mxArray'
  %       FreqPoints - Property is of type 'psdFreqPointsType enumeration: {'All','User Defined'}'
  %       SpectrumType - Property is of type 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
  %       ConfLevel - Property is of type 'mxArray'
  %       ConfInterval - Property is of type 'twocol_nonneg_matrix user-defined'
  %
  %    dspopts.spectrum methods:
  %       getrangepropname -   Get the rangepropname.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %SPECTRUMTYPE Property is of type 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
    SpectrumType = 'Onesided';
    %CONFLEVEL Property is of type 'mxArray'
    ConfLevel = [];
    %CONFINTERVAL Property is of type 'twocol_nonneg_matrix user-defined'
    ConfInterval = [];
  end
  
  
  methods  % constructor block
    function this = spectrumMCOS(varargin)
      %SPECTRUM   Options object for PSD and mean-square spectrum analysis.
      %
      %   To create a PSD or mean-square spectrum options object use the spectrum
      %   object methods <a href="matlab:help spectrum/psdopts">psdopts</a> and <a href="matlab:help spectrum/msspectrumopts">msspectrumopts</a>, respectively.
      %
      %   See also SPECTRUM, SPECTRUM/PSEUDOSPECTRUMOPTS
      
      if nargin
        set(this, varargin{:});
      end
      
      % Set the FreqPoints explicitly to call the set function.
      this.FreqPoints = 'All';
      
    end  % spectrum
    
  end  % constructor block
  
  methods
    function set.SpectrumType(obj,value)
      % Enumerated DataType = 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
      value = validatestring(value,{'Onesided','Twosided'},'','SpectrumType');
      obj.SpectrumType = value;
    end
    
    function value = get.ConfLevel(obj)
      value = get_ConfLevel(obj,obj.ConfLevel);
    end
    function set.ConfLevel(obj,value)
      obj.ConfLevel = set_ConfLevel(obj,value);
    end
    
    function set.ConfInterval(obj,value)
      % User-defined DataType = 'twocol_nonneg_matrix user-defined'
      obj.ConfInterval = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function rangepropname = getrangepropname(this)
      %GETRANGEPROPNAME   Get the rangepropname.
      
      rangepropname = 'SpectrumType';
      
    end
    
  end  %% public methods
  
  methods (Hidden) %% possibly private or hidden
    function fullnyq(this)
      %FULLNYQ
      
      this.SpectrumType = 'Twosided';
      
    end
    
    
    function flag = ishalfnyqinterval(this)
      %ISHALFNYQINTERVAL
      
      if strcmpi(this.SpectrumType,'Twosided')
        flag = false;
      else
        flag = true;
      end
      
    end
    
    function s = reorderstructure(this, s) %#ok
      %REORDERSTRUCTURE
      
      if (isprop(this, 'NFFT'))
        s = reorderstructure(s,'FreqPoints', 'NFFT','NormalizedFrequency','Fs','SpectrumType', 'CenterDC');
      elseif (isprop(this, 'FrequencyVector'))
        s = reorderstructure(s,'FreqPoints', 'FrequencyVector','NormalizedFrequency','Fs','SpectrumType', 'CenterDC');
      end
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function ConfLevel = set_ConfLevel(this,ConfLevel)
%%SET_CONFLEVEL Set function for the ConfLevel property.

if (~isempty(ConfLevel) && (~isnumeric(ConfLevel) || ~isscalar(ConfLevel)...
    || ConfLevel == 0 || abs(ConfLevel) >= 1 ))
  error(message('signal:dspopts:spectrum:schema:invalidConfidenceLevel'));
end
end  % set_ConfLevel


%--------------------------------------------------------------------------
function ConfLevel = get_ConfLevel(this, ConfLevel)
%%GET_CONFLEVEL   Return the value of the CONFLEVEL property.

if isempty(ConfLevel)
  ConfLevel = 'Not Specified';
end
end  % get_ConfLevel


% [EOF]
