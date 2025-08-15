function mask = sigroi2binmask(roiMatrix,L)
%sigroi2binmask Get logical mask from signal regions of interest (ROI) limits
%   MASK = sigroi2binmask(ROILIMS,L) parses matrix with signal ROI limits,
%   ROILIMS and returns a logical vector mask, MASK of length L. Regions
%   with indices larger than L will be ignored or truncated. If L >
%   max(ROILIMS(:,2)), MASK will be padded with false values.
%
%   This function is for internal use only. It may change or be removed. 

%   Copyright 2020 The MathWorks, Inc.

%#codegen

% Get a sequence of indices. Ignore indices outside of the length L
indexSeq = signal.internal.segmentation.roiMatrix2SingleIdxSeq(roiMatrix);
indexSeq(indexSeq > L) = [];

% Create a logical sequence of length L and set to true at index locations
mask = false(L,1);
mask(indexSeq) = true;
