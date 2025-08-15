function [S,f,t,P,fcorr,tcorr] = pspectrogram(x,spectype,varargin)
%PSPECTROGRAM Spectrogram only
%   S = PSPECTROGRAM(X,'spect',WINDOW,NOVERLAP,NFFT,Fs,...)
%   [S,F,T,P,fcorr,tcorr] = PSPECTROGRAM(...)
%
%   LIMITATIONS:
%      Only for use with gpuArray Spectrogram - Cross Spectrogram not
%      supported

%   Copyright 2019-2020 The MathWorks, Inc.

% Parse arguments specific to PSPECTROGRAM and remove from argument list.
[reassign,varargin] = getReassignmentOption(varargin{:});
[faxisloc, varargin] = getFreqAxisOption(varargin{:});
[threshold,varargin] = getMinThreshold(varargin{:});

% Look for psd and power flags
[esttype, varargin] = psdesttype({'psd','power','ms'},'psd',varargin);
if strcmpi(esttype,'ms')
    error(message("signal:spectrogram:InvalidMsLegacyOption","gpuArray"));
end

% Look for output time dimension name-value pair and remove from argument
% list.
[timeDimension, varargin] = getOutputTimeDimension(varargin{:});

% Look for legacy freqrange options.
if any(strcmpi(varargin,'whole')) || any(strcmpi(varargin,'half'))
    error(message("signal:spectrogram:InvalidFreqrangeLegacyOption","gpuArray"));
end

% Parse input arguments (using the PWELCH parser since it shares the same API).
[x,~,~,y,ny,win,~,~,noverlap,~,~,options] = signal.internal.spectral.welchparse(x,esttype,varargin{:});

% Check for valid input signals
chkinput(x,'X');

coder.internal.errorIf(noverlap(1,1)~=round(noverlap(1,1))||noverlap(1,1)<0,...
    'signal:spectrogram:NoverlapNonnegativeInteger');
validateattributes(win,{'double','single'},{'nonsparse'},'spectrogram','Window');

% Process frequency-specific arguments
[Fs,nfft,isnormfreq,options] = processFrequencyOptions(options,reassign);

% Checking which precision to cast to
win = gpuArray(win);
if (isaUnderlying(win,'single') && ~isscalar(win)) || isaUnderlying(x,'single')
    DT = 'single';
else
    DT = 'double';
end

x = gpuArray(cast(reshape(x,[],1),DT));
y = cast(reshape(y,[],1),'like',x);
win = cast(reshape(win,[],1),'like',real(y()));
nwin = length(win);
fcorr = zeros([0,0],'like',x);
tcorr = zeros([0,0],'like',x);
nfft = cast(nfft,'like',win);

% Place x into columns and return the corresponding central time estimates.
[xin,t] =  parallel.internal.gpu.extractWindows(x,nwin,noverlap,Fs);

if strcmpi(spectype,'spect') % Spectrogram
    % Compute the raw STFT
    % Apply the window to the array of offset signal segments.
    xin_off = win.*xin;
    [y,f] = computeDFT(xin_off,nfft,Fs);
    
    % Compute reassignment matrices.
    [fcorr,tcorr] = computeReassign(xin,win,Fs,nfft,y,f,t,reassign,nargout);
    
    % Truncate output and adjust any time-frequency corrections based on
    % FREQRANGE spectrum format ('centered', 'onesided', 'twosided')
    [S,f,fcorr,tcorr] = formatSpectrogram(y,f,fcorr,tcorr,Fs,nfft,options);
    
    % Compute PSD when required.
    if nargout==0 || nargout>3
        [P,f] = compute_PSD(win,S,nfft,f,t,options,Fs,esttype,threshold,reassign,fcorr,tcorr);
    else
        P = zeros([0,0],'like',f);
    end
    
    % Shift the outputs when 'centered' is specified.
    if options.centerdc && length(options.nfft)==1
        [S,f,P,fcorr,tcorr] = centerOutputs(nargout,S,f,P,fcorr,tcorr);
    end
    
    if nargout==0
        % plot when no output arguments are specified
        displayspectrogram(t,f,P,isnormfreq,faxisloc,esttype,threshold);
    else
        % Non-conjugate transpose S, t, P, fcorr, and tcorr if
        % timeDimension is 'downrows'
        [S,t,P,fcorr,tcorr] = nonConjugateTransposeOutputs(timeDimension,S,t,P,fcorr,tcorr);
    end
    
else % Cross Spectrogram (not changed)
    % Validate second input argument
    chkinput(y,'Y');
    
    % Place y into columns.
    yin = signal.internal.stft.getSTFTColumns(y,ny,nwin,noverlap,Fs);
    
    if options.centerdc
        freqrange = 'centered';
    else
        freqrange = options.range;
    end
    
    % Compute cross STFT using CPSD.
    [S,f] = cpsd(xin,yin,win,0,nfft,Fs,freqrange);
    
    % Scale the cross spectrogram to power using the effective noise
    % bandwidth of the window, if requested.
    if strcmp(esttype,'power')
        S = S*enbw(win,Fs);
    end
    
    % Compute time-varying cross spectrum when requested.
    if nargout>3
        P = S;
    else
        P = [];
    end
    
    % Return the cross spectrogram (magnitude) as the first argument.
    S = abs(S);
    
    % Apply threshold
    if threshold>0
        S(S<threshold) = 0;
    end
    
    if nargout==0
        % plot when no output arguments are specified
        displayspectrogram(t,f,S,isnormfreq,faxisloc,esttype,threshold);
    else
        % Non-conjugate transpose S, t, and P if timeDimension is
        % 'downrows'
        [S,t,P] = nonConjugateTransposeOutputs(timeDimension,S,t,P);
    end
    
end

%--------------------------------------------------------------------------
function chkinput(x,X)
% Check for valid input signal

if isempty(x) || issparse(x) || ~isfloat(x)
    error(message('signal:spectrogram:MustBeFloat', X));
end

if min(size(x))~=1
    error(message('signal:spectrogram:MustBeVector', X));
end

%--------------------------------------------------------------------------
function displayspectrogram(t,f,Pxx,isFsnormalized,faxisloc,esttype, threshold)
% Cell array of the standard frequency units strings

if strcmpi(esttype,'power')
    plotOpts.cblbl = getString(message('signal:dspdata:dspdata:PowerdB'));
else
    if isFsnormalized
        plotOpts.cblbl = getString(message('signal:dspdata:dspdata:PowerfrequencydBradsample'));
    else
        plotOpts.cblbl = getString(message('signal:dspdata:dspdata:PowerfrequencydBHz'));
    end
end

%Threshold in dB
plotOpts.freqlocation = faxisloc;
plotOpts.threshold = 10*log10(threshold+eps);
plotOpts.isFsnormalized = logical(isFsnormalized);

%Power in dB
%Gather necessary as plotting can not be done from gpuArray
signalwavelet.internal.convenienceplot.plotTFR(gather(t),gather(f), 10*log10(abs(gather(Pxx))+eps),plotOpts);

% -------------------------------------------------------------------------
function [Pxx,f,fcorr,tcorr] = compute_PSD(win,y,nfft,f,t,options,Fs,esttype,threshold,reassign,fcorr,tcorr)

% Evaluate the window normalization constant.
if strcmpi(esttype,'power')
    if reassign
        % compensate for the power of the window including a
        % 1/N scaling factor omitted by FFT/DFT computation.
        if isscalar(nfft)
            U = nfft*(win'*win);
        else
            U = numel(win)*(win'*win);
        end
    else
        % The window is convolved with every power spectrum peak, therefore
        % compensate for the DC value squared to obtain correct peak heights.
        % The 1/N factor has been omitted since it will cancel below.
        U = sum(win)^2;
    end
else
    % compensates for the power of the window.
    % The 1/N factor has been omitted since it will cancel below.
    U = win'*win;
end

Sxx = arrayfun(@(y,U)(real(y*conj(y)/U)),y,U); % Auto spectrum.

% reassign in-place when requested.
if reassign
    Sxx = signal.internal.spectral.reassignSpectrum(Sxx, f, t, fcorr, tcorr, options);
end

% Compute the one-sided or two-sided PSD [Power/freq]. Also compute
% the corresponding half or whole power spectrum [Power].
[Pxx,f] = computepsd(Sxx, f, options.range, nfft, Fs, esttype);

% remove low-power estimates if requested
if threshold>0
    Pxx = arrayfun(@FlushToZero,Pxx,threshold);
end

% -------------------------------------------------------------------------
function [Pxx] = FlushToZero(Pxx, threshold)
%     Pxx(Pxx<threshold) = 0;
if Pxx < threshold
    Pxx = 0;
end

% -------------------------------------------------------------------------
function [y,f,Pxx,fcorr,tcorr] = centerOutputs(nOut,y,f,Pxx,fcorr,tcorr)
% center y,fcorr,tcorr only if specified in the output list
% center f,Pxx if specified in the output list or when plotting
% nOut contains the number of output arguments of SPECTROGRAM
if nOut>0
    y = signal.internal.spectral.centerest(y);
end

if nOut==0 || nOut>1
    f = signal.internal.spectral.centerfreq(f);
end

if nOut==0 || nOut>3
    Pxx = signal.internal.spectral.centerest(Pxx);
end

if nOut>4
    fcorr = signal.internal.spectral.centerest(fcorr);
end

if nOut>5
    tcorr = signal.internal.spectral.centerest(tcorr);
end

% -------------------------------------------------------------------------
function varargout = nonConjugateTransposeOutputs(timeDimension,varargin)
% Non-conjugate transpose outputs if timeDimension is not the default
% value.

varargout = cell(1,nargout);
for i=1:nargin-1
    if strcmpi(timeDimension,'acrosscolumns')
        varargout{i} = varargin{i};
    else
        varargout{i} = varargin{i}.';
    end
end

% -------------------------------------------------------------------------
function [timeDimension,varargin] = getOutputTimeDimension(varargin)
timeDimension = 'acrosscolumns';

validStrings = {'acrosscolumns','downrows'};
i = 1;
while i<numel(varargin)
    if ischar(varargin{i}) ...
            && strncmpi(varargin{i},'OutputTimeDimension',strlength(varargin{i}))
        timeDimension = varargin{i+1};
        timeDimension = validatestring(timeDimension,validStrings,'spectrogram','OutputTimeDimension');
        varargin([i i+1]) = [];
    else
        i = i+1;
    end
end

% -------------------------------------------------------------------------
function [threshold,varargin] = getMinThreshold(varargin)
threshold = 0;

i = 1;
while i<numel(varargin)
    if ischar(varargin{i}) && strncmpi(varargin{i},'MinThreshold',strlength(varargin{i}))...
            && isnumeric(varargin{i+1}) && isscalar(varargin{i+1})
        threshold = 10^(varargin{i+1}/10);
        varargin([i i+1]) = [];
    else
        i = i+1;
    end
end

% -------------------------------------------------------------------------
function [faxisloc,varargin] = getFreqAxisOption(varargin)
faxisloc = 'xaxis';
i = 1;
while i <= numel(varargin)
    if ischar(varargin{i}) && strncmpi(varargin{i},'xaxis',strlength(varargin{i}))
        faxisloc = 'xaxis';
        varargin(i)=[];
    elseif ischar(varargin{i}) && strncmpi(varargin{i},'yaxis',strlength(varargin{i}))
        faxisloc = 'yaxis';
        varargin(i)=[];
    else
        i = i+1;
    end
end

% -------------------------------------------------------------------------
function [reassign,varargin] = getReassignmentOption(varargin)
reassign = false;

i = 1;
while i <= numel(varargin)
    if ischar(varargin{i}) && strncmpi(varargin{i},'reassigned',strlength(varargin{i}))
        reassign = true;
        varargin(i)=[];
    else
        i = i+1;
    end
end

%--------------------------------------------------------------------------
function [Fs,nfft,isnormfreq,options] = processFrequencyOptions(options,reassign)
% Determine whether an empty was specified for Fs (i.e., Fs=1Hz) or
% returned by welchparse which means normalized Fs is used.

% Cast to enforce Precision rules

Fs = double(options.Fs);
nfft = double(options.nfft);

% when Fs is specified as [], welchparse() returns 1 Hz.
% welchparse() returns nan only when Fs is omitted
isnormfreq = isnan(Fs);
if isnormfreq
    Fs = 2*pi;
end

if length(nfft) > 1
    % Frequency vector was specified, return and plot two-sided PSD
    if strcmpi(options.range,'onesided')
        warning(message('signal:welch:InconsistentRangeOption'));
    end
    options.range = 'twosided';
end

% prevent unneeded temporary conversion to one-sided spectrum
if options.centerdc
    options.range = 'twosided';
end

% ensure frequency vector is linearly spaced when performing reassignment
if reassign && ~isscalar(options.nfft)
    f = gpuArray(reshape(options.nfft,[],1));
    
    % Check if uniformly spaced
    [~, ~, ~, maxerr] = signal.internal.spectral.getUniformApprox(f);
    isuniform = maxerr < 3*eps(signalwavelet.internal.typeof(f));
    
    if ~isuniform
        error(message('signal:spectrogram:ReassignFreqMustBeUniform'));
    end
end

% -------------------------------------------------------------------------
function [y,f,fcorr,tcorr]  = formatSpectrogram(y,f,fcorr,tcorr,Fs,nfft,options)
% truncate output and adjust any time-frequency corrections based on
% FREQRANGE spectrum format ('centered', 'onesided', 'twosided')

% if nfft is a scalar, it is the length of the fft, otherwise it contains
% the output frequency vector
freqvecspecified = length(nfft)>1;

% truncate output when using one-sided spectrum
if ~freqvecspecified && strcmpi(options.range,'onesided')
    f = cast(psdfreqvec('npts',nfft,'Fs',Fs,'Range','half'),'like',f);
    y = head(y,length(f));
    if ~isempty(fcorr)
        fcorr = head(fcorr,length(f));
    end
    if ~isempty(tcorr)
        tcorr = head(tcorr,length(f));
    end
end

if ~isempty(fcorr)
    if options.centerdc || freqvecspecified && any(nfft < 0)
        % map to [-Fs/2,Fs/2) when using negative frequencies
        fcorr = mod(fcorr+Fs/2,Fs)-Fs/2;
    else
        % map to [0,Fs) when using positive frequencies
        fcorr = mod(fcorr,Fs);
    end
end

%--------------------------------------------------------------------------
function [fcorr,tcorr] = computeReassign(xin,win,Fs,nfft,y,f,t,reassign,narg)
% Compute the reassignment time and frequency matrices fcorr and tcorr
if reassign || narg>4
    % Apply frequency correction from time derivative window
    t_win = gpuArray(signal.internal.spectral.dtwin(gather(win),Fs)); % DTWIN not supported on the GPU
    tc_win = t_win.*xin;
    yc = computeDFT(tc_win,nfft,Fs);
    fcorr = arrayfun(@freqCorrect,yc,y,f);
else
    fcorr = zeros([0,0],'like',f);
end

if reassign || narg>5
    % Apply time correction from frequency derivative window
    fc_win = signal.internal.spectral.dfwin(win,Fs).*xin;
    yc = computeDFT(fc_win,nfft,Fs);
    tcorr = arrayfun(@timeCorrect,yc,y,t);
else
    tcorr = zeros([0,0],'like',t);
end

%--------------------------------------------------------------------------
function [fcorr] = freqCorrect(yc,y,f)
% Apply frequency correction from time derivative window

fcorr = -imag(yc / y);
if ~isfinite(fcorr)
    fcorr = zeros("like",f);
end
fcorr = fcorr+f;

%--------------------------------------------------------------------------
function [tcorr] = timeCorrect(yc,y,t)
% Apply time correction from time derivative window

tcorr = real(yc / y);
if ~isfinite(tcorr)
    tcorr = zeros("like",t);
end
tcorr = tcorr+t;