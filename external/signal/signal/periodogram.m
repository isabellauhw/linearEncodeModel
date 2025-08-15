function [Px,w,Px0,wc1] = periodogram(x1,varargin)
%PERIODOGRAM  Power Spectral Density (PSD) estimate via periodogram method.
%   Pxx = PERIODOGRAM(X) returns the PSD estimate, Pxx, of a signal, X.
%   When X is a vector, it is converted to a column vector and treated as a
%   single channel.  When X is a matrix, the PSD is computed independently
%   for each column and stored in the corresponding column of Pxx.
%  
%   By default, the signal X is windowed with a rectangular window of the
%   same length as X. The PSD estimate is computed using an FFT of length
%   given by the larger of 256 and the next power of 2 greater than the
%   length of X.
%
%   Note that the default window (rectangular) has a 13.3 dB sidelobe
%   attenuation. This may mask spectral content below this value (relative
%   to the peak spectral content). Choosing different windows will enable
%   you to make tradeoffs between resolution (e.g., using a rectangular
%   window) and sidelobe attenuation (e.g., using a Hann window). See
%   windowDesigner for more details.
%
%   Pxx is the distribution of power per unit frequency. For real signals,
%   PERIODOGRAM returns the one-sided PSD by default; for complex signals,
%   it returns the two-sided PSD.  Note that a one-sided PSD contains the
%   total power of the input signal.
%
%   Pxx = PERIODOGRAM(X,WINDOW) specifies a window to be applied to X. If X
%   is a vector, WINDOW must be a vector of the same length as X.  If X is
%   a matrix, WINDOW must be a vector whose length is the same as the
%   number of rows of X.  If WINDOW is a window other than a rectangular,
%   the resulting estimate is a modified periodogram. If WINDOW is
%   specified as empty, the default window is used.
%
%   Pxx = PERIODOGRAM(X,WINDOW,...,SPECTRUMTYPE) uses the window scaling
%   algorithm specified by SPECTRUMTYPE when computing the power spectrum:
%     'psd'   - returns the power spectral density
%     'power' - scales each estimate of the PSD by the equivalent noise
%               bandwidth (in Hz) of the window.  Use this option to
%               obtain an estimate of the power at each frequency.
%   The default value for SPECTRUMTYPE is 'psd'
%
%   [Pxx,W] = PERIODOGRAM(X,WINDOW,NFFT) specifies the number of FFT points
%   used to calculate the PSD estimate.  For real X, Pxx has length
%   (NFFT/2+1) if NFFT is even, and (NFFT+1)/2 if NFFT is odd.  For complex
%   X, Pxx always has length NFFT.  If NFFT is specified as empty, the
%   default NFFT is used.
%
%   Note that if NFFT is greater than the length of WINDOW, the data is
%   zero-padded. If NFFT is less than the length of WINDOW, the segment is
%   "wrapped" (using DATAWRAP) to make the length equal to NFFT to produce
%   the correct FFT.
%
%   W is the vector of normalized frequencies at which the PSD is
%   estimated.  W has units of radians/sample.  For real signals, W spans
%   the interval [0,pi] when NFFT is even and [0,pi) when NFFT is odd.  For
%   complex signals, W always spans the interval [0,2*pi).
%
%   [Pxx,W] = PERIODOGRAM(X,WINDOW,W) computes the two-sided PSD at the
%   normalized angular frequencies contained in the vector W. W must have
%   at least two elements.
%
%   [Pxx,F] = PERIODOGRAM(X,WINDOW,NFFT,Fs) returns a PSD computed as
%   a function of physical frequency.  Fs is the sampling frequency
%   specified in hertz.  If Fs is empty, it defaults to 1 Hz.
%
%   F is the vector of frequencies (in hertz) at which the PSD is
%   estimated.  For real signals, F spans the interval [0,Fs/2] when NFFT
%   is even and [0,Fs/2) when NFFT is odd.  For complex signals, F always
%   spans the interval [0,Fs).
%
%   [Pxx,F] = PERIODOGRAM(X,WINDOW,F,Fs) computes the two-sided PSD at the 
%   frequencies contained in vector F. F must contain at least two elements
%   and be expressed in units of hertz.
%
%   [...] = PERIODOGRAM(X,WINDOW,NFFT,...,FREQRANGE) returns the PSD
%   over the specified range of frequencies based upon the value of
%   FREQRANGE:
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
%         [0,2*pi). When Fs is specified, the interval becomes [0,Fs).
%
%      'centered' - returns the centered two-sided PSD for either real or
%         complex X.  Pxx has length NFFT and is computed over the interval
%         (-pi, pi] for even length NFFT and (-pi, pi) for odd length NFFT.
%         When Fs is specified, the intervals become (-Fs/2, Fs/2] and
%         (-Fs/2, Fs/2) for even and odd NFFT, respectively.
%
%      FREQRANGE may be placed in any position in the input argument list
%      after WINDOW.  The default value of FREQRANGE is 'onesided' when X
%      is real and 'twosided' when X is complex.
%
%   [Pxx,F,Pxxc] = PERIODOGRAM(...,'ConfidenceLevel',P) , where P is a
%   scalar between 0 and 1, returns the P*100% confidence interval for Pxx.
%   The default value for P is .95.  Confidence intervals are computed
%   using a chi-squared approach.  Pxxc has twice as many columns as Pxx.
%   Odd-numbered columns contain the lower bounds of the confidence
%   intervals; even-numbered columns contain the upper bounds.  Thus,
%   Pxxc(M,2*N-1) is the lower bound and Pxxc(M,2*N) is the upper bound
%   corresponding to the estimate Pxx(M,N).
%   
%   [RPxx,F] = PERIODOGRAM(X,WINDOW,...,'reassigned') reassigns each PSD
%   estimate to the nearest frequency in F corresponding to the estimate's
%   center of gravity.  The reassigned estimates are summed together and
%   returned in RPxx.  If WINDOW is unspecified or an empty matrix, then a
%   Kaiser window will be used as the default window.
%
%   [RPxx,F,Pxx,Fc] = PERIODOGRAM(...,'reassigned') additionally returns
%   the original PSD estimates, Pxx, and their corresponding center 
%   frequencies, Fc. Note that the 'ConfidenceLevel' option cannot be used
%   in conjunction with reassignment.
%
%   PERIODOGRAM(...) with no output arguments by default plots the PSD
%   estimate (in decibels per unit frequency) in the current figure window.
%
%   % Example 1:
%   %    Compute the two-sided periodogram of a 200 Hz sinusoid embedded
%   %    in noise.
%   Fs = 1000;   t = 0:1/Fs:.3;
%   x = cos(2*pi*t*200)+randn(size(t));
%   periodogram(x,[],'twosided',512,Fs)
% 
%   % Example 2:
%   %   Compute the one-sided reassigned periodogram of a 200 Hz sinusoid 
%   %   embedded in noise.
%   Fs = 1000;   t = 0:1/Fs:.3;
%   x = cos(2*pi*t*200)+0.001*randn(size(t));
%   periodogram(x,[],512,Fs,'power','reassigned')
%
%   See also PWELCH, PBURG, PCOV, PYULEAR, PMTM, PMUSIC, PMCOV, PEIG.

%   Copyright 1988-2020 The MathWorks, Inc.
%#codegen

narginchk(1,10);

inputArgs = cell(size(varargin));

if nargin > 1
    [inputArgs{:}] = convertStringsToChars(varargin{:});
else
    inputArgs = varargin;
end

cond = (~coder.target('MATLAB') && nargout==0);
coder.internal.errorIf(cond,'signal:periodogram:CodegenNotEnoughOutputs');

% look for psd, power, and ms window compensation flags
[esttype, args]= signal.internal.psdesttype({'psd','power','ms'},'psd',inputArgs);

if isvector(x1)
    N = length(x1); % Record the length of the data
else
    N = size(x1,1);
end

% extract window argument
if ~isempty(args) && ~ischar(args{1})
    win1 = args{1};
    args1 = {args{2:end}};
else
    win1 = [];
    args1 = args;
end

% scan for options
options = periodogram_options(isreal(x1),N,args1{:});

if ~options.reassign
    if nargout>3
        coder.internal.error('MATLAB:nargoutchk:tooManyOutputs');
    end
end

% Generate a default window if needed
%   default window is rectangular of same size as input.
%   if 'reassigned' is specified, then a Kaiser window is used instead
if coder.target('MATLAB')
    winName = 'User Defined';
    winParam = '';
end
if isempty(win1)
    if options.reassign
        win2 = kaiser(N,38);
    else
        win2 = rectwin(N);
        if coder.target('MATLAB')
            winName = 'Rectangular';
            winParam = N;
        end
    end
else
    win2 = win1;
end

% Cast to enforce precision rules
if any([signal.internal.sigcheckfloattype(x1,'single','periodogram','X')...
    signal.internal.sigcheckfloattype(win2,'single','periodogram','WINDOW')]) 
  x = single(x1);
  win = single(win2);
else
   x= x1;
   win = win2;
end

Fs    = options.Fs;
nfft  = options.nfft;

% Compute the PS using periodogram over the whole Nyquist range.
[Sxx,w2,RSxx,wc] = computeperiodogram(x,win,nfft,esttype,Fs,options);

% If frequency vector was specified, return and plot two-sided PSD
if length(nfft) > 1 && strcmpi(options.range,'onesided')
        coder.internal.warning('signal:periodogram:InconsistentRangeOption');
        options.range = 'twosided';
end

% compute reassigned spectrum if needed.
if options.reassign
    RPxx = computepsd(RSxx,w2,options.range,nfft,Fs,esttype);
    % Compute the one-sided corrected frequency vector for each component
    % of input signal
    wc = makeOnesidedWc(options.range,wc,nfft);
    % de-alias
    wc = dealiasWc(options,wc);
else
    RPxx = cast([],'like',RSxx);
    wc = [];
end

% Compute the 1-sided or 2-sided PSD [Power/freq] or mean-square [Power].
% Also, compute the corresponding freq vector & freq units.
[Pxx,w2,units] = computepsd(Sxx,w2,options.range,nfft,Fs,esttype);


% compute confidence intervals if needed.
if ~isnan(options.conflevel)
    Pxxc = signal.internal.spectral.confInterval(options.conflevel, Pxx, isreal(x), w2, options.Fs, 1);
elseif nargout>2 && ~options.reassign
    Pxxc = signal.internal.spectral.confInterval(0.95, Pxx, isreal(x), w2, options.Fs, 1);
else
    Pxxc = cast([],'like',Pxx);
end

if nargout==0 % Plot when no output arguments are specified
    signal.internal.spectral.plotPeriodogram(Pxx,w2,Pxxc,RPxx,options,esttype,units,winName,winParam);
else
    if options.centerdc
        if options.reassign
            RPxx1 = signal.internal.spectral.psdcenterdc(RPxx, w2, [], options);
            wc = centerWc(options,wc);
        else
            RPxx1= RPxx;
        end
        [Pxx1, w1, Pxxc] = signal.internal.spectral.psdcenterdc(Pxx, w2, Pxxc, options);
    else
        Pxx1 = Pxx;
        w1= w2;
        RPxx1= RPxx;
    end
    
    % assign outputs in correct order
    if options.reassign
        % first and third output are reassigned and unnormalized power
        Px1 = RPxx1;
        Px0 = Pxx1;
    else
        % first and third output are normalized power and confidence
        % intervals
        Px1 = Pxx1;
        Px0 = Pxxc;
    end
    
    % If the input is a vector and a row frequency vector was specified,
    % return output as a row vector for backwards compatibility.
    if size(options.nfft,2)>1 && isvector(x)
        Px = real(Px1.');                  % coder inference: power will always be real
        w3 = w1.';
        if options.reassign
            Px0 = Px0.';
            wc = wc.';
        end
    else
        Px = real(Px1);
        w3=w1;
    end
    
    % Cast to enforce precision rules
    % Only case if output is requested, otherwise plot using double
    % precision frequency vector.
    if isa(Px,'single')
        w = single(w3);
        if options.reassign
            wc1 = single(wc);
        else
            wc1 = cast([],'like',Px);
        end
    else
        w=w3;
        if options.reassign
            wc1=wc;
        else
            wc1=[];
        end
    end
end

end

%------------------------------------------------------------------------------
function options = periodogram_options(isreal_x,N,varargin)
%PERIODOGRAM_OPTIONS   Parse the optional inputs to the PERIODOGRAM function.
%   PERIODOGRAM_OPTIONS returns a structure, OPTIONS, with following fields:
%
%   options.nfft         - number of freq. points at which the psd is estimated
%   options.Fs           - sampling freq. if any
%   options.range        - 'onesided' or 'twosided' psd
%   options.centerdc     - true if 'centered' specified

% Generate defaults
sizeNFFT = [1 1];
for i=1:length(varargin)
    if ~ischar(varargin{i})
        sizeNFFT = size(varargin{i});
        break;
    end
end
if sizeNFFT(1) > 1 || sizeNFFT(2) > 1
    options1.nfft = coder.nullcopy(zeros(sizeNFFT));
else
    options1.nfft = max(256, 2^nextpow2(N));
end

%assign invalid default value to infer size as 1*1 for codegen
options1.Fs = nan; % Work in rad/sample
options1.centerdc = false;
options1.range = 'twosided';  %Two Sided Range
options1.conflevel = nan; % Default Invalid value

% extract and remove any 'reassigned' option from the argument list
[reassign,args1] = getReassignmentOption(varargin{:});
options1.reassign = reassign;

% Determine if frequency vector specified
freqVecSpec = false;
len_args = length(args1);
if len_args > 0
    for i=1:len_args
        if ~ischar(args1{i}) && length(args1{i}) >1
            freqVecSpec = true;
        end
    end
end

if isreal_x && ~freqVecSpec
    options1.range = 'onesided'; %One Sided Range
end

if any(strcmp(args1, 'whole'))
    coder.internal.warning('signal:periodogram:invalidRange', 'whole', 'twosided');
    options1.range = 'twosided';
elseif any(strcmp(args1, 'half'))
    coder.internal.warning('signal:periodogram:invalidRange', 'half', 'onesided');
    options1.range = 'onesided';
end

[options,msg,msgobj] = psdoptions(isreal_x,options1,args1{:});

if coder.target('MATLAB') && ~isempty(msg)
  error(msgobj);
end

% ensure frequency vector is linearly spaced when performing reassignment
if reassign && ~isscalar(options.nfft)
  f = options.nfft(:);
  
  % see if we can get a uniform spacing of the freq vector
  [~, ~, ~, maxerr] = signal.internal.spectral.getUniformApprox(f);
  
  % see if the ratio of the maximum absolute deviation relative to the
  % largest absolute in the frequency vector is less than a few eps
  isuniform = maxerr < 3*eps(class(f));
  
  if ~isuniform
    coder.internal.error('signal:periodogram:ReassignFreqMustBeUniform');
  end
  
end

end

%--------------------------------------------------------------------------
function [reassign, args]  = getReassignmentOption(varargin)
% search for 'reassigned' flag and return true if present.
% error if 
reassign = false;
args = varargin;
matchLoc = find(strncmpi('reassign',args,8));
if ~isempty(matchLoc)
    reassign = true;
    if any(strcmpi('confidencelevel',args))
        %required to be a runtime error for function signatures : func(x,'conflevel',c)
        coder.internal.error('signal:psdoptions:ConflictingOptions','reassigned', 'ConfidenceLevel');
    end
end

if coder.target('MATLAB')
    args(matchLoc) = [];
end

end

%--------------------------------------------------------------------------
function w = makeOnesidedWc(range,w,nfft)

if strcmp(range,'onesided') && isscalar(nfft)
   if signalwavelet.internal.isodd(nfft)
      select = 1:(nfft+1)/2;  % ODD     
   else
      select = 1:nfft/2+1;    % EVEN     
   end
   w = w(select,:);
end  
end
    
%--------------------------------------------------------------------------
function Wc = centerWc(options,Wc)
     
nFreq = size(Wc,1);
if options.centerdc
  nfft_even = signalwavelet.internal.iseven(options.nfft);
  if strcmp(options.range,'onesided')
    if nfft_even
      Wc = [-Wc(nFreq-1:-1:2,:) ; Wc(1:nFreq,:)];
    else
      Wc = [-Wc(nFreq:-1:2,:) ; Wc(1:nFreq,:)];
    end
  else % two-sided
    if nfft_even
      Wc = Wc([nFreq/2+2:nFreq 1:nFreq/2+1],:);
    else
      Wc = Wc([(nFreq+1)/2+1:nFreq 1:(nFreq+1)/2],:);
    end
  end
end
end

%--------------------------------------------------------------------------
function Wc = dealiasWc(options,Wc)
Fs = options.Fs;
if isnan(Fs)
    % normalize to 2*pi when default specified.
    Fs1 = 2*pi;
else
    Fs1 = Fs;
end

freqs = options.nfft;

if coder.target('MATLAB')
    hasNegativeFreqs  = any(freqs < 0);
else
    hasNegativeFreqs = coder.internal.vAllOrAny('any',freqs,@(freqs)freqs<0);
end

if options.centerdc || hasNegativeFreqs
   % map to [-Fs/2,Fs/2) when using negative frequencies
   Wc = mod(Wc+Fs1/2,Fs1)-Fs1/2;
else
   % map to [0,Fs) when using positive frequencies
   Wc = mod(Wc,Fs1);
end
end
