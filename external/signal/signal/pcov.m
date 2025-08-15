function varargout = pcov(x,p,varargin)
%PCOV   Power Spectral Density (PSD) estimate via the Covariance method.
%   Pxx = PCOV(X,ORDER) returns the PSD estimate, Pxx, of the discrete-time
%   signal X.  When X is a vector, it is converted to a column vector and
%   treated as a single channel.  When X is a matrix, the PSD is computed
%   independently for each column and stored in the corresponding column of
%   Pxx.  Pxx is the distribution of power per unit frequency. The
%   frequency is expressed in units of radians/sample.  ORDER is the order
%   of the autoregressive (AR) model used to produce the PSD.
%
%   For real signals, PCOV returns the one-sided PSD by default; for 
%   complex signals, it returns the two-sided PSD.  Note that a one-sided 
%   PSD contains the total power of the input signal.
%
%   Pxx = PCOV(X,ORDER,NFFT) specifies the FFT length used to calculate the
%   PSD estimates.  For real X, Pxx has (NFFT/2+1) rows if NFFT is even,
%   and (NFFT+1)/2 rows if NFFT is odd.  For complex X, Pxx always has
%   NFFT rows.  If NFFT is specified as empty, NFFT is set to either 256
%   or the next power of two greater than the length X, whichever is
%   larger.
%
%   [Pxx,W] = PCOV(X,ORDER,NFFT) returns the vector of normalized angular
%   frequencies, W, at which the PSD is estimated.  W has units of 
%   radians/sample.  For real signals, W spans the interval [0,Pi] when 
%   NFFT is even and [0,Pi) when NFFT is odd.  For complex signals, W 
%   always spans the interval [0,2*Pi).  
%
%   [Pxx,W] = PCOV(X,ORDER,W) computes the two-sided PSD at the normalized
%   angular frequencies contained in vector W. W must have at least two
%   elements.
%
%   [Pxx,F] = PCOV(X,ORDER,NFFT,Fs) returns a PSD computed as a function of
%   physical frequency.  Fs is the sampling frequency specified in hertz.
%   If Fs is empty, it defaults to 1 Hz.
%
%   F is the vector of frequencies (in hertz) at which the PSD is
%   estimated.  For real signals, F spans the interval [0,Fs/2] when NFFT
%   is even and [0,Fs/2) when NFFT is odd.  For complex signals, F always
%   spans the interval [0,Fs).
%
%   [Pxx,F] = PCOV(X,ORDER,F,Fs) computes the two-sided PSD at the
%   frequencies contained in vector F. F must have at least two elements
%   and be expressed in hertz.
%
%   [...] = PCOV(...,FREQRANGE)  returns the PSD over the specified
%   range of frequencies based upon the value of FREQRANGE:
%
%      'onesided' - returns the one-sided PSD of a real input signal X.
%         If NFFT is even, Pxx has length NFFT/2+1 and is computed over the
%         interval [0,pi].  If NFFT is odd, Pxx has length (NFFT+1)/2 and
%         is computed over the interval [0,pi). When Fs is specified, the
%         intervals become [0,Fs/2] and [0,Fs/2) for even and odd NFFT,
%         respectively.
%
%      'twosided' - returns the two-sided PSD for either real or complex
%         input X.  Pxx has length NFFT and is computed over the interval
%         [0,2*Pi). When Fs is specified, the interval becomes [0,Fs).
%
%      'centered' - returns the centered two-sided PSD for either real or
%         complex X.  Pxx has length NFFT and is computed over the interval
%         (-pi, pi] for even length NFFT and (-pi, pi) for odd length NFFT.
%         When Fs is specified, the intervals become (-Fs/2, Fs/2] and
%         (-Fs/2, Fs/2) for even and odd length NFFT, respectively.
%
%      FREQRANGE may be placed in any position in the input argument list
%      after ORDER.  The default value of FREQRANGE is 'onesided' when X
%      is real and 'twosided' when X is complex.
%
%   [Pxx,F,Pxxc] = PCOV(...,'ConfidenceLevel',P) returns the P*100%
%   confidence interval for Pxx, where P is a scalar between 0 and 1. The
%   default value for P is .95.  Confidence intervals are computed using a
%   Gaussian PDF. Pxxc has twice as many columns as Pxx. Odd-numbered
%   columns contain the lower bounds of the confidence intervals;
%   even-numbered columns contain the upper bounds.  Thus, Pxxc(M,2*N-1) is
%   the lower bound and Pxxc(M,2*N) is the upper bound corresponding to the
%   estimate Pxx(M,N).
%
%   PCOV(...) with no output arguments plots the PSD estimate (in decibels
%   per unit frequency) in the current figure window.
%
%   EXAMPLE:
%      x = randn(100,1);
%      y = filter(1,[1 1/2 1/3 1/4 1/5],x);
%      pcov(y,4,[],1000);             % Uses the default NFFT of 256.
%
%   See also PMCOV, PYULEAR, PBURG, PMTM, PMUSIC, PEIG, PWELCH, PERIODOGRAM,
%   ARCOV, PRONY.

%   Copyright 1988-2019 The MathWorks, Inc.

narginchk(2,8)

if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Cast to enforce Precision Rules
p = signal.internal.sigcasttofloat(p,'double','pcov','ORDER','allownumeric');
% Checks if X is valid data
signal.internal.sigcheckfloattype(x,'','pcov','X');

method = @arcov;
% NFFT and Fs are cast to enforce precision rules in ARSPECTRA
[Pxx,freq,msg,units,~,options,msgobj] = arspectra(method,x,p,varargin{:});
if ~isempty(msg), error(msgobj); end

% compute confidence intervals if needed.
if ~strcmp(options.conflevel,'omitted')
  % arconfinterval enforces double precision arithmetic internally
  Pxxc = arconfinterval(options.conflevel, p, Pxx, x);
elseif nargout>2
  Pxxc = arconfinterval(0.95, p, Pxx, x);
else
  Pxxc = [];
end

if nargout==0
   % If no output arguments are specified plot the PSD.
   freq = {freq};
   if strcmpi(units,'Hz'), freq = [freq {'Fs',options.Fs}]; end
   hpsd = dspdata.psd(Pxx,freq{:},'SpectrumType',options.range);

   % Create a spectrum object to store in the PSD object's metadata.
   hspec = spectrum.cov(p);
   hpsd.Metadata.setsourcespectrum(hspec);
   
   % plot the confidence levels if conflevel is specified.
   if ~isempty(Pxxc)
       hpsd.ConfLevel = options.conflevel;
       hpsd.ConfInterval = Pxxc;
   end
   
   % center dc if needed
   if options.centerdc
     centerdc(hpsd);
   end

   plot(hpsd);

else
   % center dc if needed
   if options.centerdc
     [Pxx, freq, Pxxc] = signal.internal.spectral.psdcenterdc(Pxx, freq, Pxxc, options);
   end

   % If the input is a vector and a row frequency vector was specified,
   % return output as a row vector for backwards compatibility.
   if size(options.nfft,2)>1 && isvector(x)
     Pxx = Pxx.';
   end

   % Cast to enforce precision rules. Cast frequency only if outputs have
   % been requested, otherwise plot using double frequency vectors.
   if isa(Pxx,'single')
     freq = single(freq);
   end
   
   % Assign output arguments.
   varargout = {Pxx,freq,Pxxc};  % Pxx=PSD, Sxx=PS
end

% [EOF] pcov.m
