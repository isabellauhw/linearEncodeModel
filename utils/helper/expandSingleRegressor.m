function [laggedMat, validIdx] = expandSingleRegressor(trace, preFrames, postFrames)
% - *expandSingleRegressor*: A helper function for expanding a single
% regressor to time-shifted columns, used in *createTaskDesignMatrix*.
lags = -preFrames:postFrames-1;
nLags = length(lags);
nFrames = length(trace);
laggedMat = zeros(nFrames, nLags);

for iLag = 1:nLags
    lag = lags(iLag);
    if lag < 0
        shifted = [trace(-lag + 1:end); zeros(-lag, 1)];
    elseif lag > 0
        shifted = [zeros(lag, 1); trace(1:end - lag)];
    else
        shifted = trace;
    end
    laggedMat(:, iLag) = shifted;
end

% Remove all-zero columns
validCols = any(abs(laggedMat) > eps, 1);
laggedMat = laggedMat(:, validCols);
validIdx = find(validCols);

end