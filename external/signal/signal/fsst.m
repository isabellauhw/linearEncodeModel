function [sst,f,t] = fsst(x,varargin)
%FSST Fourier synchrosqueezed transform
%   SST = FSST(X) returns the Fourier synchrosqueezed transform of X. Each
%   column of SST contains the synchrosqueezed spectrum of a windowed
%   segment of X. The number of columns of SST is equal to the number of
%   samples of the input X, which is padded with zeros on each side. Each
%   spectrum is one-sided for real X and two-sided and centered for complex
%   X. By default, a Kaiser window of length 256 and a beta of 10 is used.
%   If X has fewer than 256 samples, then the Kaiser window has the same
%   length as X.
%
%   [SST,W,S] = FSST(X) returns a vector of normalized frequencies, W,
%   corresponding to the rows of SST, and a vector of sample numbers, S,
%   corresponding to the columns of SST. Each element of S is the sample
%   number of the midpoint of a windowed segment of X.
%
%   [SST,F,T] = FSST(X,Fs) specifies the sampling frequency, Fs, in hertz,
%   as a positive scalar. The output contains sample times, T, expressed in
%   seconds and frequencies, F, expressed in hertz.
%
%   [SST,F,T] = FSST(X,Ts) specifies the sampling interval, Ts, as a
%   <a href="matlab:help duration">duration</a>. Ts is the time between samples of X. T has the same units
%   as the duration. The units of F are in cycles/unit time of the
%   duration.
%
%   [...] = FSST(X,...,WINDOW) when WINDOW is a vector, divides X into
%   segments of the same length as WINDOW and then multiplies each segment
%   by WINDOW.  If WINDOW is an integer, a Kaiser window with length WINDOW
%   and a beta of 10 is used. If WINDOW is not specified, the default
%   Kaiser window is used.
%
%   FSST(...) with no output arguments plots the synchrosqueezed transform
%   of the input vector x on the current figure.
%
%   FSST(...,FREQLOCATION) controls where MATLAB displays the frequency
%   axis on the plot. This string can be either 'xaxis' or 'yaxis'.
%   Setting FREQLOCATION to 'yaxis' displays frequency on the y-axis and
%   time on the x-axis.  The default is 'xaxis', which displays frequency
%   on the x-axis. FREQLOCATION is ignored when output arguments are
%   specified.
%
%   % Example 1:
%   %   Compute and plot the Fourier synchrosqueezed transform (SST) of a
%   % signal that consists of two chirps.
%   fs = 3000;
%   t = 0:1/fs:1-1/fs;
%   x1 = 2*chirp(t,500,t(end),1000);
%   x2 = chirp(t,400,t(end),800);
%   fsst(x1+x2,fs,'yaxis')
%   title('Magnitude of Fourier Synchrosqueezed Transform of Two Chirps')
%
%   % Compute and plot the short-time Fourier transform.
%   [stft,f,t] = spectrogram(x1+x2,kaiser(256,10),255,256,fs);
%   figure
%   h = imagesc(t,f,abs(stft));
%   xlabel('Time (s)')
%   ylabel('Frequency (Hz)')
%   title('Magnitude of Short-time Fourier Transform of Two Chirps')
%   h.Parent.YDir = 'normal';
%
%   % Example 2
%   %   Compute the Fourier synchrosqueezed transform of a speech signal.
%   load mtlb
%   fsst(mtlb,Fs,hann(256),'yaxis')
%
%   See also ifsst, tfridge, spectrogram, duration.

% Copyright 2015-2020 The MathWorks, Inc.
%#codegen

coder.gpu.kernelfun;

narginchk(1,4);
nargoutchk(0,3);

isInMATLABorMEX = coder.target('MATLAB') || coder.target('MEX');

inputArgs = cell(size(varargin));

if nargin > 1
    [inputArgs{:}] = convertStringsToChars(varargin{:});
else
    inputArgs = varargin;
end

% Parse inputs. Fs is populated as used throughout the bulk of the code
% even if Ts is specified. fNorm specifies normalized frequencies.
[Fs,Ts,win,fNorm,freqloc] = signal.internal.fsst.fsstParser(x,inputArgs{:});

% Parameters based on window size - noverlap is fixed so the transform is
% invertible.
nwin = length(win);
nfft = nwin;
noverlap = nwin-1;

% Convert to column vectors
x = signal.internal.toColIfVect(x);
win = win(:);
Fs = Fs(1);

isSingle = isa(x,'single') || isa(win,'single');

if isSingle
    convFact = 'single';
else
    convFact = 'double';
end

% Compute the output time vector (one time per sample point of the input)
if fNorm
    tout = cast(1:length(x),convFact);
else
    tout = cast((0:length(x)-1)/Fs,convFact);
end

% cast to enforce precision rules
if isSingle
    x = single(x);
    win1 = single(win);
else
    win1 = win;
end

% Pad the signal vector x
if isodd(nwin)
    xp = [zeros((nwin-1)/2,1) ; x ; zeros((nwin-1)/2,1)];
else
    xp = [zeros((nwin)/2,1) ; x ; zeros((nwin-2)/2,1)];
end

nxp = length(xp);

if coder.gpu.internal.isGpuEnabled && ~coder.internal.isConstantFolding
    % GPU Code
    xin = getFSSTColumns_gpu(xp,nxp,nwin,noverlap,Fs,win1,nfft);
    [sstout,fout] = computeFFT(xin,nfft,Fs);
    stftc = sstout(:,size(sstout,2)/2+1:end,:);
    sstout = sstout(:,1:size(sstout,2)/2,:);
else
    % Place xp into columns for the STFT
    xin = signal.internal.stft.getSTFTColumns(xp,nxp,nwin,noverlap,Fs);
    % Compute the STFT
    [sstout,fout] = computeDFT(bsxfun(@times,win1,xin),nfft,Fs);
    fout = cast(fout,convFact);
    stftc = computeDFT(bsxfun(@times,signal.internal.spectral.dtwin(win1,Fs),xin),nfft,Fs);
end

% Compute the reassignment vector
if coder.gpu.internal.isGpuEnabled && ~coder.internal.isConstantFolding
    % GPU Code
    fcorr = coder.nullcopy(zeros(size(stftc),'like',tout));
    tcorr = coder.nullcopy(zeros(size(stftc),'like',tout));
    coder.gpu.kernel
    for dim2 = 1:size(fcorr,2)
        coder.gpu.kernel
        for dim1 = 1:size(fcorr,1)
            tempVal = -imag(stftc(dim1,dim2)/sstout(dim1,dim2));
            if ~isfinite(tempVal)
                tempVal = cast(0,'like',tout);
            end
            fcorr(dim1,dim2) = tempVal + fout(dim1);
            tcorr(dim1,dim2) = tout(1,dim2);
        end
    end
else
    fcorr = -imag(stftc./ sstout);
    fcorr(~isfinite(fcorr)) = 0;
    fcorr = bsxfun(@plus,fout,fcorr);
    tcorr = bsxfun(@plus,tout,zeros(size(fcorr)));
end

% Multiply STFT by a linear phase shift to produce the modified STFT
m = floor(nwin/2);
inds = 0:nfft-1;
ez = exp(-1i*2*pi*m*inds/nfft)';
sstout = bsxfun(@times,sstout,ez);

% Reassign the modified STFT
options.range = 'twosided';
options.nfft = nfft;
sstout = signal.internal.spectral.reassignSpectrum(sstout, fout, tout, fcorr, tcorr, options);

% Reduce to one-sided spectra if the input is real, otherwise return a
% two-sided (centered) spectra.
if isreal(x)
    fout = psdfreqvec('npts',nfft,'Fs',Fs,'Range','half');
    fout = cast(fout,convFact);
    sstout = sstout(1:length(fout),:);
else
    % Centered spectra
    sstout = signal.internal.spectral.centerest(sstout);
    fout = signal.internal.spectral.centerfreq(fout);
end

% Scale fout and tout if the input is a duration object
if ~isempty(Ts)
    [~,units,timeScale] = signal.internal.fsst.getFSSTDurationAndUnits(Ts);
    tout = tout*timeScale;
    fout = fout/timeScale;
elseif ~(coder.gpu.internal.isGpuEnabled && ~coder.internal.isConstantFolding)
    units = [];
end

if nargout == 0 && ~(coder.gpu.internal.isGpuEnabled && ~coder.internal.isConstantFolding)
    % Plotting is supported only for MATLAB and MEX targets
    coder.internal.assert(isInMATLABorMEX,'signal:fsst:PlottingNotSupported');
    
    if ~isempty(units)
        switch units
            case 'sec'
                signal.internal.fsst.plotFSST(seconds(tout),fout,sstout,fNorm,freqloc);
            case 'min'
                signal.internal.fsst.plotFSST(minutes(tout),fout,sstout,fNorm,freqloc);
            case 'hr'
                signal.internal.fsst.plotFSST(hours(tout),fout,sstout,fNorm,freqloc);
            case 'day'
                signal.internal.fsst.plotFSST(days(tout),fout,sstout,fNorm,freqloc);
            case 'year'
                signal.internal.fsst.plotFSST(years(tout),fout,sstout,fNorm,freqloc);
        end
    else
        signal.internal.fsst.plotFSST(tout,fout,sstout,fNorm,freqloc);
    end
else
    sst = sstout;
    f = fout;
    t = tout(:)';
end



% Function to create FSST matrices (for GPU Codegen)
function xin = getFSSTColumns_gpu(x,nx,nwin,noverlap,Fs,win1,nfft)
% getFSSTColumns_gpu creates the fsst matrices.

%#codegen
coder.gpu.kernelfun;
% Determine the number of columns of the STFT output (i.e., the S output)
classCast = class(x);
numChannels = size(x,2);
numSample = size(x,1);
ncol = fix((nx-noverlap)/(nwin-noverlap));
nsamp = nwin-noverlap;
win2 = signal.internal.spectral.dtwin(win1,Fs);

xin = coder.nullcopy(zeros(nfft,2*ncol,numChannels,'like', x));
% Populate the fft matrix
coder.gpu.kernel;
for iCh = 1:numChannels
    for icol = 1:ncol
        for ielem = 1:nfft
            if ielem <= nwin
                xVal = x((((icol-1)*nsamp) + ielem),iCh);
                xin(ielem, icol,iCh) = xVal.*win1(ielem);
                xin(ielem, icol+ncol,iCh) = xVal.*win2(ielem);
            else
                xin(ielem, icol,iCh) = cast(0, 'like',x);
                xin(ielem, icol+ncol,iCh) = cast(0, 'like',x);
            end
        end
    end
end

% Function to call FFT on the input (for GPU Codegen)
function [Xx,f] = computeFFT(xin,nfft,Fs)
%#codegen
coder.gpu.kernelfun;
Xx = fft(xin);
f = coder.nullcopy(zeros(nfft,1, 'like', real(xin)));
for idx = 1:nfft
    f(idx) = (Fs/nfft)*(idx-1);
end

% LocalWords:  synchrosqueezed Fs FREQLOCATION xaxis yaxis fs stft YDir mtlb
% LocalWords:  ifsst tfridge Colto Vec noverlap xp npts fout Freqloc nonsparse
% LocalWords:  nonnan mins signalwavelet convenienceplot TFR

