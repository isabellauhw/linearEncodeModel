classdef pseudospectrumMCOS < dspopts.abstractfreqrespMCOS
  %dspopts.pseudospectrum class
  %   dspopts.pseudospectrum extends dspopts.abstractfreqresp.
  %
  %    dspopts.pseudospectrum properties:
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray'
  %       CenterDC - Property is of type 'mxArray'
  %       FreqPoints - Property is of type 'psdFreqPointsType enumeration: {'All','User Defined'}'
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %
  %    dspopts.pseudospectrum methods:
  %       getrangepropname -   Returns the property name for the range option.
  
  
  
  methods  % constructor block
    function this = pseudospectrumMCOS(varargin)
      %PSEUDOSPECTRUM   Options object for pseudospectrum analysis.
      %
      %   To create a pseudospectrum options object use the spectrum object
      %   method <a href="matlab:help spectrum/pseudospectrumopts">pseudospectrumopts</a>.
      %
      %   See also SPECTRUM, SPECTRUM/MSSPECTRUMOPTS, SPECTRUM/PSDOPTS.
      
      if nargin
        set(this, varargin{:});
      end
      
      
    end  % pseudospectrum
    
  end  % constructor block
  
  methods  %% public methods
    function rangepropname = getrangepropname(this)
      %GETRANGEPROPNAME   Returns the property name for the range option.
 
      rangepropname = 'SpectrumRange';

    end
        
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function s = reorderstructure(this, s) %#ok
      %REORDERSTRUCTURE
      
      if (isprop(this, 'NFFT'))
        s = reorderstructure(s,'FreqPoints', 'NFFT','NormalizedFrequency','Fs','SpectrumRange', 'CenterDC');
      elseif (isprop(this, 'FrequencyVector'))
        s = reorderstructure(s,'FreqPoints', 'FrequencyVector','NormalizedFrequency','Fs','SpectrumRange', 'CenterDC');
      end
      
    end
        
  end  %% possibly private or hidden
  
end  % classdef

