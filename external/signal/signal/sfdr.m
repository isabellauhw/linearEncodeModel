function [r, spurPow, spurFreq] = sfdr(varargin)
%SFDR   Spurious Free Dynamic Range
%   R = SFDR(X) computes the spurious free dynamic range, in dB, of the
%   real sinusoidal input signal X.  The computation is performed over a
%   periodogram of the same length as the input using a Kaiser window.
%
%   R = SFDR(X, Fs) specifies the sampling rate, Fs, of the time-domain
%   input signal, X.  If Fs is unspecified it defaults to 1 Hz.
%
%   R = SFDR(X, Fs, MSD) considers only spurs that are separated from the
%   carrier frequency by the minimum spur distance, MSD, to compute
%   spurious free dynamic range. MSD is a real-valued positive scalar
%   specified in frequency units. This parameter may be specified to ignore
%   spurs or sidelobes that may occur in close proximity to the carrier.
%   For example, if the carrier frequency is Fc, then all spurs in the
%   range (Fc-MSD, Fc+MSD) are ignored. If not specified, then MSD defaults
%   to zero.
%
%   R = SFDR(Sxx, F, 'power') computes the spurious free dynamic range, in
%   dB, of a one-sided power spectrum, Sxx, of a real signal.   F is a
%   vector of frequencies that corresponds to the vector of Sxx estimates.
%
%   R = SFDR(Sxx, F, MSD, 'power') considers spurs separated from the
%   carrier frequency identified in Sxx by the minimum spur distance, MSD.
%
%   [R, SPURPOW, SPURFREQ] = SFDR(...) also returns the power,
%   SPURPOW, and frequency, SPURFREQ, of the largest spur.
%
%   SFDR(...) with no output arguments plots the spectrum of the signal and
%   annotates the fundamental signal and the maximum spur.  The DC
%   component is removed before computing SFDR.
%
%   % Example 1:
%   %   Obtain the SFDR of a 9.8kHz tone with a spur 80 dBc at 14.7kHz
%   Fs = 44.1e3; f1 = 9.8e3; f2 = 14.7e3; N = 900;
%   nT = (1:N)/Fs;
%   x = sin(2*pi*f1*nT) + 100e-6*sin(2*pi*f2*nT) + 1e-8*randn(1,N);
%   [sfd, spur, frq] = sfdr(x, Fs)
%
%   % annotate the spectrum
%   sfdr(x, Fs)
%
%   See also THD SINAD SNR TOI.

%   Copyright 2012-2019 The MathWorks, Inc.

%#codegen

narginchk(1,4);

inputArgs = cell(size(varargin));
[inputArgs{:}] = convertStringsToChars(varargin{:});

% if no arguments are specified, then plot
plotFlag = nargout==0;
% plotting is supported only in MATLAB execution
coder.internal.assert(~(~coder.target('MATLAB') && plotFlag),'signal:sfdr:PlottingNotSupported');

% validate input string and get the index of the 'power' flag
idx = getflagidx('power',inputArgs);

if idx == 0
    % Time-domain input
    [r, spurPow, spurFreq] = tsfdr(plotFlag, inputArgs{:});
else
    % Power spectrum input
    [r, spurPow, spurFreq] = psfdr(plotFlag, inputArgs{1:idx-1});
end

end

function [r, spurPow, spurFreq] = tsfdr(plotFlag, x, fs, msd)

% force column vector before checking attributes
if max(size(x)) == numel(x)
    colX = x(:);
else
    colX = x;
end

validateattributes(colX,{'single','double'},{'real','finite','vector'}, ...
    'sfdr','X',1);

if nargin > 2
    validateattributes(fs, {'numeric'},{'real','finite','scalar','positive'}, ...
        'sfdr','Fs',2);
else
    fs = 1;
end
fsScalar = double(fs(1));
if nargin > 3
    validateattributes(msd,{'numeric'},{'real','finite','positive','scalar'}, ...
        'sfdr','MSD',3);
else
    msd = 0;
end

n = length(colX);

% use Kaiser window to reduce effects of leakage
w = kaiser(n,38);
rbw = enbw(w,fsScalar);
[Pxx, F] = periodogram(colX,w,n,fsScalar);

origPxx = Pxx;

% bump DC component by 3dB and remove it.
Pxx(1) = 2*Pxx(1);
[~, ~, ~, iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw, 0);
if ~isempty(iLeft) && ~isempty(iRight)
    Pxx(iLeft(1):iRight(1)) = 0;
end
dcIdx = [iLeft; iRight];

% get an estimate of the actual frequency / amplitude, then remove it.
[Pfund, Ffund, iFund, iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw);
if ~isempty(iLeft) && ~isempty(iRight)
    Pxx(iLeft(1):iRight(1)) = 0;
end
fundIdx = [iLeft; iRight];

% remove any adjacent content if msd is specified
Pxx(abs(F-Ffund)<msd(1)) = 0;

% get the maximum spur from the remaining bins
[~, spurBin] = max(Pxx);

% get an estimate of the spurious power.
[Pspur, Fspur, iSpur] = signal.internal.getToneFromPSD(Pxx, F, rbw, F(spurBin));

r = 10*log10(Pfund / Pspur);
spurPow = 10*log10(Pspur);
spurFreq = Fspur;

if plotFlag
    % use sample estimate for markers
    Pfund = 10*log10(rbw*origPxx(iFund));
    Pspur = 10*log10(rbw*origPxx(iSpur));
    Ffund = F(iFund);
    Fspur = F(iSpur);
    
    plotSFDR(origPxx, F, rbw, Ffund, Pfund, fundIdx, Fspur, Pspur, dcIdx);
    title(getString(message('signal:sfdr:SFDRResult',sprintf('%6.2f',r))));
end
end

function [leftBinScalar, rightBinScalar] = getPeakBorder(Sxx, F, fundFreq, fundBin, msd)
fundBinScalar = fundBin(1);
% find the borders of the fundamental peak
leftBin = find(Sxx(2:fundBinScalar) < Sxx(1:fundBinScalar-1),1,'last');
rightBin = fundBinScalar + find(Sxx(fundBinScalar+1:end) > Sxx(fundBinScalar:end-1),1,'first')-1;

% ensure against edge cases and force a scalar
if isempty(leftBin)
    leftBinScalar = 1;
else
    leftBinScalar = leftBin(1);
end

if isempty(rightBin)
    rightBinScalar = numel(Sxx);
else
    rightBinScalar = rightBin(1);
end

% increase peak width if necessary
leftBinG  = find(F <= fundFreq(1) - msd(1), 1, 'last');
rightBinG = find(fundFreq(1) + msd(1) < F, 1, 'first');
if ~isempty(leftBinG) && leftBinG(1) < leftBinScalar
    leftBinScalar = leftBinG(1);
end
if ~isempty(rightBinG) && rightBinG(1) > rightBinScalar
    rightBinScalar = rightBinG(1);
end

end

function [r, spurPow, spurFreq] = psfdr(plotFlag, Sxx, F, msd)

validateattributes(Sxx,{'single','double'},{'real','finite','vector','positive'},...
    'sfdr','Sxx',1);
validateattributes(F, {'numeric'},{'real','finite','vector'},...
    'sfdr','F',2);

coder.internal.assert(F(1)==0,'signal:sfdr:MustBeOneSided');

if nargin>3
    validateattributes(msd,{'numeric'},{'real','finite','positive','scalar'},...
        'sfdr','MSD',3);
else
    msd = 0;
end

origSxx = Sxx;
% force column vector
colSxx = Sxx(:);

% ignore any (monotonically decreasing) DC component
colSxx(1) = 2*colSxx(1);
idxStop = find(colSxx(1:end-1)<colSxx(2:end),1,'first');
if ~isempty(idxStop)
    colSxx(1:idxStop(1)) = 0;
end
dcIdx = [1; idxStop];

[fundPow, fundBin] = max(colSxx);
fundFreq = F(fundBin);

% remove peak
[leftBin, rightBin] = getPeakBorder(colSxx, F, fundFreq, fundBin, msd);
colSxx(leftBin:rightBin) = 0;
fundIdx = [leftBin; rightBin];

% get the maximum spur from the remaining bins
[spurPow, spurBin] = max(colSxx);

r = 10*log10(fundPow / spurPow);
fundPow = 10*log10(fundPow);
spurPow = 10*log10(spurPow);
spurFreq = F(spurBin);

if plotFlag
    plotSFDR(origSxx, F, 1, fundFreq, fundPow, fundIdx, spurFreq, spurPow, dcIdx);
    title(getString(message('signal:sfdr:SFDRResult',sprintf('%6.2f',r))));
end
end

function plotSFDR(Pxx, F, rbw, Ffund, Pfund, fundIdx, Fspur, Pspur, dcIdx)
% scale Pxx by rbw
Pxx = Pxx * rbw;

% initialize distortion plot
[hAxes, F, fscale, colors] = initdistplot('power', F);

% --- plot legend entries ---

% plot fundamental
xData = F(fundIdx(1):fundIdx(2));
yData = 10*log10(Pxx(fundIdx(1):fundIdx(2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(1,:));

% plot dc and noise and distortion
xData = [F(1:fundIdx(1)); NaN; F(fundIdx(2):end)];
yData = 10*log10([Pxx(1:fundIdx(1)); NaN; Pxx(fundIdx(2):end)]);
line(xData, yData, 'Parent', hAxes, 'Color', colors(2,:));

% plot dc legend entry
xData = F(dcIdx(1):dcIdx(2));
yData = 10*log10(Pxx(dcIdx(1):dcIdx(2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(3,:));

% --- use a solid grid slightly offset to accommodate text labels ---
initdistgrid(hAxes);

% --- replot on top of the grid ---

% plot fundamental marker
xData = Ffund*fscale;
yData = Pfund;
text(double(xData(1)),double(yData(1)),'F', ...
    'VerticalAlignment','bottom', ...
    'HorizontalAlignment','center', ...
    'BackgroundColor','w', ...
    'EdgeColor','k', ...
    'Color', colors(1,:));

% plot largest spur marker
xData = Fspur*fscale;
yData = Pspur;
text(double(xData(1)),double(yData(1)),'S', ...
    'VerticalAlignment','bottom', ...
    'HorizontalAlignment','center', ...
    'BackgroundColor','w', ...
    'EdgeColor','k', ...
    'Color', colors(2,:));

% plot fundamental line
xData = F(fundIdx(1):fundIdx(2));
yData = 10*log10(Pxx(fundIdx(1):fundIdx(2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(1,:));

% plot dc and noise and distortion line
xData = [F(1:fundIdx(1)); NaN; F(fundIdx(2):end)];
yData = 10*log10([Pxx(1:fundIdx(1)); NaN; Pxx(fundIdx(2):end)]);
line(xData, yData, 'Parent', hAxes, 'Color', colors(2,:));

% plot dc line
xData = F(dcIdx(1):dcIdx(2));
yData = 10*log10(Pxx(dcIdx(1):dcIdx(2)));
line(xData, yData, 'Parent', hAxes, 'Color', colors(3,:));

% create SFDR patch and send to back
xLim = get(hAxes,'XLim');
hPatch = patch(xLim([1 1 2 2]),[Pspur Pfund Pfund Pspur],[.85 .85 1], ...
    'Parent',hAxes,'EdgeColor','none');
uistack(hPatch,'bottom');

legend(getString(message('signal:sfdr:SFDR')), ...
    getString(message('signal:sfdr:Fundamental')), ...
    getString(message('signal:sfdr:Spurs')), ...
    getString(message('signal:sfdr:DC')));

end


function flagIdx = getflagidx(inpflag,args)

found = false;
coder.unroll();
for i = 1:length(args)
    if ischar(args{i}) && ~found
        % input string must be a compile time constant for code generation
        coder.internal.assert(coder.internal.isConst(args{i}),...
            'signal:sfdr:InputStringAsConst');
        % check for valid input flag
        coder.internal.assert(strcmpi(args{i},inpflag),...
            'signal:sfdr:UnknownOption',args{i});
        found = true;
        flagIdx = i;
    else
        flagIdx = 0;
    end
end
end