function varargout = mscohere(x,y,varargin)
%MSCOHERE   Magnitude Squared Coherence Estimate.
%   Cxy = MSCOHERE(X,Y) estimates the magnitude squared coherence estimate
%   of the system with input X and output Y using Welch's averaged,
%   modified periodogram method. Coherence is a function of frequency with
%   values between 0 and 1 that indicate how well the input X corresponds
%   to the output Y at each frequency.  The magnitude squared coherence,
%   Cxy, is given by Cxy = (abs(Pxy).^2)./(Pxx.*Pyy) where Pxx and Pyy are
%   the power spectral density (PSD) estimate of X and Y, respectively; and
%   Pxy is the Cross-PSD (CPSD) estimate of X and Y. See "help pwelch" and
%   "help cpsd" for complete details.
%
%   By default, X and Y are divided into eight sections with 50% overlap,
%   each section is windowed with a Hamming window, and eight modified
%   periodograms are computed and averaged.  See "help pwelch" and "help
%   cpsd" for complete details.
%
%   X and Y may be either vectors or two-dimensional matrices.  If both are
%   matrices and have the same size, MSCOHERE operates column-wise:
%   Cxy(:,n) = MSCOHERE(X(:,n),Y(:,n)).  If one is a matrix and the other
%   is a vector, the vector is converted to a column vector and expanded
%   internally so both inputs have the same number of columns.
%
%   Cxy = MSCOHERE(X,Y,WINDOW), when WINDOW is a vector, divides each
%   column of X and Y into overlapping sections of length equal to the
%   length of WINDOW, and then windows each section with the vector
%   specified in WINDOW. If WINDOW is an integer, each column of X and Y
%   are divided into sections of length WINDOW, and each section is
%   windowed with a Hamming window of that length.  If WINDOW is omitted or
%   specified as empty, a Hamming window is used to obtain eight sections
%   of X and Y.
%    
%   Cxy = MSCOHERE(X,Y,WINDOW,NOVERLAP) uses NOVERLAP samples of overlap
%   from section to section. NOVERLAP must be an integer smaller than
%   WINDOW, if WINDOW is an integer; or smaller than the length of WINDOW,
%   if WINDOW is a vector. If NOVERLAP is omitted or specified as empty,
%   it is set to obtain a 50% overlap.
%
%   When WINDOW and NOVERLAP are not specified, MSCOHERE divides X into
%   eight sections with 50% overlap and windows each section with a Hamming
%   window. MSCOHERE computes and averages the periodogram of each section
%   to produce the estimate.
%
%   [Cxy,W] = MSCOHERE(X,Y,WINDOW,NOVERLAP,NFFT) specifies the number of
%   FFT points, NFFT, used to calculate the PSD and CPSD estimates. For
%   real X and Y, Cxy has length (NFFT/2+1) if NFFT is even, and (NFFT+1)/2
%   if NFFT is odd. For complex X or Y, Cxy always has length NFFT. If NFFT
%   is omitted or specified as empty, it is set to  either 256 or the next
%   power of two greater than the length of each section of X (or Y),
%   whichever is larger.
%
%   If NFFT is greater than the length of each section, the data is
%   zero-padded. If NFFT is less than the section length, the segment is
%   "wrapped" (using DATAWRAP) to make the length equal to NFFT. This
%   produces the correct FFT when NFFT is smaller than the section length.
%
%   W is the vector of normalized frequencies at which Cxy is estimated.
%   W has units of radians/sample.  For real signals, W spans the interval
%   [0,pi] when NFFT is even and [0,pi) when NFFT is odd.  For complex
%   signals, W always spans the interval [0,2*pi).
%
%   [Cxy,W] = MSCOHERE(X,Y,WINDOW,NOVERLAP,W) computes the two-sided
%   coherence estimate at the normalized angular frequencies contained in
%   the vector W.  W must have at least two elements.
%
%   [Cxy,F] = MSCOHERE(X,Y,WINDOW,NOVERLAP,NFFT,Fs) returns the coherence
%   estimate as a function of physical frequency.  Fs is the sampling
%   frequency specified in hertz.  If Fs is empty, it defaults to 1 Hz.
%
%   F is the vector of frequencies (in hertz) at which Cxy is estimated.
%   For real signals, F spans the interval [0,Fs/2] when NFFT is even and
%   [0,Fs/2) when NFFT is odd.  For complex signals, F always spans the
%   interval [0,Fs).
%
%   [Cxy,F] = MSCOHERE(X,Y,WINDOW,NOVERLAP,F,Fs) computes the coherence
%   estimate at the physical frequencies contained in the vector F.  F must
%   be expressed in hertz and have at least two elements.
%
%   [...] = MSCOHERE(...,'mimo') returns the multiple coherence function
%   for a multiple-input/multiple-output system. The multiple coherence
%   function of the ith signal in Y is contained in the ith column of Cxy.
%   If X is a vector, multiple coherence is equivalent to ordinary
%   magnitude squared coherence. If X and Y have a different number of
%   columns and both have more than one column, this option is used by
%   default.
%
%   [...] = MSCOHERE(...,FREQRANGE) returns the coherence estimate computed
%   over the specified range of frequencies based upon the value of
%   FREQRANGE:
%
%      'onesided' - returns the one-sided coherence estimate of real input
%         signals X and Y. If NFFT is even, Cxy has length NFFT/2+1 and is
%         computed over the interval [0,pi]. If NFFT is odd, Cxy has length
%         (NFFT+1)/2 and is computed over the interval [0,pi). When Fs is
%         optionally specified, the intervals become [0,Fs/2] and [0,Fs/2)
%         for even and odd NFFT, respectively.
%
%      'twosided' - returns the two-sided coherence estimate for either
%         real or complex input X and Y. Cxy has length NFFT and is
%         computed over the interval [0,2*pi). When Fs is specified, the
%         interval becomes [0,Fs).
%
%      'centered' - returns the centered two-sided two-sided coherence
%         estimate for either real or complex X and Y.  Cxy has length NFFT
%         and is computed over the interval (-pi, pi] for even length NFFT
%         and (-pi, pi) for odd length NFFT. When Fs is specified, the
%         intervals become (-Fs/2, Fs/2] and (-Fs/2, Fs/2) for even and odd
%         NFFT, respectively.
%
%      FREQRANGE may be placed in any position in the input argument list
%      after NOVERLAP.  The default value of FREQRANGE is 'onesided' when X
%      and Y are both real and 'twosided' when either X or Y is complex.
%
%   MSCOHERE(...) with no output arguments plots the coherence estimate (in
%   decibels per unit frequency) in the current figure window.
%
%   % Example 1:
%   %   Compute and plot the coherence estimate between two colored noise 
%   %   sequences x and y.
%   h = fir1(30,0.2,rectwin(31));   % Window-based FIR filter design
%   h1 = ones(1,10)/sqrt(10);       
%   r = randn(16384,1);             
%   x = filter(h1,1,r);  % Filter the data sequence
%   y = filter(h,1,x);   % Filter the data sequence  
%   noverlap = 512; nfft = 1024;
%   mscohere(x,y,hann(nfft),noverlap,nfft); % Plot estimate
%
%   % Example 2:
%   %   Compute and plot the multiple coherence estimate between x and y.  
%   h1 = fir1(30,0.3,rectwin(31));
%   h2 = fir1(30,0.5,rectwin(31));
%   x = randn(16384,2);
%   y = filter(h1,1,x(:,1)) + filter(h2,1,x(:,2));
%   noverlap = 512; nfft = 1024;
%   mscohere(x,y,hann(nfft),noverlap,nfft,'mimo'); % Plot estimate
%
%   See also TFESTIMATE, CPSD, PWELCH, PERIODOGRAM. 

%#codegen

%   Copyright 1988-2018 The MathWorks, Inc.

narginchk(2,8)

inputArgs = cell(size(varargin));

if nargin > 2
    [inputArgs{:}] = convertStringsToChars(varargin{:});
else
    inputArgs = varargin;
end

cond = (~coder.target('MATLAB') && nargout == 0);
coder.internal.errorIf(cond,'signal:mscohere:CodegenNotEnoughOutputs');

funcName = 'mscohere';
% Possible outputs are:
%       Plot
%       Cxy
%       Cxy, freq
[varargout{1:nargout}] = welch({x,y},funcName,inputArgs{:});

if nargout == 0
    title(getString(message('signal:dspdata:dspdata:CoherenceTitle')));
    if any(strcmpi(varargin,'MIMO'))
        ylabel(getString(message('signal:dspdata:dspdata:MultipleCoherence')));  
    else
        ylabel(getString(message('signal:dspdata:dspdata:MagnitudeSquaredCoherence')));  
    end
end

% [EOF]
