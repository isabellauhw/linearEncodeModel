function roiMatrixOut = removesigroi(roiMatrix,s)
%removesigroi Remove signal regions of interest (ROI)
%   ROILIMSOUT = removesigroi(ROILIMS,S) removes signal regions
%   specified in matrix with ROI limits, ROILIMS, when they are shorter
%   than or equal to S samples.
%
%   The function assumes an ROI matrix with integer, non-decreasing region
%   limits.
%
%   This function is for internal use only. It may change or be removed. 

%   Copyright 2020 The MathWorks, Inc.

%#codegen

if isempty(roiMatrix)
   roiMatrixOut = cast(zeros(0,2),'like', roiMatrix);
   return
end
roiMatrix = sortrows(roiMatrix);

if s > 0
    currentIdx1 = roiMatrix(:,1);
    currentIdx2 = roiMatrix(:,2);
        
    keepIdx = (currentIdx2 - currentIdx1) + 1 > s;
    
    if ~any(keepIdx)
        roiMatrixOut = zeros(0,2,'like',roiMatrix);
        return;
    end

    currentIndices1 = roiMatrix(keepIdx,1);
    currentIndices2 = roiMatrix(keepIdx,2);
    roiMatrixOut = [currentIndices1, currentIndices2];
else
    roiMatrixOut = roiMatrix;
end
