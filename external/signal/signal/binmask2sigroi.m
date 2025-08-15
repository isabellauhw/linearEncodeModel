function roiMatrix = binmask2sigroi(mask)
%binmask2sigroi Convert binary mask to matrix of signal regions of interest (ROI)
%   ROILIMS = binmask2sigroi(MASK) converts MASK, a binary mask of signal
%   ROI samples, to a matrix of ROI limits, ROILIMS. ROILIMS is a
%   two-column matrix with each row containing the beginning and end
%   indices of a region of interest specified in the binary mask. MASK is a
%   logical vector with true values indicating the presence of a region of
%   interest.
%
%   % EXAMPLE:
%      % Get the region index limits of a binary mask containing 4 regions
%      % of interest.
%      mask = logical([0 0 1 1 1 1 0 0 0 0 1 1 1 0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 1 1 0 0]); 
%      roiLimits = binmask2sigroi(mask)
%
%   See also signalMask, sigroi2binmask, extractsigroi, extendsigroi,
%   shortensigroi, mergesigroi, removesigroi.

%   Copyright 2020 The MathWorks, Inc.

%#codegen

narginchk(1,1);

if ~isempty(mask)
    validateattributes(mask,{'logical','numeric'},{'vector','real','finite'},'logicalmask2roilims','SEQ');    
end
maskLogical = logical(mask(:));
roiMatrix = signal.internal.segmentation.binmask2sigroi(maskLogical);
