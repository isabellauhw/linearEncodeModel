classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) abstractfreqrespwspectrumtypeMCOS < dspdata.abstractfreqrespMCOS
  %dspdata.abstractfreqrespwspectrumtype class
  %   dspdata.abstractfreqrespwspectrumtype extends dspdata.abstractfreqresp.
  %
  %    dspdata.abstractfreqrespwspectrumtype properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumType - Property is of type 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
  %
  %    dspdata.abstractfreqrespwspectrumtype methods:
  %       computeresp4freqrange -   Compute the spectrum over the frequency range
  %       createoptsobj -   Creates a default options object for this class.
  %       getrangepropname -   Returns the property name for the range option.
  %       getspectrumtype -   Get the spectrumtype property value.
  %       getylabel - Get the ylabel.
  %       ishalfnyqinterval -   True if the spectrum was calculated for only half the
  %       onesided -   Convert a two-sided spectrum to a one-sided spectrum.
  %       setspectrumtype -   Set the spectrumtype.
  %       thiscenterdc -   Shift the zero-frequency component to center of spectrum.
  %       thisloadobj -   Load this object.
  %       twosided -   Convert a one-sided spectrum to a two-sided spectrum.
  %       validatespectrumtype -   Validate SpectrumType property value.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVSPECTRUMTYPE Property is of type 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
    privSpectrumType = 'OneSided';
  end
  
  properties (Transient, AbortSet, SetObservable, GetObservable)
    %SPECTRUMTYPE Property is of type 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
    SpectrumType = 'Onesided';
  end
  
  
  methods
    function value = get.SpectrumType(obj)
      value = get_spectrumtype(obj,obj.SpectrumType);
    end
    function set.SpectrumType(obj,value)
      % Enumerated DataType = 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
      value = validatestring(value,{'Onesided','Twosided'},'','SpectrumType');
      obj.SpectrumType = set_spectrumtype(obj,value);
    end
    
    function set.privSpectrumType(obj,value)
      % Enumerated DataType = 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
      value = validatestring(value,{'Onesided','Twosided'},'','privSpectrumType');
      obj.privSpectrumType = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function [H,W] = computeresp4freqrange(this,ishalfrange,ispsd,isnormalized,isDCcentered)
      %COMPUTERESP4FREQRANGE   Compute the spectrum over the frequency range
      %                        requested by the user.
 
      % Define a boolean flag representing the state of SpectrumType property.
      isonesided = ishalfnyqinterval(this);
      
      % Make sure that Fs, frequency, and NormalizedFrequency property are all
      % consistent.
      normalizefreq(this,logical(isnormalized));
      
      if ~ishalfrange && isonesided    % User requested 'twosided' but obj has 'onesided'
        twosided(this);
        
      elseif ishalfrange && ~isonesided % User requested 'onesided' but obj has 'twosided'
        onesided(this);
      end
      
      if isDCcentered
        centerdc(this);
      end
      
      H = this.Data;
      W = this.Frequencies;
      
      % Allow concrete classes to do further calculations if necessary.
      [H,W] = thiscomputeresp4freqrange(this,H,W,ispsd);
      
    end
    
    function hopts = createoptsobj(this)
      %CREATEOPTSOBJ   Creates a default options object for this class.
     
      hopts = dspopts.spectrum;
      
    end
    
    function rangepropname = getrangepropname(this)
      %GETRANGEPROPNAME   Returns the property name for the range option.
  
      rangepropname = 'SpectrumType';
      
    end
    
    
    function privspectrumtype = getspectrumtype(this)
      %GETSPECTRUMTYPE   Get the spectrumtype property value.
 
      privspectrumtype = this.privSpectrumType;
      
    end
    
    
    function ylbl = getylabel(this)
      %GETYLABEL Get the ylabel.
    
      if this.NormalizedFrequency
        ylbl = getString(message('signal:dspdata:dspdata:PowerfrequencydBradsample'));
      else
        ylbl = getString(message('signal:dspdata:dspdata:PowerfrequencydBHz'));
      end
      
    end
    
    
    function flag = ishalfnyqinterval(this)
      %ISHALFNYQINTERVAL   True if the spectrum was calculated for only half the
      %                    Nyquist interval.
   
      flag = false;
      if strcmpi(get(this,getrangepropname(this)),'onesided')
        flag = true;
      end
      
    end
    
    
    function onesided(this)
      %ONESIDED   Convert a two-sided spectrum to a one-sided spectrum.
    
      newSpectrumType = 'onesided';
      if strcmpi(this.SpectrumType,newSpectrumType)
        return;     % Spectrum already one-sided.
      end
      
      % Force data and frequencies to be in the range 0-Fs.
      centerdc(this,false);  % no-op if dc is not centered.
      
      Pxx = this.Data;
      W   = this.Frequencies;
      [nfft,nchans] = size(Pxx);
      
      % Convert a 'twosided' spectrum (and frequencies) to a 'onesided' spectrum.
      if rem(nfft,2)
        select = 1:(nfft+1)/2;                    % ODD;  take only [0,pi)
        Pxx = [Pxx(1,:); 2*Pxx(select(2:end),:)]; % Don't multiply DC term by 2.
      else
        select = 1:nfft/2+1;                      % EVEN; take only [0,pi]
        Pxx = [Pxx(1,:); 2*Pxx(select(2:end-1),:); Pxx(select(end),:)]; % Don't multiple DC & Nyquist by 2.
      end
      W = W(select);
      
      this.Data = Pxx;
      this.Frequencies = W;
      setspectrumtype(this,newSpectrumType);
      
    end
    
    
    function setspectrumtype(this, spectrumtype)
      %SETSPECTRUMTYPE   Set the spectrumtype.
   
      set(this,'privSpectrumType',spectrumtype);
      
    end
    
    function thiscenterdc(this)
      %THISCENTERDC   Shift the zero-frequency component to center of spectrum.
      
      % First convert to a spectrum that occupies the whole Nyquist interval.
      if ishalfnyqinterval(this)
        twosided(this);
      end
      
      if this.CenterDC
        % Center the DC component.
        spectrumshift(this);
      else
        % Move the DC component back to the left edge.
        ispectrumshift(this);
      end
      
    end
    
    
    function thisloadobj(this, s)
      %THISLOADOBJ   Load this object.
    
      set(this, 'privSpectrumType', s.SpectrumType);
      
    end
    
    
    function twosided(this)
      %TWOSIDED   Convert a one-sided spectrum to a two-sided spectrum.
  
      newSpectrumType = 'twosided';
      if strcmpi(this.SpectrumType,newSpectrumType)
        return;    % Spectrum already two-sided.
      end
      
      if this.NormalizedFrequency
        fnyq = pi;
      else
        fnyq = this.getfs/2;
      end
      
      Pxx = this.Data;
      W   = this.Frequencies;
      [Nfft,nchans] = size(Pxx);
      
      % Rebuild the 'twosided' PSD from the 'onesided' PSD.
      startIdx = Nfft+1;
      if isevenwholenfft(this,Nfft,W)      % EVEN "whole" NFFT
        endIdx = (Nfft-1)*2;
        Pxx(2:Nfft-1,:) = Pxx(2:Nfft-1,:)/2;
        Pxx(startIdx:endIdx,:) = Pxx(Nfft-1:-1:2,:);  % Add positive half.
        W(startIdx:endIdx) = W(2:Nfft-1)+fnyq;
        
      else                                  % ODD "whole" NFFT
        endIdx = (Nfft*2)-1;
        Pxx(2:Nfft,:) = Pxx(2:Nfft,:)/2;
        Pxx(startIdx:endIdx,:) = Pxx(Nfft:-1:2,:);    % Add positive half.
        W(startIdx:endIdx) = W(2:Nfft)+fnyq;
      end
      
      this.Data = Pxx;
      this.Frequencies = W;
      setspectrumtype(this,newSpectrumType); % Uses priv property to produce better error msg.
      
    end
    
    function validatespectrumtype(this,spectrumType)
      %VALIDATESPECTRUMTYPE   Validate SpectrumType property value.
      %
      % This error checking should be done in the object's set method, but for
      % enum datatypes UDD first checks the list before calling the set method.
  
      validStrs = {'onesided','twosided'};
      if ~ischar(spectrumType) | ~any(strcmpi(spectrumType,validStrs))
        error(message('signal:dspdata:abstractfreqrespwspectrumtype:validatespectrumtype:invalidSpectrumType', 'SpectrumType', validStrs{ 1 }, validStrs{ 2 }));
      end
      
    end
        
  end  %% public methods
  
end  % classdef

function spectype = set_spectrumtype(this,spectype)
%SETSPECTRUMTYPEPROP   Set function for the SpectrumType property.

error(message('signal:dspdata:abstractfreqrespwspectrumtype:schema:settingPropertyNotAllowed', 'SpectrumType', 'onesided', 'twosided', 'help dspdata/onesided', 'help dspdata/twosided'));
end  % set_spectrumtype


%--------------------------------------------------------------------------
function spectype = get_spectrumtype(this,spectype)
%GET_SPECTRUMTYPE   Return the value of the SpectrumType property.

spectype = getspectrumtype(this);
end  % get_spectrumtype

