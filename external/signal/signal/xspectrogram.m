function varargout = xspectrogram(x,y,varargin)
%XSPECTROGRAM Cross-spectrogram using Short-Time Fourier Transforms (STFT).
%   S = XSPECTROGRAM(X,Y) returns the cross-spectrogram of the signals
%   specified by vectors X and Y. X and Y must have the same length. X and
%   Y are each divided into eight segments with 50% overlap, and each
%   segment is windowed with a Hamming window. The number of frequency
%   points used to calculate the discrete Fourier transforms is equal to
%   the larger of 256 or the next power of two greater than the segment
%   length.
%
%   If X and Y cannot be divided exactly into eight segments, they are
%   truncated.
%
%   S = XSPECTROGRAM(X,Y,WINDOW), when WINDOW is a vector, divides X and Y
%   into segments of the same length as WINDOW, and then windows each
%   segment with the vector specified in WINDOW.  When WINDOW is an
%   integer, the function divides X and Y into segments of length equal to
%   that integer value and windows each segment with a Hamming window.  If
%   WINDOW is not specified, the default is used.
%
%   S = XSPECTROGRAM(X,Y,WINDOW,NOVERLAP) specifies NOVERLAP samples of
%   overlap between adjoining segments. NOVERLAP must be an integer smaller
%   than WINDOW if WINDOW is an integer.  NOVERLAP must be an integer
%   smaller than the length of WINDOW if WINDOW is a vector.  If NOVERLAP
%   is not specified, the default value is used to obtain a 50% overlap.
%
%   S = XSPECTROGRAM(X,Y,WINDOW,NOVERLAP,NFFT) specifies the number of
%   frequency points used to calculate the discrete Fourier transforms. If
%   NFFT is not specified, the default NFFT is used.
%
%   S = XSPECTROGRAM(X,Y,WINDOW,NOVERLAP,NFFT,Fs) specifies the sample
%   rate, Fs, in Hz. If Fs is specified as empty, it defaults to 1 Hz. If
%   it is not specified, normalized frequency is used.
%
%   Each column of S contains an estimate of the short-term, time-localized
%   frequency content of X and Y.  Time increases across the columns of S,
%   from left to right.  Frequency increases down the rows, starting at 0.
%   If X and Y are length N signals and complex, S is a real matrix with
%   NFFT rows and k = fix((N-NOVERLAP)/(length(WINDOW)-NOVERLAP)) columns.
%   For real X and Y, S has (NFFT/2+1) rows if NFFT is even and (NFFT+1)/2
%   rows if NFFT is odd.
%
%   S = XSPECTROGRAM(...,'MinThreshold',THRESH) sets to zero any elements
%   such that 10*log10(S) is less than THRESH. Specify THRESH in decibels.
%   The default value of THRESH is -Inf.
%
%   S = XSPECTROGRAM(...,SPECTRUMTYPE) uses the window scaling algorithm
%   specified by SPECTRUMTYPE when computing the cross-spectrogram.
%   SPECTRUMTYPE can be set to 'psd' or 'power':
%      'psd'   - returns the cross power spectral density.
%      'power' - scales each estimate of the cross power spectral
%                density by the equivalent noise bandwidth of the window
%                (in Hz).  Use this option to obtain an estimate of the
%                power at each frequency.
%   The default value for SPECTRUMTYPE is 'psd'.
%
%   [S,F,T] = XSPECTROGRAM(...) returns a vector of frequencies, F, and a
%   vector of times, T, at which the cross-spectrogram is computed. F has
%   length equal to the number of rows of S. T has length k (defined above)
%   and its value corresponds to the center of each segment. If a sample
%   rate is not provided, F contains normalized frequencies.
%
%   [S,F,T] = XSPECTROGRAM(X,Y,WINDOW,NOVERLAP,F) computes the two-sided
%   cross-spectrogram at the normalized frequencies specified in the vector
%   F. F must have at least two elements.
%
%   [S,F,T] = XSPECTROGRAM(X,Y,WINDOW,NOVERLAP,F,Fs) computes the two-sided
%   cross-spectrogram at the frequencies specified in vector F. F must be
%   expressed in Hz and have at least two elements.
%
%   [S,F,T,C] = XSPECTROGRAM(...) returns the complex time-varying cross
%   spectrum of the signals X and Y. The cross-spectrogram, S, is the
%   magnitude of C.
%
%   [...] = XSPECTROGRAM(...,FREQRANGE) returns each spectrum over the
%   specified range of frequencies based upon the value of FREQRANGE:
%
%      'onesided' - returns a one-sided matrix S for real input signals.
%         If NFFT is even, S has NFFT/2+1 rows and is computed over the
%         interval [0,pi].  If NFFT is odd, then S has (NFFT+1)/2 rows
%         and is computed over the interval [0,pi). When Fs is specified,
%         the intervals become [0,Fs/2] and [0,Fs/2) for even and odd NFFT,
%         respectively.
%
%      'twosided' - returns a two-sided matrix.  S has NFFT rows and is
%         computed over the interval [0,2*pi). When Fs is specified, the
%         interval becomes [0,Fs).
%
%      'centered' - returns a centered two-sided matrix S. S has NFFT rows
%         and is computed over the interval (-pi,pi] for even length
%         NFFT and (-pi,pi) for odd length NFFT. When Fs is specified, the
%         intervals become (-Fs/2,Fs/2] and (-Fs/2,Fs/2) for even and odd
%         NFFT, respectively.
%
%      FREQRANGE may be placed in any position in the input argument list
%      after NOVERLAP.  The default value of FREQRANGE is 'onesided' when X
%      and Y are real and 'twosided' when X or Y is complex.
%
%   [...] = XSPECTROGRAM(...,'OutputTimeDimension',TIMEDIMENSION) specifies
%   the orientation of S, T, and C according to the location of the time
%   dimension. If TIMEDIMENSION is set to 'downrows', the time dimension of
%   S and C is down the rows and the frequency dimension is across the
%   columns. T is returned as a column vector. If TIMEDIMENSION is set to
%   'acrosscolumns', the time dimension of S and C is across the columns
%   and the frequency dimension is down the rows. T is returned as a row
%   vector. This argument is ignored if this function is called with no
%   output arguments. The default value is 'acrosscolumns'.
%
%   XSPECTROGRAM(...) with no output arguments plots the cross-spectrogram
%   on a surface in the current figure.
%
%   XSPECTROGRAM(...,FREQLOCATION) controls where MATLAB displays the
%   frequency axis on the plot. This string can be either 'xaxis' or
%   'yaxis'.  Setting this FREQLOCATION to 'yaxis' displays frequency on
%   the y-axis and time on the x-axis.  The default is 'xaxis' which
%   displays the frequency on the x-axis. If FREQLOCATION is specified when
%   output arguments are requested, it is ignored.
%
%   % Example 1
%   %   Plot the magnitude of the cross-spectrogram of two chirps
%   t = 0:0.001:2;
%   x1 = chirp(t,100,1,200,'quadratic');
%   x2 = chirp(t,150,1,200, 'quadratic');
%   xspectrogram(x1,x2,128,120,128,1e3);
%   title('Cross-Spectrogram of Two Quadratic Chirps')
%
%   % Example 2
%   %   Compute the phase shift between two quadratic chirps
%   t = 0:0.001:2;
%   y1 = chirp(t,100,1,200,'quadratic',-5);
%   y2 = chirp(t,100,1,200,'quadratic',-45);
%   [~,f,~,C] = xspectrogram(y1,y2,kaiser(128,18),120,128,1e3);
%   % Extract the maximum-energy time-frequency ridge
%   [~,~,lridge] = tfridge(C,f);
%   % Compute the mean phase shift in degrees
%   mean(angle(C(lridge))*180/pi)
%
%   See also SPECTROGRAM, CPSD, MSCOHERE.

% [1] Oppenheim, A. V., and R. W. Schafer. Discrete-Time Signal Processing.
%     Englewood Cliffs, NJ: Prentice-Hall 1989.
% [2] Mitra, S. K.: Digital Signal Processing: A Computer-Based Approach.
%     2nd Ed. New York: McGraw-Hill, 2001.

%   Copyright 2016-2019 The MathWorks, Inc.
%#codegen
narginchk(2,13);
nargoutchk(0,4);
inpArgs = cell(size(varargin));
if nargin > 2
    if ~coder.target('MATLAB') % check if char/string inputs are constants
        for i = 1:length(varargin)
            if ischar(varargin{i}) || isStringScalar(varargin{i})
                coder.internal.assert(coder.internal.isConst(varargin{i}),'signal:spectrogram:inputNotConstant');
            end
        end
    end
    [inpArgs{:}] = convertStringsToChars(varargin{:});
else
    inpArgs = varargin;
end

validateInputs(x,y);

if nargout > 0
    [varargout{1:nargout}] = pspectrogram({x,y},'xspect',inpArgs{:});
else
    pspectrogram({x,y},'xspect',inpArgs{:});
end

%--------------------------------------------------------------------------
function validateInputs(x,y)
% Check the type of x and y. Error if either is empty.
validateattributes(x,{'single','double'},...
                   {'nonempty'},'xspectrogram','X',1);
validateattributes(y,{'single','double'},...
                   {'nonempty'},'xspectrogram','Y',2);

% LocalWords:  STFT NOVERLAP NFFT Fs SPECTRUMTYPE FREQRANGE TIMEDIMENSION
% LocalWords:  downrows acrosscolumns FREQLOCATION xaxis yaxis lridge tfridge
% LocalWords:  Oppenheim Schafer Englewood Mitra nd Graw xspect
