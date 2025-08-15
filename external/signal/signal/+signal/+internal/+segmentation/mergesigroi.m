function roiMatrixOut = mergesigroi(roiMatrix,s)
%mergesigroi Merge signal regions of interest (ROI)
%   ROILIMSOUT = extendsigroi(ROILIMS,S) merges signal regions specified in
%   matrix with ROI limits, ROILIMS, when separated by S samples or less.
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

% Cast to double to ensure we can concatenate limits horizontally 
sNew = double(s);

left = roiMatrix(:,1);
right = cummax(roiMatrix(:,2));
idx = find(left(2:end)-(sNew+1) > right(1:end-1));
N = length(left);
indicesLeft = [1;idx+1];
indicesRight = [idx;N];
roiMatrixOut = reshape(horzcat(left(indicesLeft),right(indicesRight)),[],2);


