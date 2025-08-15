function roiMatrix = extendsigroi(roiMatrix,sl,sr)
%extendsigroi Extend signal regions of interest (ROI) to left and right
%   ROILIMSOUT = extendsigroi(ROILIMS,SL,SR) extends regions specified in
%   ROILIMS to the left by SL samples and to the right by SR samples.
%   ROILIMS is a two-column positive integer matrix with region limits. The
%   i-th row of ROILIMS contains nondecreasing indices corresponding to the
%   beginning and end of the i-th region. SL and SR must be nonnegative
%   integers. ROILIMSOUT is a matrix with extended ROI limits. Output
%   limits are returned in sorted order using the sortrows function.
%
%   % EXAMPLE 1:
%      % Extend regions of interest to the left and right by 2 samples. 
%      % Get a binary mask from the original and modified regions.
%      roiMatrix = [5 10; 17 20; 29 32; 38 40];
%      roiMatrixExtended = extendsigroi(roiMatrix,2,2)
%      maskOriginal = sigroi2binmask(roiMatrix,45)'
%      maskExtended= sigroi2binmask(roiMatrixExtended,45)'
%
%   % EXAMPLE 2:
%      % Extend regions of interest to the right by 5 samples. Use the
%      % mergesigroi function to merge resulting contiguous or overlapping 
%      % regions.
%      roiMatrix = [5 10; 15 25; 40 45; 48 55];
%      roiMatrix = extendsigroi(roiMatrix,0,5)
%      roiMatrix = mergesigroi(roiMatrix,0)
%
%   See also signalMask, shortensigroi, mergesigroi, removesigroi,
%   extractsigroi, sigroi2binmask, binmask2sigroi.

%   Copyright 2020 The MathWorks, Inc.

%#codegen

narginchk(3,3);

validateattributes(sl,{'numeric'},{'integer','scalar','nonnegative'},'extendsigroi','SL');
validateattributes(sr,{'numeric'},{'integer','scalar','nonnegative'},'extendsigroi','SR');
signal.internal.segmentation.validateROIMatrix(roiMatrix,true);

maxIdx = realmax;
roiMatrix = signal.internal.segmentation.extendsigroi(roiMatrix,sl,sr,maxIdx);
