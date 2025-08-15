classdef psdMCOS < dspdata.abstractpsMCOS
  %dspdata.psd class
  %   dspdata.psd extends dspdata.abstractps.
  %
  %    dspdata.psd properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumType - Property is of type 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
  %       ConfLevel - Property is of type 'mxArray'
  %       ConfInterval - Property is of type 'twocol_nonneg_matrix user-defined'
  %
  %    dspdata.psd methods:
  %       avgpower -    Average power.
  %       getrangepropname -   Returns the property name for the range option.
  %       isdensity -   Return true if object contains a PSD.
  %       plotindb -   Returns true.
  %       responseobj -   Powerresp response object.
  %       thiscomputeresp4freqrange -   Compute the PSD over the frequency range
  %       thisnormalizefreq -   Normalize/un-normalize the frequency of the data object.
  
  
  
  methods  % constructor block
    function this = psdMCOS(varargin)
      %PSD   Power Spectral Density (PSD).
      %
      %   DSPDATA.PSD is not recommended.  Use the following functions instead:
      %      <a href="matlab:help periodogram">periodogram</a>
      %      <a href="matlab:help pwelch">pwelch</a>
      %      <a href="matlab:help pburg">pburg</a>
      %      <a href="matlab:help pcov">pcov</a>
      %      <a href="matlab:help pmcov">pmcov</a>
      %      <a href="matlab:help pyulear">pyulear</a>
      %      <a href="matlab:help pmtm">pmtm</a>
      %
      %   H = DSPDATA.PSD(DATA) instantiates a data object H with its data
      %   property set to DATA. DATA represents power and therefore must contain
      %   real and positive values. DATA can be a vector or a matrix where each
      %   column represents an independent trial. A corresponding frequency
      %   vector is automatically generated in the range of [0, pi]. Fs
      %   defaults to "Normalized".
      %
      %   The power spectral density is intended for continuous spectra. Note
      %   that unlike the mean-squared spectrum (MSS), in this case the peaks in
      %   the spectra do not reflect the power at a given frequency. Instead,
      %   the integral of the PSD over a given frequency band computes the
      %   average power in the signal over such frequency band. See the help on
      %   AVGPOWER for more information.
      %
      %   H = DSPDATA.PSD(DATA,FREQUENCIES) sets the frequency vector to
      %   FREQUENCIES in the data object returned in H.  The length of the vector
      %   FREQUENCIES must equal the length of the columns of DATA.
      %
      %   H = DSPDATA.PSD(...,'Fs',Fs) sets the sampling frequency to Fs.  If
      %   FREQUENCIES is not specified the frequency vector defaults to [0,Fs/2].
      %   See the NOTE below for more details.
      %
      %   H = DSPDATA.PSD(...,'SpectrumType',SPECTRUMTYPE) sets the SpectrumType
      %   property to the string specified by SPECTRUMTYPE, which can be either
      %   'onesided' or 'twosided'.
      %
      %   H = DSPDATA.PSD(...,'CenterDC',true) indicates that the Data's DC value
      %   is centered in the vector. Setting CenterDC to true automatically sets
      %   the 'SpectrumType' to 'twosided'.
      %
      %   If no frequency vector is specified the default frequency vector is
      %   generated according to the setting of 'CenterDC'.  If a frequency
      %   vector is specified then 'CenterDC' should be set to match the
      %   frequency vector (and data) specified.  To modify this property use the
      %   <a href="matlab:help dspdata/centerdc">centerdc</a> method.
      %
      %   NOTE: If the spectrum data specified was calculated over "half" the
      %   Nyquist interval and you don't specify a corresponding frequency
      %   vector, then the default frequency vector will assume that the number
      %   of points in the "whole" FFT was even.  Also, the plot option to
      %   convert to a "whole" spectrum will assume the original "whole" FFT
      %   length was even.
      %
      %   EXAMPLE: Use the periodogram to estimate the power spectral density of
      %            % a noisy sinusoidal signal with two frequency components. Then
      %            % store the results in PSD data object and plot it.
      %
      %            Fs = 32e3;   t = 0:1/Fs:2.96;
      %            x = cos(2*pi*t*1.24e3)+ cos(2*pi*t*10e3)+ randn(size(t));
      %            Pxx = periodogram(x);
      %            hpsd = dspdata.psd(Pxx,'Fs',Fs); % Create a PSD data object.
      %            plot(hpsd);                      % Plot the PSD.
      
      %   Author(s): P. Pacheco
      
      narginchk(0,12);
      
      % Create object and set the properties specific to this object.
      % this = dspdata.psd;
      set(this,'Name','Power Spectral Density');
      
      % Construct a metadata object.
      set(this,'Metadata',dspdata.powermetadataMCOS);
      set(this.Metadata,...
        'FrequencyUnits','Hz',...
        'DataUnits','volts^2/Hz');
      
      % Initialize Data and Frequencies with defaults or user specified values.
      initialize(this,varargin{:});
      
      
    end  % psd
    
  end  % constructor block
  
  methods  %% public methods
    function pwr = avgpower(this,freqrange)
      %AVGPOWER    Average power.
      %
      %   AVGPOWER is not recommended.
      %   Use <a href="matlab:help bandpower">bandpower</a> instead.
      
      %   Author(s): P. Pacheco
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      narginchk(1,2);
      
      % Get the spectrum and frequencies.
      Pxx = this.Data;
      W   = this.Frequencies;
      
      freqrangespecified = false;
      if nargin < 2
        freqrange = [W(1) W(end)];
      else
        if ischar(freqrange) || length(freqrange)~=2 || freqrange(1)<W(1) ||...
            freqrange(2)>W(end)
          error(message('signal:dspdata:psd:avgpower:invalidFrequencyRangeVector', 'FREQRANGE'));
        end
        freqrangespecified = true;
      end
      
      % Find indices of freq range requested.
      idx1 = find(W<=freqrange(1), 1, 'last');
      idx2 = find(W>=freqrange(2), 1);
      
      % Determine the width of the rectangle used to approximate the integral.
      width = diff(W);
      if freqrangespecified
        lastRectWidth = 0;  % Don't include last point of PSD data.
        width = [width; lastRectWidth];
      else
        % Make sure we include Nyquist and the last point before Fs.
        if strcmpi(this.SpectrumType,'onesided')
          % Include whole bin width.
          lastRectWidth = width(end);        % Assumes uniform data.
          width = [width; lastRectWidth];
        else
          % There are two cases when spectrum is twosided, CenterDC or not.
          % In both cases, the frequency samples does not cover the entire
          % 2*pi (or Fs) region due to the periodicity.  Therefore, the
          % missing freq range has to be compensated in the integral.  The
          % missing freq range can be calculated as the difference between
          % 2*pi (or Fs) and the actual frequency vector span.  For example,
          % considering 1024 points over 2*pi, then frequency vector will be
          % [0 2*pi*(1-1/1024)], i.e., the missing freq range is 2*pi/1024.
          %
          % When CenterDC is true, if the number of points is even, the
          % Nyquist point (Fs/2) is exact, therefore, the missing range is at
          % the left side, i.e., the beginning of the vector.  If the number
          % of points is odd, then the missing freq range is at both ends.
          % However, due to the symmetry of the real signal spectrum, it can
          % still be considered as if it is missing at the beginning of the
          % vector.  Even when the spectrum is asymmetric, since the
          % approximation of the integral is close when NFFT is large,
          % putting it in the beginning of the vector is still ok.
          %
          % When CenterDC is false, the missing range is always at the end of
          % the frequency vector since the frequency always starts at 0.
          if this.NormalizedFrequency
            Fs = 2*pi;
          else
            Fs = getfs(this);
          end
          
          missingWidth = Fs - (W(end)-W(1));
          
          
          if this.CenterDC
            width = [missingWidth; width];
          else
            width = [width; missingWidth];
          end
        end
      end
      
      % Sum the average power over the range of interest.
      pwr = width(idx1:idx2)'*Pxx(idx1:idx2,:);
      
    end
    
    function rangepropname = getrangepropname(this)
      %GETRANGEPROPNAME   Returns the property name for the range option.
      
      rangepropname = 'SpectrumType';
      
    end
    
    function isden = isdensity(this)
      %ISDENSITY   Return true if object contains a PSD.
      
      isden = true;
      
    end
    
    
    function b = plotindb(this)
      %PLOTINDB   Returns true.
      
      b = true;
      
    end
    
    
    function hresp = responseobj(this)
      %RESPONSEOBJ   Powerresp response object.
      %
      % This is a private method.
      
      % Create the response object.
      hresp = sigresp.powerresp(this);
      
    end
    
    
    function [H,W] = thiscomputeresp4freqrange(this,H,W,isdensity)
      %THISCOMPUTERESP4FREQRANGE   Compute the PSD over the frequency range
      %                            requested by the user.
      
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
    
    
    function thisnormalizefreq(this,oldFs,newFsFlag)
      %THISNORMALIZEFREQ   Normalize/un-normalize the frequency of the data object.
      
      % Scale the data by the appropriate value, either Fs, oldFs, or 2pi.
      Fs = getprivfs(this);
      if this.NormalizedFrequency
        scaleFactor = oldFs/(2*pi);
      else
        if newFsFlag  % Catch case of repeated calls with new Fs.
          scaleFactor = oldFs/Fs;
        else
          scaleFactor = (2*pi)/Fs;
        end
      end
      this.Data = this.Data*scaleFactor;
      
    end
    
    
  end  %% public methods
  
end  % classdef

