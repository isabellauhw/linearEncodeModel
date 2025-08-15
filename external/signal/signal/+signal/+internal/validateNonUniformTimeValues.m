function flag = validateNonUniformTimeValues(tv)
% check irregularity of the time values by measuring how different
% are the mean and median of the time differences.
% mean(diff(time))/median(diff(time)).This is equivalent to looking
% at the ratio of the length of the data after resampling over the
% length of the data before resampling.

%   Copyright 2017 The MathWorks, Inc.
%#codegen

dtv = diff(tv);
medianTimeInterval = median(dtv);
meanTimeInterval = mean(dtv);
flag = medianTimeInterval/meanTimeInterval < 100 && meanTimeInterval/medianTimeInterval < 100;
end