function roiMatrixOut = removesigroi(roiMatrix,s)
%removesigroi Remove signal regions of interest (ROI)
%   ROILIMSOUT = removesigroi(ROILIMS,S) removes signal regions specified
%   in ROILIMS that have a length of S samples or less. ROILIMS is a
%   two-column positive integer matrix with region limits. The i-th row of
%   ROILIMS contains nondecreasing indices corresponding to the beginning
%   and end of the i-th region. S must be a nonnegative integer. ROILIMSOUT
%   is a matrix of ROI limits with removed regions (if any). Output limits
%   are returned in sorted order using the sortrows function.
%
%   % EXAMPLE:
%      % Remove regions of interest with length smaller than or equal to 5 
%      % samples. Get a binary mask from the original and modified limits.
%      roiMatrix = [5 10; 17 27; 32 33; 50 53; 56 65];
%      roiMatrixRemoved = removesigroi(roiMatrix,5)
%      maskOriginal = sigroi2binmask(roiMatrix,65)'
%      maskRemoved= sigroi2binmask(roiMatrixRemoved,65)'
%
%   See also signalMask, extendsigroi, shortensigroi, mergesigroi,
%   extractsigroi, sigroi2binmask, binmask2sigroi.

%   Copyright 2020 The MathWorks, Inc.

%#codegen

narginchk(2,2);

validateattributes(s,{'numeric'},{'integer','scalar','nonnegative'},'removesigroi','S');
signal.internal.segmentation.validateROIMatrix(roiMatrix,true);

roiMatrixOut = signal.internal.segmentation.removesigroi(roiMatrix,s);
