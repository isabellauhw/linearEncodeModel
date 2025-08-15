function seq = roiMatrix2SingleIdxSeq(roiMatrix)
% Convert an ROI index matrix to a single flat sequence of integer indices.
% If input has matrix: [[Idx1,Idx2];...[Idxp,Idxq]] then the output list
% contains: unique([Idx1:Idx2 ... Idxp:Idxq])
%
%   The function assumes an ROI matrix with integer, non-decreasing region
%   limits.
%
%   This function is for internal use only. It may change or be removed. 

%   Copyright 2020 The MathWorks, Inc.

%#codegen

roiMatrix = signal.internal.segmentation.sortROIMatrix(roiMatrix);

% get the number of partitions
nPartitions = size(roiMatrix,1);

% get the number of elements in each partition and total number of elements
szPartition = diff(roiMatrix,[],2)+1;
total = sum(szPartition);

% intialize differential index list
ID = ones(1,total);

% set first index to be index of first partition.
ID(1) = roiMatrix(1);

% get index of first element in differential index list
iDiff = 1+cumsum(szPartition(1:end-1));
ID(iDiff) = roiMatrix(2:nPartitions,1) - roiMatrix(1:nPartitions-1,2);

% integrate the differential list, get unique sorted indices
seq = unique(cumsum(ID),'sorted');
