function [r, harmPow, harmFreq] = thd(varargin)
%THD    Total Harmonic Distortion
%   R = THD(X) computes the total harmonic distortion (THD), in dBc, of the
%   real sinusoidal input signal X.  The computation is performed over a
%   periodogram of the same length as the input using a Kaiser window and
%   includes the first six harmonics (including the fundamental).
%
%   R = THD(X, Fs, N) specifies the sampling rate, Fs, and number of
%   harmonics, N, to consider when computing THD.  The default value
%   of Fs is 1.  The default value of N is 6 and includes the fundamental
%   frequency.
%
%   R = THD(Pxx, F, 'psd') specifies the input as a one-sided PSD estimate,
%   Pxx, of a real signal.   F is a vector of frequencies that corresponds
%   to the vector of Sxx estimates.
%
%   R = THD(Pxx, F, N, 'psd') specifies the number of harmonics, N,
%   to include when computing THD.  The default value of N is 6 and
%   includes the fundamental frequency.
%
%   R = THD(Sxx, F, RBW, 'power') specifies the input as a one-sided power
%   spectrum, Sxx, of a real signal.  RBW is the resolution bandwidth over
%   which each power estimate is integrated.
%
%   R = THD(Sxx, F, RBW, N, 'power') specifies the number of harmonics, N,
%   to include when computing THD.  The default value of N is 6 and
%   includes the fundamental frequency.
%
%   [R, HARMPOW, HARMFREQ] = THD(...) also returns the power, HARMPOW,
%   and frequencies, HARMFREQ, of all harmonics (including the fundamental).
%
%   [...] = THD(...,'aliased') also considers harmonics of the fundamental
%   aliased into the Nyquist range.  Use this option when the input signal
%   is undersampled.  If unspecified or 'omitaliases' is used instead,
%   harmonics of the fundamental frequency are ignored beyond Nyquist.
%
%   THD(...) with no output arguments plots the spectrum of the signal and
%   annotates the harmonics in the current figure window.  The DC and noise
%   terms are also plotted.  The DC component is removed before computing
%   THD.
%
%   % Example 1:
%   %   Plot the THD of a 2.5 kHz distorted sinusoid sampled at 48 kHz
%   load('sineex.mat','x','Fs');
%   thd(x,Fs)
%
%   % Example 2:
%   %   Generate the periodogram of a 2.5 kHz distorted sinusoid sampled
%   %   at 48 kHz and compute the THD
%
%   load('sineex.mat','x','Fs');
%   w = kaiser(numel(x),38);
%   [Sxx, F] = periodogram(x,w,numel(x),Fs,'power');
%
%   % compute THD via a power spectrum
%   rbw = enbw(w,Fs);
%   [sineTHD, hPower, hFreq] = thd(Sxx,F,rbw,'power')
%
%   % plot and annotate the spectrum
%   thd(Sxx,F,rbw,'power')
%
%   See also SFDR SINAD SNR TOI.

%   Copyright 2013-2019 The MathWorks, Inc.

%#codegen

narginchk(1,5);

inputArgs = cell(1,length(varargin));
[inputArgs{:}] = convertStringsToChars(varargin{:});

if coder.target('MATLAB') % for MATLAB execution
    
    % look for psd or power window compensation flags
    [esttype, Args, ~] = signal.internal.psdesttype({'psd','power','time'},'time',inputArgs);
    
    % allow undersampled harmonics when 'aliased' is specified
    [harmType, Args] = getmutexclopt({'aliased','omitaliases'},'omitaliases',Args);
    
else % for code generation
    
    % look for psd or power window compensation flags and find their index
    % in the input argument list
    [esttype, estIdx] = localInputParser({'psd','power','time'},'time',inputArgs);
    
    % look for aliased or omit aliases options and find their index in the
    % input argument list
    [harmType, harmIdx] = localInputParser({'aliased','omitaliases'},'omitaliases',inputArgs);
    
    % remove the above string options, if present, from the input argument
    % list
    if (estIdx~=0) && (harmIdx~=0)
        Args = cell(1,length(inputArgs)-2);
        if estIdx < harmIdx
            [Args{:}] = inputArgs{[1:(estIdx-1), (estIdx+1):(harmIdx-1), (harmIdx+1):end]};
        else
            [Args{:}] = inputArgs{[1:(harmIdx-1), (harmIdx+1):(estIdx-1), (estIdx+1):end]};
        end
    elseif (estIdx~=0) && (harmIdx==0)
        Args = cell(1,length(inputArgs)-1);
        [Args{:}] = inputArgs{[1:(estIdx-1), (estIdx+1):end]};
    elseif (estIdx==0) && (harmIdx~=0)
        Args = cell(1,length(inputArgs)-1);
        [Args{:}] = inputArgs{[1:(harmIdx-1), (harmIdx+1):end]};
    else
        Args = inputArgs;
    end
    
end

% check for unrecognized strings
chknostropts(Args{:});

% plot if no arguments are specified
plotType = distplottype(nargout, esttype);

switch esttype
    case 'psd'
        [r, harmPow, harmFreq] = psdTHD(plotType, harmType, Args{:});
    case 'power'
        [r, harmPow, harmFreq] = powerTHD(plotType, harmType, Args{:});
    case 'time'
        [r, harmPow, harmFreq] = timeTHD(plotType, harmType, Args{:});
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [r, harmPow, harmFreq] = timeTHD(plotType, harmType, x, fs, nHarm)

% force column vector before checking attributes
if length(x) == numel(x)
    colX = x(:);
else
    colX = x;
end

validateattributes(colX,{'single','double'},{'real','finite','vector'}, ...
    'thd','X',1);

if nargin > 3
    validateattributes(fs, {'numeric'},{'real','finite','scalar','positive'}, ...
        'thd','Fs',2);
    fsScalar = double(fs(1));
else
    fsScalar = 1;
end

if nargin > 4
    validateattributes(nHarm,{'numeric'},{'integer','finite','positive','scalar','>',1}, ...
        'thd','N',3);
    nHarmScalar = double(nHarm(1));
else
    nHarmScalar = 6;
end

% remove DC component
colX = colX(:,1) - mean(colX(:,1));

n = length(colX);

% use Kaiser window to reduce effects of leakage
w = kaiser(n,38);
rbw = enbw(w, fsScalar);
[Pxx, F] = periodogram(colX,w,n,fsScalar,'psd');

% specify sample rate for aliased harmonics (assume same as Fs)
if strcmp(harmType, 'aliased')
    aliasFs = fsScalar;
else
    aliasFs = NaN;
end

[r, harmPow, harmFreq] = computeTHD(plotType, Pxx, F, rbw, nHarmScalar, aliasFs);

end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [r, harmPow, harmFreq] = powerTHD(plotType, harmType, Sxx, F, rbw, nHarm)

validateattributes(Sxx, {'single','double'},...
    {'real','finite','nonnegative','vector'}, 'thd', 'Sxx', 1);
validateattributes(F, {'single','double'},...
    {'real','finite','vector'}, 'thd', 'F', 2);

coder.internal.assert(F(1)==0,'signal:thd:MustBeOneSidedSxx');

% ensure specified RBW is larger than a bin width
df = mean(diff(F));

validateattributes(rbw,{'numeric'},{'real','finite','positive','scalar','>=',df}, ...
    'thd','RBW',3);
rbwScalar = double(rbw(1));

if nargin > 5
    validateattributes(nHarm,{'numeric'},{'integer','finite','positive','scalar','>',1}, ...
        'thd','N',4);
    nHarmScalar = double(nHarm(1));
else
    nHarmScalar = 6;
end

% assume frequency transform is from an even-length input when
% undersampling harmonics (i.e. F(end) = Fs/2)
if strcmp(harmType, 'aliased')
    aliasFs = 2*F(end);
else
    aliasFs = NaN;
end

[r, harmPow, harmFreq] = computeTHD(plotType, Sxx/rbwScalar, F, rbwScalar, nHarmScalar, aliasFs);
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [r, harmPow, harmFreq] = psdTHD(plotType, harmType, Pxx, F, nHarm)

validateattributes(Pxx, {'single','double'},...
    {'real','finite','nonnegative','vector'}, 'thd', 'Pxx', 1);
validateattributes(F, {'single','double'},...
    {'real','finite','vector'}, 'thd', 'F', 2);

coder.internal.assert(F(1)==0,'signal:thd:MustBeOneSidedPxx');

if nargin > 4
    validateattributes(nHarm,{'numeric'},{'integer','finite','positive','scalar','>',1}, ...
        'thd','N',3);
    nHarmScalar = double(nHarm(1));
else
    nHarmScalar = 6;
end

% assume frequency transform is from an even-length input when
% undersampling harmonics (i.e. F(end) = Fs/2)
if strcmp(harmType, 'aliased')
    aliasFs = 2*F(end);
else
    aliasFs = NaN;
end

[r, harmPow, harmFreq] = computeTHD(plotType, Pxx, F, mean(diff(F)), nHarmScalar, aliasFs);
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [r, harmPow, harmFreq] = computeTHD(plotType, Pxx, F, rbw, nHarm, aliasFs)

% save a copy of the original PSD estimates
origPxx = Pxx;

% pre-allocate harmonic table
harmPow = NaN(nHarm,1,'like',Pxx);
harmFreq = NaN(nHarm,1,'like',Pxx);
psdHarmPow = NaN(nHarm,1);
psdHarmFreq = NaN(nHarm,1);
harmIdx = NaN(nHarm, 2);

% bump DC component by 3dB and remove it.
Pxx(1) = 2*Pxx(1);
[~, ~, ~, iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw, 0);
if ~isempty(iLeft) && ~isempty(iRight)
    Pxx(iLeft(1):iRight(1)) = 0;
end
dcIdx = [iLeft; iRight];

% get an estimate of the actual frequency / amplitude
[Pfund, Ffund, iFund, iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw);
[psdHarmPow(1), psdHarmFreq(1)] = idx2psddb(Pxx, F, iFund);
harmPow(1) = Pfund;
harmFreq(1) = Ffund;
if ~isempty(iLeft) && ~isempty(iRight)
    harmIdx(1, :) = [iLeft(1); iRight(1)];
end

harmSum = zeros(1,1,'like',Pxx);
for i=2:nHarm
    toneFreq = i*Ffund;
    if isfinite(aliasFs)
        toneFreq = aliasToNyquist(i*Ffund, aliasFs);
    end
    [harmPow(i), harmFreq(i), iHarm, iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw, toneFreq);
    [psdHarmPow(i), psdHarmFreq(i)] = idx2psddb(Pxx, F, iHarm);
    % obtain local maximum value in neighborhood of bin
    if ~isnan(harmPow(i))
        harmSum = harmSum + harmPow(i);
        if ~isempty(iLeft) && ~isempty(iRight)
            harmIdx(i, :) = [iLeft(1); iRight(1)];
        end
    end
end

r = 10*log10(harmSum / harmPow(1));
harmPow = 10*log10(harmPow);

if ~strcmp(plotType,'none')
    coder.internal.assert(coder.target('MATLAB'),'signal:thd:PlottingNotSupported');
    plotTHD(origPxx, F, rbw, plotType, psdHarmFreq, psdHarmPow, dcIdx, harmIdx);
    title(getString(message('signal:thd:THDResult',sprintf('%6.2f',r))));
end
end

function toneF = aliasToNyquist(f, fs)

toneF1 = mod(f,fs);
if toneF1 > fs/2
    toneF = fs-toneF1;
else
    toneF = toneF1;
end

end

function plotTHD(Pxx, F, rbw, plotType, psdHarmFreq, psdHarmPow, dcIdx, harmIdx)
% scale Pxx by rbw
Pxx = Pxx * rbw;
psdHarmPow = psdHarmPow + 10*log10(rbw);

% initialize distortion plot
[hAxes, F, fscale, colors] = initdistplot(plotType, F);

% --- plot legend entries ---

% plot fundamental
xData = F(harmIdx(1,1):harmIdx(1,2));
yData = 10*log10(Pxx(harmIdx(1,1):harmIdx(1,2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(1,:));

haveHarmonics = false;
% plot first available harmonic
for i=2:size(harmIdx,1)
    if ~any(isnan(harmIdx(i,:)))
        xData = F(harmIdx(i,1):harmIdx(i,2));
        yData = 10*log10(Pxx(harmIdx(i,1):harmIdx(i,2)));
        line(xData, yData, 'Parent', hAxes,'Color', colors(2,:));
        haveHarmonics = true;
        break
    end
end

% plot dc
xData = F(dcIdx(1):dcIdx(2));
yData = 10*log10(Pxx(dcIdx(1):dcIdx(2)));
line(xData, yData, 'Parent', hAxes,'Color', colors(3,:));

% --- use a solid grid slightly offset to accommodate text labels ---
initdistgrid(hAxes);

% --- replot the items on top of the grid ---

% plot fundamental marker
xData = psdHarmFreq(1)*fscale;
yData = psdHarmPow(1);

text(double(xData(1)),double(yData(1)),'F', ...
    'VerticalAlignment','bottom', ...
    'HorizontalAlignment','center', ...
    'BackgroundColor', 'w', ...
    'EdgeColor', 'k', ...
    'Color', colors(1,:));

% plot harmonic markers
xData = double(psdHarmFreq(2:end)*fscale);
yData = double(psdHarmPow(2:end));
for i=1:numel(xData)
    text(xData(i),yData(i),num2str(i+1), ...
        'VerticalAlignment','bottom', ...
        'HorizontalAlignment','center', ...
        'BackgroundColor', 'w', ...
        'EdgeColor', 'k', ...
        'Color', colors(2,:));
end

% replot dc and noise line
xData = F;
yData = 10*log10(Pxx);
line(xData, yData, 'Parent', hAxes, 'Color', colors(3,:));

% replot fundamental
xData = F(harmIdx(1,1):harmIdx(1,2));
yData = 10*log10(Pxx(harmIdx(1,1):harmIdx(1,2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(1,:));

% replot harmonics
for i=2:size(harmIdx,1)
    if ~any(isnan(harmIdx(i,:)))
        xData = F(harmIdx(i,1):harmIdx(i,2));
        yData = 10*log10(Pxx(harmIdx(i,1):harmIdx(i,2)));
        line(xData, yData, 'Parent', hAxes,'Color', colors(2,:));
    end
end

if haveHarmonics
    legend(getString(message('signal:thd:Fundamental')), ...
        getString(message('signal:thd:Harmonics')), ...
        getString(message('signal:thd:DCAndNoise')), ...
        'Location','best');
else
    legend(getString(message('signal:thd:Fundamental')), ...
        getString(message('signal:thd:DCAndNoise')), ...
        'Location','best');
end
end

function [opt, idx] = localInputParser(validOpts,defaultOpt,arglist)

% Ensure any specified input string is a compile-time constant for code
% generation
coder.unroll();
for t = 1:numel(arglist)
    if ischar(arglist{t})
        coder.internal.assert(coder.internal.isConst(arglist{t}),...
            'signal:thd:FlagAsConst');
    end
end

found = false;
idx1 = 0;

coder.unroll();
for i = 1:numel(arglist)
    arg = arglist{i};
    coder.unroll();
    for j = 1:numel(validOpts)
        if ischar(arg) && strncmpi(arg,validOpts{j},length(arg))
            if ~found
                found = true;
                opt1 = validOpts{j};
                idx1 = i;
                break;
            end
            coder.internal.assert(~found,...
                'signal:thd:ConflictingOptions',opt1,validOpts{j});
        end
    end
end

if ~found
    opt = defaultOpt;
    idx = 0;
else
    opt = opt1;
    idx = idx1;
end

end
% LocalWords:  Bc Fs Pxx Sxx RBW HARMPOW HARMFREQ undersampled omitaliases
% LocalWords:  sineex rbw enbw SINAD TOI undersampling replot