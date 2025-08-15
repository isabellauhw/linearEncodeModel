function roiMatrixOut = mergesigroi(roiMatrix,s)
%mergesigroi Merge signal regions of interest (ROI)
%   ROILIMSOUT = mergesigroi(ROILIMS,S) merges signal regions specified in
%   ROILIMS that are separated by S samples or less. ROILIMS is a
%   two-column positive integer matrix with region limits. The i-th row of
%   ROILIMS contains nondecreasing indices corresponding to the beginning
%   and end of the i-th region. S must be a nonnegative integer. ROILIMSOUT
%   is a matrix of ROI limits with merged regions (if any). Output limits
%   are returned in sorted order using the sortrows function.
%
%   Use mergesigroi with S = 0 to merge contiguous, overlapping, or
%   repeated regions of ROILIMS.
%
%   % EXAMPLE 1:
%      % Merge regions of interest separated by 5 samples or less and get a
%      % binary mask from the original and modified limits.
%      roiMatrix = [5 15; 17 20; 29 38; 50 53; 57 60];
%      roiMatrixMerged = mergesigroi(roiMatrix,5)
%      maskOriginal = sigroi2binmask(roiMatrix,60)'
%      maskMerged = sigroi2binmask(roiMatrixMerged,60)'
%
%   % EXAMPLE 2:
%      % Merge contiguous regions and remove repeated regions.
%      roiMatrix = [5 15; 16 20; 29 38; 29 38; 56 90; 91 100];
%      roiMatrix = mergesigroi(roiMatrix,0)
%
%   % EXAMPLE 3:
%      % Merge overlapping regions.
%      roiMatrix = [5 15; 10 20; 30 40; 50 65; 55 90; 95 100];
%      roiMatrix = mergesigroi(roiMatrix,0)
%
%   See also signalMask, extendsigroi, shortensigroi, removesigroi,
%   extractsigroi, sigroi2binmask, binmask2sigroi.

%   Copyright 2020 The MathWorks, Inc.

%#codegen

narginchk(2,2);

validateattributes(s,{'numeric'},{'integer','scalar','nonnegative'},'mergesigroi','S');
signal.internal.segmentation.validateROIMatrix(roiMatrix,true);

roiMatrixOut = signal.internal.segmentation.mergesigroi(roiMatrix,s);
