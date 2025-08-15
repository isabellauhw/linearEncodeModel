function mask = sigroi2binmask(roiMatrix,L)
%sigroi2binmask Convert matrix of signal regions of interest (ROI) to binary mask
%   MASK = sigroi2binmask(ROILIMS) parses a matrix of signal ROI limits,
%   ROILIMS, and returns the corresponding binary mask, MASK, with true
%   values indicating samples that belong to a region of interest. ROILIMS
%   is a two-column positive integer matrix with region limits. The i-th
%   row of ROILIMS contains nondecreasing indices corresponding to the
%   beginning and end of the i-th region. The length of the output
%   sequence, MASK, is max(ROILIMS(:,2)).
%
%   MASK = sigroi2binmask(ROILIMS,L) specifies the output mask length, L,
%   as an integer scalar. Regions with indices larger than L are ignored or
%   truncated. If L > max(ROILIMS(:,2)), MASK is padded with false values.
%
%   % EXAMPLE 1:
%      % Get a binary mask corresponding to four signal regions of
%      % interest.
%      roiMatrix = [5 10; 15 18; 25 32; 36 40];
%      mask = sigroi2binmask(roiMatrix)'
%
%   % EXAMPLE 2:
%      % Get a binary mask with length 30 for a matrix with 3 regions of
%      % interest.
%      roiMatrix = [1 4; 8 12; 15 25];
%      L = 30;
%      mask = sigroi2binmask(roiMatrix,L)'
%
%   See also signalMask, binmask2sigroi, extractsigroi, extendsigroi,
%   shortensigroi, mergesigroi, removesigroi.

%   Copyright 2020 The MathWorks, Inc.

%#codegen

narginchk(1,2);

signal.internal.segmentation.validateROIMatrix(roiMatrix,true);

if nargin < 2
    if isempty(roiMatrix)
        mask = logical([]);
        return;
    else
        L = max(roiMatrix(:,2));
    end
else
    validateattributes(L,{'numeric'},{'scalar','integer','positive'},'sigroi2binmask','L');
end

if isempty(roiMatrix)
    mask = false(L,1);
else
    mask = signal.internal.segmentation.sigroi2binmask(roiMatrix,L);
end
