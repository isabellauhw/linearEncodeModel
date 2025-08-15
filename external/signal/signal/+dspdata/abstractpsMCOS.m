classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, Abstract) abstractpsMCOS < dspdata.abstractfreqrespwspectrumtypeMCOS
  %dspdata.abstractps class
  %   dspdata.abstractps extends dspdata.abstractfreqrespwspectrumtype.
  %
  %    dspdata.abstractps properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumType - Property is of type 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
  %       ConfLevel - Property is of type 'mxArray'
  %       ConfInterval - Property is of type 'twocol_nonneg_matrix user-defined'
  %
  %    dspdata.abstractps methods:
  %       convert2db -   Convert input response to db values.
  %       findpeaks - Find local peaks in data
  %       findpeaksopts - Creates an options object for FINDPEAKS method
  %       getspectrumtype -   Get the spectrumtype property value.
  %       spectrumshift -   Shift zero-frequency component to center of spectrum.
  %       thiscomputeresp4freqrange -   Compute the spectrum over the frequency range
  %       twosided -   Convert a one-sided spectrum to a two-sided spectrum.
  %       validatedata -   Validate the data for this object.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %CONFLEVEL Property is of type 'mxArray'
    ConfLevel = [];
    %CONFINTERVAL Property is of type 'twocol_nonneg_matrix user-defined'
    ConfInterval = [];
  end
  
  
  methods
    function set.ConfLevel(obj,value)
      obj.ConfLevel = value;
    end
    
    function set.ConfInterval(obj,value)
      % User-defined DataType = 'twocol_nonneg_matrix user-defined'
      obj.ConfInterval = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function HdB = convert2db(this,H)
      %CONVERT2DB   Convert input response to db values.
      
      %   Author(s): P. Pacheco
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      ws = warning; % Cache warning state
      warning off   % Avoid "Log of zero" warnings
      HdB = db(H,'power');  % Call the Convert to decibels engine
      warning(ws);  % Reset warning state
      
    end
    
    
    function [pks,frqs] = findpeaks(this,varargin)
      %FINDPEAKS Find local peaks in data
      %   PKS = FINDPEAKS(H) finds local peaks in data contained in the DSPDATA
      %   object H.
      %
      %   [PKS,FRQS]= FINDPEAKS(H) also returns the frequencies FRQS at which the
      %   PKS occur.
      %
      %   [...] = FINDPEAKS(H,'MINPEAKHEIGHT',MPH) finds only those peaks that
      %   are greater than MINPEAKHEIGHT MPH. Specifying MPH may help in reducing
      %   the processing time. MPH is a real valued scalar. The default value of
      %   MPH is -Inf.
      %
      %   [...] = FINDPEAKS(H,'MINPEAKDISTANCE',MPD) finds peaks that are at
      %   least separated by MINPEAKDISTANCE MPD. MPD is a real valued positive
      %   scalar specified in frequency units. This parameter may be specified to
      %   ignore smaller peaks that may occur in close proximity to a large local
      %   peak. For example, if a large local peak occurs at frequency Fp, then
      %   all smaller peaks in the range (Fp-MPD, Fp+MPD) are ignored. If not
      %   specified, MPD is assigned a value equal to the minimum distance
      %   between two consecutive frequency points in the spectrum estimate.
      %
      %   [...] = FINDPEAKS(H,'THRESHOLD',TH) finds peaks that are at least
      %   greater than their neighbhors by the THRESHOLD TH. TH is real valued
      %   scalar greater than or equal to zero. The default value of TH is zero.
      %
      %   [...] = FINDPEAKS(X,'NPEAKS',NP) specifies the maximum number of peaks
      %   to be found. NP is an integer greater than zero. If not specified, all
      %   peaks are returned.
      %
      %   [...] = FINDPEAKS(H,'SORTSTR',STR) specifies the direction of sorting
      %   of peaks. STR can take values of 'ascend','descend' or 'none'. If not
      %   specified, STR takes the value of 'none' and the peaks are returned in
      %   the order of their occurrence.
      %
      %   EXAMPLE
      %      f1  = 0.5; f2 = 0.52; f3 = 0.9; f4 = 0.1; n = 0:255;
      %      x   = 10*cos(pi*f1*n)'+ 6*cos(pi*f2*n)'+ 0.5*cos(pi*f3*n)'+ ...
      %            + 0.5*cos(pi*f4*n)';
      %      H   = spectrum.periodogram;
      %      h   = msspectrum(H,x);
      %      pks = findpeaks(h);
      %
      %      % To ignore peaks below 0.1
      %      [pks, frqs] = findpeaks(h,'MinPeakHeight',0.1);
      %
      %   See also DSPDATA/SFDR, FINDPEAKS
      
      narginchk(1,11);
      
      if nargin > 1
          [varargin{:}] = convertStringsToChars(varargin{:});
      end

      hopts = uddpvparse('dspopts.findpeaks',{'findpeaksopts',this},varargin{:});
      
      TH  = hopts.Threshold;
      PD  = hopts.MinPeakDistance;
      PH  = hopts.MinPeakHeight;
      NP  = hopts.NPeaks;
      STR = hopts.SortStr;
      
      Data = this.Data;
      F = this.Frequencies;
      K = length(F);
      
      % Find equivalent of MinPeakDistance PD in terms of number of data points.
      % This conversion is required since the findpeaks function, which is called
      % upon later, requires MinPeakDistance in terms of number of data points
      % (integer).
      S = round(K*PD/(max(F)-min(F)));
      
      % Setting S = 1 (minimum value allowed) if S < 1
      if(isempty(S)) || (S < 1)
        S = 1;
      end
      
      if(K<=S)
        error(message('signal:dspdata:abstractps:findpeaks:largePeakDistance', 'MinPeakDistance', num2str( (max( F ) - min( F )) )));
      else
        [pks,locs] = findpeaks(Data,'MinPeakHeight',PH,'MinPeakDistance',S,...
          'Threshold',TH,'NPeaks',NP,'SortStr',STR);
        frqs = F(locs);
      end
      
    end
    
    
    function hopts = findpeaksopts(this)
      %FINDPEAKSOPTS Creates an options object for FINDPEAKS method
      
      hopts = dspopts.findpeaks;
      
    end
    
    function privspectrumtype = getspectrumtype(this)
      %GETSPECTRUMTYPE   Get the spectrumtype property value.
      
      privspectrumtype = this.privSpectrumType;
      
    end
    
    function [H,W] = spectrumshift(this,H,W)
      %SPECTRUMSHIFT   Shift zero-frequency component to center of spectrum.
      
      if nargin == 1
        H = this.Data;
        W = this.Frequencies;
        CI = this.ConfInterval;
      else
        CI = [];
      end
      
      % Convert to plot + and - frequencies.
      H = fftshift(H,1);  % Places the Nyquist freq on the negative side.
      
      if ~isempty(CI)
        for i=1:size(CI,2)
          CI(:,i) = fftshift(CI(:,i),1);
        end
      end
      
      [nfft,~] = size(H);
      
      % Determine half the number of FFT points.
      if rem(nfft,2)
        halfNfft = (nfft+1)/2;  % ODD
        negEndPt = halfNfft;
        
      else
        halfNfft = (nfft/2)+1;  % EVEN
        negEndPt = halfNfft-1;
        
        % Move the Nyquist point to the right-hand side (pos freq) to be
        % consistent with plot when looking at the positive half only.
        H = [H(2:end,:); H(1,:)];
        if ~isempty(CI)
          CI = [CI(2:end,:); CI(1,:)];
        end
      end
      
      W = [-flipud(W(2:negEndPt)); W(1:halfNfft)]; % -Nyquist:Nyquist
      
      if nargout == 0
        this.Data = H;
        this.Frequencies = W;
        if ~isempty(CI)
          this.ConfInterval = CI;
        end
      end
      
    end
    
    
    function [H,W] = thiscomputeresp4freqrange(this,H,W,ispsd)
      %THISCOMPUTERESP4FREQRANGE   Compute the spectrum over the frequency range
      %                            requested by the user.
      % Private method.
      
      % NO OP
      
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
      CI  = this.ConfInterval;
      [Nfft,~] = size(Pxx);
      
      % Rebuild the 'twosided' PSD from the 'onesided' PSD.
      startIdx = Nfft+1;
      if isevenwholenfft(this,Nfft,W)      % EVEN "whole" NFFT
        endIdx = (Nfft-1)*2;
        Pxx(2:Nfft-1,:) = Pxx(2:Nfft-1,:)/2;
        Pxx(startIdx:endIdx,:) = Pxx(Nfft-1:-1:2,:);  % Add positive half.
        W(startIdx:endIdx) = W(2:Nfft-1)+fnyq;
        if ~isempty(CI)
          CI(2:Nfft-1,:) = CI(2:Nfft-1,:)/2;
          CI(startIdx:endIdx,:) = CI(Nfft-1:-1:2,:);
        end
      else                                  % ODD "whole" NFFT
        endIdx = (Nfft*2)-1;
        Pxx(2:Nfft,:) = Pxx(2:Nfft,:)/2;
        Pxx(startIdx:endIdx,:) = Pxx(Nfft:-1:2,:);    % Add positive half.
        W(startIdx:endIdx) = W(2:Nfft)+fnyq;
        if ~isempty(CI)
          CI(2:Nfft,:) = CI(2:Nfft,:)/2;
          CI(startIdx:endIdx,:) = CI(Nfft:-1:2,:);    % Add positive half.
        end
      end
      
      this.Data = Pxx;
      this.Frequencies = W;
      this.ConfInterval = CI;
      setspectrumtype(this,newSpectrumType); % Uses priv property to produce better error msg.
      
    end
    
    function validatedata(this, data)
      %VALIDATEDATA   Validate the data for this object.
      
      % Call "private" function (using a trick) which is also used by pseudospectrum.
      dspdata.validatedata(this,data);
      
    end
    
  end  %% public methods
  
end  % classdef

