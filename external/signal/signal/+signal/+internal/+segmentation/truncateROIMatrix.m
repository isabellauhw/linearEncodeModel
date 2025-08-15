function [roiMatrix, I] = truncateROIMatrix(roiMatrix,L)
%   [roiMatrixOut, I] = truncateROIMatrix(roiMatrixIn,L) truncates regions
%   of roiMatrixIn so that they do not go beyond limit L. Rows
%   corresponding to regions with an initial ROI value greater than L are
%   removed from roiMatrixIn. I is a logical vector with
%   size(roiMatrixIn,1) with false values at indices of rows that were
%   removed from the input matrix because their initial limits were larger
%   than L.
%
%   This function is for internal use only. It may change or be removed. 

%#codegen

I = true(size(roiMatrix,1),1);
if ~isempty(roiMatrix) && L < max(roiMatrix(:,2))
    I = roiMatrix(:,1) <= L;
    roiMatrix = roiMatrix(I,:);
    roiMatrix(:,2) = min(L,roiMatrix(:,2));
end

