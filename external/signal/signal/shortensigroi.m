function roiMatrixOut = shortensigroi(roiMatrix,sl,sr)
%shortensigroi Shorten signal regions of interest (ROI) from left and right
%   ROILIMSOUT = shortensigroi(ROILIMS,SL,SR) shortens the regions
%   specified in ROILIMS from the left by SL samples and from the right by
%   SR samples. ROILIMS is a two-column positive integer matrix with region
%   limits. The i-th row of ROILIMS contains nondecreasing indices
%   corresponding to the beginning and end of the i-th region. SL and SR
%   must be nonnegative integers. ROILIMSOUT is a matrix with shortened ROI
%   limits. Output limits are returned in sorted order using the sortrows
%   function.
%
%   The function removes all regions of length SL + SR or less.
%
%   % EXAMPLE:
%      % Shorten regions of interest form the left and right by two samples.
%      % Get a binary mask from the original and modified limits.
%      roiMatrix = [5 10; 15 25; 30 35];
%      roiMatrixShortened = shortensigroi(roiMatrix,2,2)
%      maskOriginal = sigroi2binmask(roiMatrix,40)'
%      maskShortened = sigroi2binmask(roiMatrixShortened,40)'
%
%   See also signalMask, extendsigroi, mergesigroi, removesigroi,
%   extractsigroi, sigroi2binmask, binmask2sigroi.

%   Copyright 2020 The MathWorks, Inc.

%#codegen

narginchk(3,3);

validateattributes(sl,{'numeric'},{'integer','scalar','nonnegative'},'shortensigroi','SL');
validateattributes(sr,{'numeric'},{'integer','scalar','nonnegative'},'shortensigroi','SR');
signal.internal.segmentation.validateROIMatrix(roiMatrix,true);

roiMatrixOut = signal.internal.segmentation.shortensigroi(roiMatrix,sl,sr);
