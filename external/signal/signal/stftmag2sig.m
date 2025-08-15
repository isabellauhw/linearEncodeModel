function [X,T,INFO] = stftmag2sig(S,varargin)
%STFTMAG2SIG Signal reconstruction from STFT magnitude
%   X = STFTMAG2SIG(S,NFFT) returns a time-domain real signal X estimated
%   from the short-time Fourier transform (STFT) magnitude, S, based on the
%   Griffin-Lim algorithm. Specify S as a matrix with time increasing
%   across the columns and frequency increasing down the rows. The function
%   assumes S was computed with the FFT length NFFT. S must correspond to a
%   single-channel, real-valued signal. S is expected to be centered and
%   conjugate symmetric. Use the 'FrequencyRange' parameter if S has a
%   different frequency range.
%
%   X = STFTMAG2SIG(S,NFFT,Fs) specifies the sample rate of S in hertz as a
%   positive scalar. If Fs is not specified, normalized frequency in
%   rad/sample is used.
%
%   X = STFTMAG2SIG(S,NFFT,Ts) specifies Ts as a positive scalar duration
%   corresponding to the sample time of X. The sample rate in this case is
%   calculated as 1/Ts.
%
%   X = STFTMAG2SIG(...,'Window',WINDOW) specifies the window for the
%   reconstruction. A good signal reconstruction requires WINDOW to
%   match the window used to generate the STFT magnitude. The default is a
%   Hann window of length 128 with window sampling flag, 'periodic'.
%
%   X = STFTMAG2SIG(...,'OverlapLength',NOVERLAP) specifies an integer number
%   of samples of overlap between adjoining segments. NOVERLAP must be
%   smaller than the length of WINDOW. A good signal reconstruction
%   requires NOVERLAP to match the NOVERLAP used to generate the STFT
%   magnitude. If NOVERLAP is not specified, it is set to the largest
%   integer less than or equal to 75% of the window length.
%
%   X = STFTMAG2SIG(...,'FrequencyRange',FREQRANGE) treats the input S as
%   the STFT magnitude over the specified range of frequencies based on the
%   value of FREQRANGE and the FFT length used to generate the STFT
%   magnitude:
%
%      'onesided' - treat S as a one-sided STFT magnitude. The magnitude
%      has a frequency range of [0,pi] for even FFT length and [0,pi) for
%      odd FFT length. When time information is provided, the intervals
%      become [0,Fs/2] and [0,Fs/2), respectively.
%
%      'centered' - treat S as a two-sided and centered STFT magnitude. The
%      magnitude has a frequency range of (-pi,pi] for even FFT length and
%      (-pi,pi) for odd FFT length. When time information is provided, the
%      intervals become (-Fs/2,Fs/2] and (-Fs/2,Fs/2), respectively.
%
%      'twosided' - treat S as a two-sided STFT magnitude. The magnitude
%      has a frequency range of [0,2*pi). When time information is
%      provided, the interval becomes [0,Fs).
%
%      The default value of FREQRANGE is 'centered'.
%
%   X = STFTMAG2SIG(...,'Method',METHOD) specifies a signal reconstruction
%   algorithm. METHOD can be 'gla' (default) for the Griffin-Lim algorithm
%   proposed in [1], 'fgla' for the fast Griffin-Lim algorithm proposed in
%   [2], or 'legla' for the fast algorithm proposed by Le Roux and
%   collaborators in [3].
%
%   X = STFTMAG2SIG(...,'InitializePhaseMethod',INITPHASEMETHOD)
%   initializes the STFT phases using the method specified in
%   INITPHASEMETHOD:
%
%      'zeros' - initialize the phases as zeros.
%
%      'random' - initialize the phases as random numbers distributed
%                 uniformly in the interval [-pi,pi].
%
%      The default value of INITPHASEMETHOD is 'zeros'.
%
%   X = STFTMAG2SIG(...,'InitialPhase',INITPHASE) specifies the initial
%   STFT phases. INITIALPHASE must have the same size as input S and its
%   elements must be within [-pi,pi]. This option is incompatible with
%   'InitializePhaseMethod'.
%
%   X = STFTMAG2SIG(...,'MaxIterations',MAXITERATIONS) specifies the
%   maximum number of optimization iterations used in the reconstruction
%   process. The process stops when the number of iterations is greater
%   than MAXITERATIONS. The default value of MAXITERATIONS is 100.
%
%   X = STFTMAG2SIG(...,'InconsistencyTolerance',INCONSTOL) specifies the
%   inconsistency tolerance. The reconstruction process stops when the
%   normalized inconsistency ||STFT(ISTFT(Sest))-Sest||/||Sest||, where
%   Sest is the estimated complex STFT at each iteration, is smaller than
%   INCONSTOL. The tolerance is a positive real value and defaults to 1e-4.
%
%   X = STFTMAG2SIG(...,'InputTimeDimension',TIMEDIMENSION) specifies the
%   orientation of S according to the direction of the time dimension. If
%   TIMEDIMENSION is set to 'downrows', STFTMAG2SIG assumes that the time
%   dimension of S is down the rows and the frequency dimension is across
%   the columns. If TIMEDIMENSION is set to 'acrosscolumns', STFTMAG2SIG
%   assumes that the time dimension of S is across the columns and the
%   frequency dimension is down the rows. The default value is
%   'acrosscolumns'.
%
%   X = STFTMAG2SIG(...,'UpdateParameter',ALPHA) specifies the update
%   parameter in the update rule of the fast Griffin-Lim algorithm. This
%   argument applies only when METHOD is set to 'fgla'. ALPHA is a real
%   positive scalar and defaults to 0.99.
%
%   X = STFTMAG2SIG(...,'TruncationOrder',L) specifies the truncation order
%   in the update rule of the 'legla' algorithm that controls the number of
%   phase values updated in each iteration. This argument applies only when
%   METHOD is set to 'legla'. L is a real positive integer. If omitted, L
%   is determined by an adaptive algorithm.
%
%   X = STFTMAG2SIG(...,'Display',DISPLAY) specifies whether to display the
%   normalized inconsistency value on the command line every 20 iterations
%   and show the final stopping information. The default is false.
%
%   [X,T] = STFTMAG2SIG(...) returns the times of the reconstructed
%   signals. If time information is provided, T is a vector that contains
%   time values in seconds. If no time information is provided, the output
%   is a vector in sample numbers. X has a number of rows or columns equal
%   to the length of the time vector T when TIMEDIMENSION is set to
%   'downrows' or 'acrosscolumns', respectively.
%
%   [X,T,INFO] = STFTMAG2SIG(...) returns a structure containing these
%   convergence information:
%      
%      ExitFlag:            Termination flag. It is true if the
%                           algorithm stopped when it reached the maximum
%                           number of iterations and false if the algorithm
%                           stopped when the inconsistency tolerance was
%                           met.
%
%      NumIterations:       Total number of iterations.
%
%      Inconsistency:       Average relative improvement toward
%                           convergence between the final two iterations.
%
%      ReconstructedPhase:  Reconstructed phase at the final iteration.
%
%      ReconstructedSTFT:   Reconstructed STFT at the final iteration.
%
%   % EXAMPLE 1:
%      % Reconstruct a sinusoid.
%      fs = 1000;
%      ts = 0:1/fs:2-1/fs;
%      x = cos(2*pi*2*ts).'+1;
%      nfft = 50;
%      OverlapLength = 25;
%      win =  hann(nfft,'periodic');
%      S = stft(x,'Window',win,'OverlapLength',OverlapLength);
%      xrec = stftmag2sig(abs(S),nfft,'Window',win,'OverlapLength',OverlapLength);
%      plot(ts,x,ts,xrec)
%      legend('Original','Reconstructed')
%
%   % EXAMPLE 2:
%      % Reconstruct an audio signal using the 'legla' algorithm.
%      load mtlb
%      % To hear, type sound(mtlb,Fs)
%      nfft = 128;
%      win = hann(nfft,'periodic');
%      S = stft(mtlb,'Window',win,'FrequencyRange','onesided');
%      xrec = stftmag2sig(abs(S),nfft,'Window',win,'FrequencyRange','onesided','Method','legla');
%      % To hear, type sound(xrec,Fs)
%
%   See also STFT and ISTFT.

%   [1] D. Griffin and Jae Lim, "Signal estimation from modified short-time
%   Fourier transform," in IEEE Transactions on Acoustics, Speech, and
%   Signal Processing, vol. 32, no. 2, pp. 236-243, April 1984.
%
%   [2] N. Perraudin, P. Balazs, and P. L. Søndergaard, "A fast Griffin-Lim
%   algorithm," 2013 IEEE Workshop on Applications of Signal Processing to
%   Audio and Acoustics, New Paltz, NY, 2013, pp. 1-4.
%
%   [3] J. Le Roux, H. Kameoka, N. Ono, and S. Sagayama, "Fast Signal
%   Reconstruction from Magnitude STFT Spectrogram Based on Spectrogram
%   Consistency," in Proceedings International Conference on Digital Audio
%   Effects (DAFx), pp. 397-403, Sep. 2010.

%   Copyright 2020 The MathWorks, Inc.

%#codegen

narginchk(1,27);
if coder.target('MATLAB') % For MATLAB
    nargoutchk(0,3);
else
    nargoutchk(1,3);
end

%---------------------------------
%Parse input
coder.internal.errorIf(isa(S,'gpuArray'),'signal:stftmag2sig:GPUArrayNotSupported');
% Validate istft data attributes and assign to data variable
validateattributes(S,{'single','double'},...
    {'nonsparse','finite','nonnan','2d','nonnegative','real'},'stftmag2sig','S');

%--------------------------------------
% Parse name-value pairs
opts = signal.internal.stftmag2sig.stftmag2sigParser(size(S),class(S),varargin{:});

%---------------------------------------
% Phase reconstruction
[X,T,INFO] = signal.internal.stftmag2sig.computeSTFTmag2sig(cast(S,opts.DataType),opts);

end