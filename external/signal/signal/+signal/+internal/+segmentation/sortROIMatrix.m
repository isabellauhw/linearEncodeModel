function [roiMatrix,sortI] = sortROIMatrix(roiMatrix)
% Sort regions based on first column of ROI index matrix
%
% This function is for internal use only. It may be removed. 

%   Copyright 2020 The MathWorks, Inc.

%#codegen

[Indices1,sortI] = sort(roiMatrix(:,1));
Indices2 = roiMatrix(sortI,2);
roiMatrix = [Indices1 Indices2];