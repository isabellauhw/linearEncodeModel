function varargout = fsst(x,varargin)
%FSST Fourier synchrosqueezed transform on GPU.
%
%   SST = FSST(X)
%   SST = FSST(X,FS)
%   SST = FSST(X,TS)
%   SST = FSST(...,WINDOW)
%   SST = FSST(...,FREQLOCATION)
%   [SST,F,T] = FSST(...)
%   FSST(...)

%   Copyright 2020 The MathWorks, Inc.

narginchk(1,4);

%---------------------------------
% Check x and window input (if it exists) to see if they are gpuArrays.
gpuFlag = false;

if isa(x,"gpuArray")
    gpuFlag = true;
elseif nargin > 2
    if isa(varargin{2},"gpuArray") && isnumeric(varargin{2}) && (numel(varargin{2}) > 1)
        gpuFlag = true;
        x = gpuArray(x);        
    end
end
   
%---------------------------------
% Dispatch to in-memory FSST if gpuFlag false.
if ~gpuFlag 
    [varargin{:}] = gather(varargin{:});
    varargout = cell(1,nargout);
    [varargout{:}] = fsst(x,varargin{:});
    return;
end
 
%---------------------------------
% Parse inputs. Fs is populated as used throughout the bulk of the code
% even if Ts is specified. fNorm specifies normalized frequencies.
[varargin{:}] = convertStringsToChars(varargin{:});
[Fs,Ts,win,fNorm,freqloc] = signal.internal.fsst.fsstParser(x,varargin{:});
win = gpuArray(win); % send to gpuArray if not already there.

%---------------------------------
% Parameters based on window size - noverlap is fixed so the transform is
% invertible.
nwin = length(win);
nfft = nwin;
noverlap = nwin-1;

%---------------------------------
% Convert inputs to column vectors
x = reshape(x,[],1);
win = reshape(win,[],1);

%---------------------------------
% Cast to enforce precision rules
if (isaUnderlying(x,"single") || isaUnderlying(win,"single"))
    x = single(x);
    win = single(win);
end

realX = real(subsref(x, substruct('()', {[]}))); % empty array for type casting

%---------------------------------
% Zero pad input signal
if signalwavelet.internal.isodd(nwin)
    x = [zeros((nwin-1)/2,1,"like",x) ; x ; zeros((nwin-1)/2,1,"like",x)];
else
    x = [zeros((nwin)/2,1,"like",x) ; x ; zeros((nwin-2)/2,1,"like",x)];
end

%---------------------------------
% Place padded signal into columns for the STFT
[xin,t] = parallel.internal.gpu.extractWindows(x,nwin,noverlap,1);
if fNorm
    t = t - (nwin/2) + 1; % offset normalised output time vector
else
    t = (t - (nwin/2))./Fs; % offset output time vector
end

%---------------------------------
% Compute the STFT
[sst,f] = computeDFT(win.*xin,nfft,Fs);
dwin = signal.internal.spectral.dtwin(gather(win),Fs); % use in-memory for dtwin
stftc = computeDFT(dwin.*xin,nfft,Fs);

%---------------------------------
% Compute the reassignment vector
f = cast(f,"like",realX);
fcorr = arrayfun(@freqCorrect,stftc,sst,f);
tcorr = t + zeros(size(fcorr),"like",t);  % using implict expansion

%---------------------------------
% Multiply STFT by a linear phase shift to produce the modified STFT
m = floor(nwin/2);
inds = (0:nfft-1); 
ez = exp(-1i*2*pi*m*inds/nfft)';
sst = ez.*sst; % using implicit expansion

%---------------------------------
% Reassign the modified STFT
options.range = "twosided";
options.nfft = nfft;
sst = signal.internal.spectral.reassignSpectrum(sst, f, t, fcorr, tcorr, options);

% Reduce to one-sided spectra if the input is real, otherwise return a
% two-sided (centered) spectra.
if isreal(x)
    f = psdfreqvec("npts",nfft,"Fs",Fs,"Range","half");
    sst = head(sst, length(f));
    f = cast(f,"like",realX);
else
    % Centered spectra
    sst = signal.internal.spectral.centerest(sst);
    f = signal.internal.spectral.centerfreq(f);
end

%---------------------------------
% Scale fout and tout if the input is a duration object
if ~isempty(Ts)   
    [~,units,timeScale] = signal.internal.fsst.getFSSTDurationAndUnits(Ts);
    t = t*timeScale;
    f = f/timeScale;
else
    units = [];
end

if nargout == 0
    [sst,f,t] = gather(sst,f,t); % gather for plotting
    if ~isempty(units)  
        switch units
            case "sec"
                signal.internal.fsst.plotFSST(seconds(t),f,sst,fNorm,freqloc);
            case "min"
                signal.internal.fsst.plotFSST(minutes(t),f,sst,fNorm,freqloc);
            case "hr"
                signal.internal.fsst.plotFSST(hours(t),f,sst,fNorm,freqloc);
            case "day"
                signal.internal.fsst.plotFSST(days(t),f,sst,fNorm,freqloc);
            case "year"
                signal.internal.fsst.plotFSST(years(t),f,sst,fNorm,freqloc);
        end
    else
        signal.internal.fsst.plotFSST(t,f,sst,fNorm,freqloc);
    end
else
    outputs = {sst,f,t};
    varargout = outputs(1:nargout);
end

%--------------------------------------------------------------------------
function fcorr = freqCorrect(yc,y,f)
% Apply frequency correction from time derivative window

fcorr = -imag(yc./y);
if ~isfinite(fcorr)
    fcorr = zeros("like",f);
end
fcorr = fcorr + f; % Note this uses implicit expansion


% LocalWords:  synchrosqueezed Fs FREQLOCATION xaxis yaxis fs stft YDir mtlb
% LocalWords:  ifsst tfridge Colto Vec noverlap xp npts fout Freqloc nonsparse
% LocalWords:  nonnan mins signalwavelet convenienceplot TFR
