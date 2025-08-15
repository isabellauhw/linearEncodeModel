function sigs = extractsigroi(x,roiMatrix,concatFlag)
%extractsigroi Extract signal regions of interest (ROI)
%   SIGROI = extractsigroi(X,ROILIMS,CONCATFLAG) extracts
%   regions from input signal vector, X, based on the matrix with ROI
%   limits, ROILIMS. Output SIGROI is a cell array. The i-th element of
%   SIGROI contains the signal samples corresponding to the region
%   specified by the i-th row of ROILIMS. If CONCATFLAG is
%   true, extracted signal segments are concatenated.
%
%   The function assumes an ROI matrix with integer, non-decreasing region
%   limits.
%
%   This function is for internal use only. It may change or be removed. 

%   Copyright 2020 The MathWorks, Inc.

%#codegen

%CONCATFLAG must be constant for codegen
coder.internal.errorIf(~coder.internal.isConst(concatFlag),'signal:internal:segmentation:ConcatFlagMustBeConstant');

if isempty(roiMatrix) || isempty(x)
    if concatFlag
        sigs = [];
    else
        sigs = {};
    end
    return;
end

L = length(x);

xin = x(:);

% Cannot use cell2mat for codegen purposes so loop and create concatenated
% vector or cell array.
N = size(roiMatrix,1);
if concatFlag
    sigs = [];
    for idx = 1:N
        leftLim = roiMatrix(idx,1);
        if leftLim > L
            sigs = [sigs; zeros(0,1,'like',x)]; %#ok<*AGROW>
            continue;
        end
        rightLim = min(L,roiMatrix(idx,2));
        sigs = [sigs; xin(leftLim:rightLim,:)];
    end
else
    sigs = cell(N,1);
    for idx = 1:N
        leftLim = roiMatrix(idx,1);
        if leftLim > L
            sigs{idx} = zeros(0,1,'like',x);
            continue;
        end
        rightLim = min(L,roiMatrix(idx,2));
        sigs{idx} = xin(leftLim:rightLim,:);
    end
end