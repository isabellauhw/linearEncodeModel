function spikeCounts = spikeCountInInterval(spikeTimes, interval)
%spikeCounts = spikeCountInInterval(spikeTimes, interval) returns the
% number of spike events wthin a set of intervals [n x 2]. spikeTimes should
% be a vector of spike times. interval should be [n x 2] listing the start
% and end times, for example [1.2 1.4; 15.9 16.5; 9 9.1... ] The output spikeCounts
% contains the number of spike events within each interval

assert(size(interval,2)==2, 'Interval argument should have 2 columns [start end]');
assert(all( interval(:,2) > interval(:,1)), 'Interval arguments should be increasing in time [start, end] not [end, start]');

numIntervals = size(interval,1);
spikeCounts = nan(numIntervals,1);

for r = 1:numIntervals
    spikeCounts(r) = sum( WithinRanges(spikeTimes, interval(r,:) ) );
end

end