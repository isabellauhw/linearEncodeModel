classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, Abstract) abstractfreqrespMCOS < dspopts.abstractspectrumwfreqpointsMCOS
  %dspopts.abstractfreqresp class
  %   dspopts.abstractfreqresp extends dspopts.abstractspectrumwfreqpoints.
  %
  %    dspopts.abstractfreqresp properties:
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray'
  %       CenterDC - Property is of type 'mxArray'
  %       FreqPoints - Property is of type 'psdFreqPointsType enumeration: {'All','User Defined'}'
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %
  %    dspopts.abstractfreqresp methods:

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %SPECTRUMRANGE Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
    SpectrumRange = 'Half';
  end
  
  
  methods
    function set.SpectrumRange(obj,value)
      % Enumerated DataType = 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
      value = validatestring(value,{'Half','Whole'},'','SpectrumRange');
      obj.SpectrumRange = value;
    end
    
  end   % set and get functions
  
  methods (Hidden) %% possibly private or hidden
    function fullnyq(this)
      %FULLNYQ
   
      this.SpectrumRange = 'Whole';
  
    end
    
    function flag = ishalfnyqinterval(this)
      %ISHALFNYQINTERVAL

      if strcmpi(this.SpectrumRange,'whole')
        flag = false;
      else
        flag = true;
      end

    end
    
    function s = reorderstructure(this,s) %#ok
      %REORDERSTRUCTURE

      s = reorderstructure(s,'NFFT','NormalizedFrequency','Fs','SpectrumRange', 'CenterDC');
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

