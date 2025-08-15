classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) abstractfreqrespwspectrumrangeMCOS < dspdata.abstractfreqrespMCOS
  %dspdata.abstractfreqrespwspectrumrange class
  %   dspdata.abstractfreqrespwspectrumrange extends dspdata.abstractfreqresp.
  %
  %    dspdata.abstractfreqrespwspectrumrange properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %
  %    dspdata.abstractfreqrespwspectrumrange methods:
  %       getrangepropname -   Returns the property name for the range option.
  %       getspectrumtype -   Get the SpectrumRange property value.
  %       getylabel - Get the ylabel.
  %       halfrange -   Power spectrum calculated over half the Nyquist interval.
  %       setspectrumtype -   Set the spectrumrange property value.
  %       thisloadobj -   Load this object.
  %       wholerange -   Power spectrum calculated over the whole Nyquist interval.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVSPECTRUMRANGE Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
    privSpectrumRange = 'Half';
  end
  
  properties (Transient, AbortSet, SetObservable, GetObservable)
    %SPECTRUMRANGE Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
    SpectrumRange = 'Half';
  end
  
  
  methods
    function value = get.SpectrumRange(obj)
      value = get_spectrumrange(obj,obj.SpectrumRange);
    end
    function set.SpectrumRange(obj,value)
      % Enumerated DataType = 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
      value = validatestring(value,{'Half','Whole'},'','SpectrumRange');
      obj.SpectrumRange = set_spectrumrange(obj,value);
    end
    
    function set.privSpectrumRange(obj,value)
      % Enumerated DataType = 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
      value = validatestring(value,{'Half','Whole'},'','privSpectrumRange');
      obj.privSpectrumRange = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function rangepropname = getrangepropname(this)
      %GETRANGEPROPNAME   Returns the property name for the range option.
 
      rangepropname = 'SpectrumRange';
      
    end
    
    function privspectrumrange = getspectrumtype(this)
      %GETSPECTRUMTYPE   Get the SpectrumRange property value.

      privspectrumrange = this.privSpectrumRange;
      
    end
    
    function ylbl = getylabel(this)
      %GETYLABEL Get the ylabel.

      if this.plotindb
        ylbl = getString(message('signal:dspdata:dspdata:MagnitudedB'));
      else
        ylbl = getString(message('signal:dspdata:dspdata:Magnitude'));
      end
      
    end
    
    function halfrange(this)
      %HALFRANGE   Power spectrum calculated over half the Nyquist interval.

      newSpectrumRange = 'half';
      if strcmpi(this.SpectrumRange,newSpectrumRange)
        % Spectrum already 'half' the Nyquist interval.
        return
      end
      
      % Convert a spectrum calculated over the 'whole' Nyquist interval to
      % spectrum calculated over 'half' the Nquist interval.
      [nfft,~] = size(this.Data);
      if rem(nfft,2),    select = 1:(nfft+1)/2;  % ODD;  take only [0,pi)
      else               select = 1:nfft/2+1;    % EVEN; take only [0,pi]
      end
      
      % Update object with new values.
      set(this,...
        'Data',this.Data(select,:),...
        'Frequencies', this.Frequencies(select));
      
      setspectrumtype(this,newSpectrumRange);
      
    end
    
    function setspectrumtype(this, spectrumrange)
      %SETSPECTRUMTYPE   Set the spectrumrange property value.

      set(this,'privSpectrumRange',spectrumrange);
      
    end
    
    
    function thisloadobj(this, s)
      %THISLOADOBJ   Load this object.

      set(this, 'privSpectrumRange', s.SpectrumRange);
      
    end
    
    
    function wholerange(this)
      %WHOLERANGE   Power spectrum calculated over the whole Nyquist interval.

      newSpectrumRange = 'whole';
      if strcmpi(this.SpectrumRange,newSpectrumRange)
        % Already a 'whole' spectrum.
        return;
      end
      
      if this.NormalizedFrequency
        fnyq = pi;
      else
        fnyq = this.getfs/2;
      end
      
      % Convert a spectrum calculated over the 'half' the Nyquist interval to
      % spectrum calculated over the 'whole' Nquist interval.
      Sxx = this.Data;
      [Nfft,~] = size(Sxx);
      startIdx = Nfft+1;
      W = this.Frequencies;
      if isevenwholenfft(this,Nfft,W)      % EVEN "whole" NFFT
        endIdx = (Nfft-1)*2;
        Sxx(startIdx:endIdx,:) = Sxx(Nfft-1:-1:2,:);  % Add positive half.
        W(startIdx:endIdx) = W(2:Nfft-1)+fnyq;
        
      else                                  % ODD "whole" NFFT
        endIdx = (Nfft*2)-1;
        Sxx(startIdx:endIdx,:) = Sxx(Nfft:-1:2,:);    % Add positive half.
        W(startIdx:endIdx) = W(2:Nfft)+fnyq;
      end
      
      set(this,...
        'Data',Sxx,...
        'Frequencies',W);
      
      setspectrumtype(this,newSpectrumRange);
      
    end    
    
  end  %% public methods
  
end  % classdef

function spectype = set_spectrumrange(this,spectype)
%SETSPECTRUMRANGEPROP   Set function for the SpectrumRange property.

error(message('signal:dspdata:abstractfreqrespwspectrumrange:schema:settingPropertyNotAllowed', 'SpectrumRange', 'halfrange', 'wholerange', 'help dspdata/halfrange', 'help dspdata/wholerange'));
end  % set_spectrumrange


%--------------------------------------------------------------------------
function specrange = get_spectrumrange(this,spectype)
%GET_SpectrumRange   Return the value of the SpectrumRange property.

specrange = getspectrumtype(this);
end  % get_spectrumrange


% [EOF]
