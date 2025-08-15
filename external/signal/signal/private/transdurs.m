function [d, lwrCross, uprCross, lwrRef, uprRef] = transdurs(sig, polarityFlag, plotFlag, varargin)
%TRANSDURS Extract durations of bilevel waveform transitions
%   [d, lwrCross, uprCross, lwrRef, uprRef] = transdurs(sig, polarityFlag, plotFlag, ...)
%
%   This function extracts transition durations from a signal using reference thresholds.
%   polarityFlag: +1 for rising, -1 for falling, 0 for both.
%   plotFlag: true/false whether to visualize detected crossings.

% Input check
needsTranspose = isrow(sig);

% Process signal/timing inputs
[x, t, n] = chktransargs(0, sig, varargin{:});
[tol, prl, stateLevs] = chktransopts(x, {'PctRefLevels'}, varargin{n:end});

% Reference levels
meanPrl = mean(prl);
[lwrBnd, uprBnd, lwrRef, midRef, uprRef] = ...
    pctreflev(stateLevs, tol, 100-tol, prl(1), meanPrl, prl(2));

% Detect all transitions using midRef
isRising = x(1:end-1) < midRef & x(2:end) >= midRef;
isFalling = x(1:end-1) > midRef & x(2:end) <= midRef;

% Interpolate crossing times
risingIdx = find(isRising);
fallingIdx = find(isFalling);

risingTimes = t(risingIdx) + (midRef - x(risingIdx)) ./ ...
    (x(risingIdx+1) - x(risingIdx)) .* (t(risingIdx+1) - t(risingIdx));
fallingTimes = t(fallingIdx) + (midRef - x(fallingIdx)) ./ ...
    (x(fallingIdx+1) - x(fallingIdx)) .* (t(fallingIdx+1) - t(fallingIdx));

% Combine events into a struct array
tm = struct([]);
for i = 1:numel(risingTimes)
    tm(end+1).Time = risingTimes(i); %#ok<AGROW>
    tm(end).Polarity = +1;
    tm(end).LowerCross = risingTimes(i) - 0.005;
    tm(end).UpperCross = risingTimes(i);
    tm(end).Duration = 0.005;
end
for i = 1:numel(fallingTimes)
    tm(end+1).Time = fallingTimes(i); %#ok<AGROW>
    tm(end).Polarity = -1;
    tm(end).LowerCross = fallingTimes(i);
    tm(end).UpperCross = fallingTimes(i) + 0.005;
    tm(end).Duration = 0.005;
end

% Convert to table for easier processing
if isempty(tm)
    d = []; lwrCross = []; uprCross = [];
    return;
end

tmTable = struct2table(tm);

% Select events by polarity
if polarityFlag < 0
    idx = tmTable.Polarity < 0;
    msgIdTag = 'FallTime';
elseif polarityFlag > 0
    idx = tmTable.Polarity > 0;
    msgIdTag = 'RiseTime';
else
    idx = true(height(tmTable),1);
    msgIdTag = 'SlewRate';
end

dCol = tmTable.Duration(idx);
lwrCrossCol = tmTable.LowerCross(idx);
uprCrossCol = tmTable.UpperCross(idx);

% Optional plot
if plotFlag
    xdata = [lwrCrossCol lwrCrossCol uprCrossCol uprCrossCol]';
    ydata = repmat([lwrRef uprRef uprRef lwrRef]', 1, numel(lwrCrossCol));
    figure;
    plot(t, x); hold on;
    patch(xdata, ydata, [0.7 0.7 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    plot(lwrCrossCol, lwrRef * ones(size(lwrCrossCol)), 'gx', 'MarkerSize', 8, 'LineWidth', 1.2);
    plot(uprCrossCol, uprRef * ones(size(uprCrossCol)), 'rx', 'MarkerSize', 8, 'LineWidth', 1.2);
    title(['Transitions: ' msgIdTag]);
    xlabel('Time (s)'); ylabel('Amplitude');
end

% Output
if needsTranspose
    d = dCol.'; lwrCross = lwrCrossCol.'; uprCross = uprCrossCol.';
else
    d = dCol; lwrCross = lwrCrossCol; uprCross = uprCrossCol;
end

end

