function y = filterData(x, opts)
%filterData Filter data with filter c
%   filterData filters data with filter c and compensates for filter delay.

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.

D = opts.FilterObject;
isFIR = opts.IsFIR;
N = filtord(D);

if opts.IsSinglePrecision && ~isFIR
    % filtfilt does not support single precision
    D = double(D);
end

if isFIR && rem(N,2)
    error(message('signal:internal:filteringfcns:InternalFilterMustBeEven'));    
end

if istimetable(x)    
    y = x;    
    varNames = y.Properties.VariableNames;
    if isFIR
        filtDelay = N/2;
        for idx = 1:numel(varNames)
            nCols = size(y.(varNames{idx}),2);
            filteredData = filter(D,[y.(varNames{idx}); zeros(filtDelay,nCols)]);
            filteredData = filteredData(filtDelay+1:end,:);
            y.(varNames{idx}) = filteredData;            
        end
    else
        for idx = 1:numel(varNames)            
            y.(varNames{idx}) = filtfilt(D,double(y.(varNames{idx})));
        end
    end 
else    
    if isFIR
        filtDelay = N/2;
        if isrow(x)
            y = filter(D,[x zeros(1,filtDelay)]);
            y = y(filtDelay+1:end);
        else
            nCols = size(x,2);
            y = filter(D,[x; zeros(filtDelay,nCols)]);
            y = y(filtDelay+1:end,:);
        end
    else
        y = filtfilt(D,double(x));
    end
end

if opts.IsSinglePrecision && ~isFIR    
    y = single(y);
end