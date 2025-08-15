classdef msspectrum < dspdata.abstractpsMCOS
  %dspdata.msspectrum class
  %   dspdata.msspectrum extends dspdata.abstractps.
  %
  %    dspdata.msspectrum properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumType - Property is of type 'SignalSpectrumTypeList enumeration: {'Onesided','Twosided'}'
  %       ConfLevel - Property is of type 'mxArray'
  %       ConfInterval - Property is of type 'twocol_nonneg_matrix user-defined'
  %
  %    dspdata.msspectrum methods:
  %       getrangepropname -   Returns the property name for the range option.
  %       getylabel - Get the ylabel.
  %       plotindb -   Returns true.
  %       responseobj -   Mean-square spectrum response object.
  %       sfdr - Spurious Free Dynamic Range.
  %       sfdropts - Creates an options object for SFDR method
  
  
  
  methods  % constructor block
    function this = msspectrum(varargin)
      %MSSPECTRUM   Mean-square spectrum.
      %
      %   DSPDATA.MSSPECTRUM is not recommended.
      %   Use <a href="matlab:help periodogram">periodogram</a> and <a href="matlab:help pwelch">pwelch</a> instead.
      %
      %   H = DSPDATA.MSSPECTRUM(DATA) instantiates an object H with its data
      %   property set to the mean-square spectrum specified in DATA. DATA
      %   represents power and therefore must contain real and positive values.
      %   DATA can be a vector or a matrix where each column represents an
      %   independent trial. A corresponding frequency vector is automatically
      %   generated in the range of [0, pi]. Fs defaults to "Normalized".
      %
      %   The mean-squared spectrum is intended for discrete spectra. Unlike the
      %   power spectral density (PSD), the peaks in the mean-square spectrum
      %   reflect the power in the signal at a given frequency.
      %
      %   H = DSPDATA.MSSPECTRUM(DATA,FREQUENCIES) sets the frequency vector to
      %   FREQUENCIES in the data object returned in H.  The length of the vector
      %   FREQUENCIES must equal the length of the columns of DATA.
      %
      %   H = DSPDATA.MSSPECTRUM(...,'Fs',Fs) sets the sampling frequency to Fs.
      %   If FREQUENCIES is not specified the frequency vector defaults to
      %   [0,Fs/2]. See the NOTE below for more details.
      %
      %   H = DSPDATA.MSSPECTRUM(...,'SpectrumType',SPECTRUMTYPE) sets the
      %   SpectrumType property to the string specified by SPECTRUMTYPE, which
      %   can be either 'onesided' or 'twosided'.
      %
      %   H = DSPDATA.MSSPECTRUM(...,'CenterDC',true) indicates that the Data's
      %   DC value is centered in the vector. Setting CenterDC to true
      %   automatically sets the 'SpectrumType' to 'twosided'.
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
      %   EXAMPLE: Use FFT to calculate mean-square spectrum of a noisy
      %            % sinusoidal signal with two frequency components. Then store
      %            % the results in an MSSPECTRUM data object and plot it.
      %
      %            Fs = 32e3;   t = 0:1/Fs:2.96;
      %            x = cos(2*pi*t*1.24e3) + cos(2*pi*t*10e3) + randn(size(t));
      %            X = fft(x);
      %            P = (abs(X)/length(x)).^2;    % Compute the mean-square.
      %
      %            hms = dspdata.msspectrum(P,'Fs',Fs,'SpectrumType','twosided');
      %            plot(hms);                    % Plot the mean-square spectrum.

      narginchk(0,12);
      
      % Create object and set the properties specific to this object.
      % this = dspdata.msspectrum;
      set(this,'Name','Mean-Square Spectrum');
      
      % Construct a metadata object.
      set(this,'Metadata',dspdata.powermetadataMCOS);
      set(this.Metadata,'FrequencyUnits','Hz');
      set(this.Metadata,'DataUnits','volts^2');
      
      % Initialize Data and Frequencies with defaults or user specified values.
      initialize(this,varargin{:});
      
      
    end  % msspectrum
    
  end  % constructor block
  
  methods  %% public methods
    function rangepropname = getrangepropname(this)
      %GETRANGEPROPNAME   Returns the property name for the range option.

      rangepropname = 'SpectrumType';
      
    end
    
    
    function ylabel = getylabel(this) %#ok<INUSD>
      %GETYLABEL Get the ylabel.

      ylabel = getString(message('signal:dspdata:dspdata:PowerdB'));
      % [EOF]
      
    end
    
    
    function b = plotindb(this)
      %PLOTINDB   Returns true.

      b = true;
      
    end
    
    
    function hresp = responseobj(this)
      %RESPONSEOBJ   Mean-square spectrum response object.
      %
      % This is a private method.
 
      % Create the response object.
      hresp = sigresp.msspectrumresp(this);
      
    end
    
    
    function [sfd,spur,frq] = sfdr(this,varargin)
      %SFDR Spurious Free Dynamic Range.
      %
      %   DSPDATA.MSSPECTRUM.SFDR is not recommended.  Use <a href="matlab:help sfdr">sfdr</a> instead.
      %
      %   SFD = SFDR(H) computes the spurious free dynamic range, in dB, of the
      %   DSPDATA.MSSPECTRUM object H.
      %
      %   [SFD,SPUR,FRQ]= SFDR(H) also returns the magnitude of the highest
      %   spur and the frequency FRQ at which it occurs.
      %
      %   [...] = SFDR(H,'MINSPURLEVEL',MSL) ignores spurs that are below the
      %   MINSPURLEVEL MSL. Specifying MSL level may help in reducing the
      %   processing time. MSL is a  real valued scalar specified in dB. The
      %   default value of MSL is -Inf.
      %
      %   [...] = SFDR(H,'MINSPURDISTANCE',MSD) considers only spurs that are at
      %   least separated by MINSPURDISTANCE MSD, to compute spurious free
      %   dynamic range. MSD is a real valued positive scalar specified in
      %   frequency units. This parameter may be specified to ignore spurs that
      %   may occur in close proximity to the carrier. For example, if the
      %   carrier frequency is Fc, then all spurs in the range (Fc-MSD, Fc+MSD)
      %   are ignored. If not specified, MSD is assigned a value equal to the
      %   minimum distance between two consecutive frequency points in the
      %   mean-square spectrum estimate.
      %
      %   EXAMPLE
      %      f1 = 0.5; f2 = 0.52; f3 = 0.9; f4 = 0.1; n = 0:255;
      %      x = 10*cos(pi*f1*n)' + 6*cos(pi*f2*n)' + 0.5*cos(pi*f3*n)' + ...
      %          + 0.5*cos(pi*f4*n)';
      %      H = spectrum.periodogram;
      %      h = msspectrum(H,x);
      %      [sfd, spur, freq] =  sfdr(h);
      %
      %      % To ignore peak at 0.52 rad/sample
      %      [sfd, spur, freq] =  sfdr(h,'MinSpurDistance',0.1);

      narginchk(1,5);
      
      hopts = uddpvparse('dspopts.sfdr',{'sfdropts',this},varargin{:});
      
      ML = hopts.MinSpurLevel;
      ML = 10^(ML/10);
      MD = hopts.MinSpurDistance;
      
      F = this.Frequencies;
      
      clear actError;
      
      exp_id1 = 'signal:dspdata:abstractps:findpeaks:largePeakDistance';
      exp_id2 = 'signal:findpeaks:largeMinPeakHeight';
      
      try
        warning('off','signal:findpeaks:noPeaks');
        [pks,frqs] = findpeaks(this,'MinPeakHeight',ML,'MinPeakDistance',MD);
      catch actError
        warning('on','signal:findpeaks:noPeaks');
        act_id = actError.identifier;
        if(strcmp(act_id,exp_id1))
          error(message('signal:dspdata:msspectrum:sfdr:largeSpurDistance', 'MinSpurDistance', num2str( (max( F ) - min( F )) )));
        elseif(strcmp(act_id,exp_id2))
          error(message('signal:dspdata:msspectrum:sfdr:largeSpurLevel', 'MinSpurLevel', 'MinSpurLevel'))
        else
          rethrow(actError);
        end
      end
      warning('on','signal:findpeaks:noPeaks');
      
      if(length(pks) <= 1)
        error(message('signal:dspdata:msspectrum:sfdr:noSpurs', 'MinSpurLevel', 'MinSpurDistance'));
      else
        carrierIdx = find(pks==max(pks));
        carrier    = pks(carrierIdx);
        carrierdB  = db(carrier,'power');
        pks(carrierIdx) = 0;
        
        highestspurIdx = find(pks==max(pks));
        spurdB = db(pks(highestspurIdx),'power');
        
        sfd = carrierdB-spurdB;
        if nargout > 1
          spur = db(pks(highestspurIdx),'power');
          frq = frqs(highestspurIdx);
        end
      end
      
    end
    
    
    function  hopts = sfdropts(this)
      %SFDROPTS Creates an options object for SFDR method

      % Construct default opts object
      hopts = dspopts.sfdr;
      
    end
    
  end  %% public methods
  
end  % classdef

