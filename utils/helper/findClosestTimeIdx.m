function idx = findClosestTimeIdx(globalTime, timeVal)
    % *findClosestTimeIdx*: Returns index of time point in globalTime closest to timeVal
    [~, idx] = min(abs(globalTime - timeVal));
end
