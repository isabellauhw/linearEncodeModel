function [r, totDistPow] = sinad(varargin)
%SINAD  Signal to Noise and Distortion ratio
%   R = SINAD(X) computes the signal to noise and distortion ratio (SINAD),
%   in dBc, of the real sinusoidal input signal X.  The computation is
%   performed over a periodogram of the same length as the input using a
%   Kaiser window.
%
%   R = SINAD(X, Fs) specifies the sampling rate, Fs.  The
%   default value of Fs is 1.
%
%   R = SINAD(Pxx, F, 'psd') specifies the input as a one-sided
%   PSD estimate, Pxx, of a real signal.  F is a vector of frequencies
%   that correspond to the PSD estimates.
%
%   R = SINAD(Sxx, F, RBW, 'power') specifies the input as a one-sided
%   power spectrum, Sxx, of a real signal.  RBW is the resolution bandwidth
%   over which each power estimate is integrated.
%
%   [R, TOTDISTPOW] = SINAD(...) also returns the total noise and harmonic
%   distortion power of the signal.
%
%   SINAD(...) with no output arguments plots the spectrum of the signal
%   and annotates the fundamental signal and noise.  The DC component is
%   removed before computing SINAD.
%
%   % Example 1:
%   %   Plot the SINAD ratio of a 2.5 kHz distorted sinusoid sampled
%   %   at 48 kHz
%   load('sineex.mat','x','Fs');
%   sinad(x,Fs)
%
%   % Example 2:
%   %   Generate the periodogram of a 2.5 kHz distorted sinusoid sampled
%   %   at 48 kHz and compute SINAD
%
%   % create the sinusoid and compute the power spectrum
%   load('sineex.mat','x','Fs');
%   w = kaiser(numel(x),38);
%   [Sxx, F] = periodogram(x,w,numel(x),Fs,'power');
%
%   % compute SINAD
%   rbw = enbw(w,Fs);
%   [sineSINAD, distPower] = sinad(Sxx, F, rbw, 'power')
%
%   % plot and annotate the spectrum
%   sinad(Sxx, F, rbw, 'power')
%
%   See also THD SFDR SNR TOI.

%   Copyright 2013-2019 The MathWorks, Inc.

%#codegen
narginchk(1,4);

inputArgs = cell(1,length(varargin));
[inputArgs{:}] = convertStringsToChars(varargin{:});

% Ensure any specified input string is a compile-time constant for code
% generation
coder.unroll();
for i = 1:numel(inputArgs)
    if ischar(inputArgs{i})
        coder.internal.assert(coder.internal.isConst(inputArgs{i}),...
            'signal:sinad:FlagAsConst');
    end
end

% look for psd or power window compensation flags
[esttype, Args1, estIdx] = signal.internal.psdesttype({'psd','power','time'},'time',inputArgs);

% update the variable 'Args1' for the case of code generation
if coder.target('MATLAB')
    Args = Args1;
elseif estIdx == 0
    Args = inputArgs;
else
    Args = cell(1,length(inputArgs)-1);
    [Args{:}] = inputArgs{[1:estIdx-1,estIdx+1:end]};
end

% check for unrecognized strings
chknostropts(Args{:});

% plot if no arguments are specified
plotType = distplottype(nargout, esttype);

switch esttype
    case 'psd'
        [r, totDistPow] = psdSINAD(plotType, Args{:});
    case 'power'
        [r, totDistPow] = powerSINAD(plotType, Args{:});
    case 'time'
        [r, totDistPow] = timeSINAD(plotType, Args{:});
end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [r, totDistPow] = timeSINAD(plotType, x, fs)

% force column vector before checking attributes
if max(size(x)) == numel(x)
    colX = x(:);
else
    colX = x;
end

validateattributes(colX,{'single','double'},{'real','finite','vector'}, ...
    'sinad','X',1);

if nargin > 2
    validateattributes(fs, {'numeric'},{'real','finite','scalar','positive'}, ...
        'sinad','Fs',2);
else
    fs = 1;
end

fsScalar = double(fs(1));
n = length(colX);
% remove DC component
colX = colX(:,1) - mean(colX(:,1));

% use Kaiser window to reduce effects of leakage
w = kaiser(n,38);
rbw = enbw(w,fsScalar);
[Pxx, F] = periodogram(colX,w,n,fsScalar,'psd');
[r, totDistPow] = computeSINAD(plotType, Pxx, F, rbw);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [r, totDistPow] = powerSINAD(plotType, Sxx, F, rbw)

validateattributes(Sxx, {'single','double'},...
    {'real','finite','nonnegative','column'},...
    'sinad', 'Sxx', 1);
validateattributes(F, {'single','double'},...
    {'real','finite','vector','numel',numel(Sxx),'increasing'},...
    'sinad', 'F', 2);

coder.internal.assert(F(1)==0,'signal:sinad:MustBeOneSidedSxx');

% use the average bin width
df = mean(diff(F));

% ensure specified RBW is larger than a bin width
validateattributes(rbw,{'numeric'},{'real','finite','positive','scalar','>=',df}, ...
    'sinad','RBW',3);

[r, totDistPow] = computeSINAD(plotType, Sxx/rbw, F, rbw);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [r, totDistPow] = psdSINAD(plotType, Pxx, F)

validateattributes(Pxx, {'single','double'},...
    {'real','finite','nonnegative','column'},...
    'sinad', 'Pxx', 1);
validateattributes(F, {'single','double'},...
    {'real','finite','vector','numel',numel(Pxx),'increasing'},...
    'sinad', 'F', 2);

coder.internal.assert(F(1)==0,'signal:sinad:MustBeOneSidedPxx');

df = mean(diff(F));

[r, totDistPow] = computeSINAD(plotType, Pxx, F, df);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [r, noisePow] = computeSINAD(plotType, Pxx, F, rbw)

% save a copy of the original PSD estimates
origPxx = Pxx;

% bump DC component by 3dB and remove it.
Pxx(1) = 2*Pxx(1);
[~, ~, ~, iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw, 0);
if ~isempty(iLeft) && ~isempty(iRight)
    Pxx(iLeft(1):iRight(1)) = 0;
end
dcIdx = [iLeft; iRight];

% get an estimate of the actual frequency / amplitude, then remove it.
[Pfund, ~, iFund, iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw);
if ~isempty(iLeft) && ~isempty(iRight)
    Pxx(iLeft(1):iRight(1)) = 0;
end
fundIdx = [iLeft; iRight];

% get an estimate of the noise floor by computing the median
% noise power of the non-harmonic region
estimatedNoiseDensity = median(Pxx(Pxx>0),1);

% extrapolate estimated noise density into dc/signal/harmonic regions
Pxx(Pxx==0,1) = estimatedNoiseDensity;

% prevent estimate from obscuring low peaks
Pxx = min([Pxx origPxx],[],2);

% compute the remaining harmonic and noise distortion.
totalNoise = bandpower(Pxx, F, 'psd');

r = 10*log10(Pfund / totalNoise);
noisePow = 10*log10(totalNoise);

if ~strcmp(plotType,'none')
    coder.internal.assert(coder.target('MATLAB'),'signal:sinad:PlottingNotSupported')
    plotSINAD(origPxx, F, rbw, plotType, iFund, dcIdx, fundIdx);
    title(getString(message('signal:sinad:SINADResult',sprintf('%6.2f',r))));
end
end

function plotSINAD(Pxx, F, rbw, plotType, iFund, dcIdx, fundIdx)
% scale Pxx by rbw
Pxx = Pxx * rbw;

% initialize distortion plot
[hAxes, F, ~, colors] = initdistplot(plotType, F);

% --- plot legend entries ---

% plot fundamental line
xData = F(fundIdx(1):fundIdx(2));
yData = 10*log10(Pxx(fundIdx(1):fundIdx(2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(1,:));

% plot noise and distortion line
xData = F;
yData = 10*log10(Pxx);
line(xData, yData, 'Parent', hAxes, 'Color', colors(2,:));

% plot DC
xData = F(dcIdx(1):dcIdx(2));
yData = 10*log10(Pxx(dcIdx(1):dcIdx(2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(3,:));

% --- use a solid grid slightly offset to accommodate text labels ---
initdistgrid(hAxes);

% --- replot on top of grid ---

% plot noise and distortion line
xData = F;
yData = 10*log10(Pxx);
line(xData, yData, 'Parent', hAxes, 'Color', colors(2,:));

% plot DC
xData = F(dcIdx(1):dcIdx(2));
yData = 10*log10(Pxx(dcIdx(1):dcIdx(2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(3,:));

% plot fundamental marker
xData = F(iFund);
yData = 10*log10(Pxx(iFund));
text(double(xData(1)),double(yData(1)),'F', ...
    'VerticalAlignment','bottom', ...
    'HorizontalAlignment','center', ...
    'BackgroundColor','w', ...
    'EdgeColor','k', ...
    'Color', colors(1,:));

% plot fundamental line
xData = F(fundIdx(1):fundIdx(2));
yData = 10*log10(Pxx(fundIdx(1):fundIdx(2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(1,:));

legend(getString(message('signal:sinad:Fundamental')), ...
    getString(message('signal:sinad:NoiseAndDistortion')), ...
    getString(message('signal:sinad:DC')));

% LocalWords:  Bc Fs Pxx Sxx RBW TOTDISTPOW sineex rbw enbw THD TOI replot
end