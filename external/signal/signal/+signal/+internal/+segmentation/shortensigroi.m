function roiMatrixOut = shortensigroi(roiMatrix,sl,sr)
%shortensigroi Shorten signal regions of interest (ROI) from left and right
%   ROILIMSOUT = shortensigroi(ROILIMS,SL,SR) shortens regions
%   specified in matrix with ROI limits, ROILIMS, from the left by SL
%   samples and from the right by SR samples.
%
%   A region is removed if it is shortened by a number of samples equal to
%   or larger than its length.
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

% Cast to double to ensure we can concatenate limits horizontally as these
% values can have any numeric type
slNew = double(sl);
srNew = double(sr);

% Remove regions that are shorter than the total samples to shorten, this
% will also sort the roi matrix rows
roiMatrixOut = signal.internal.segmentation.removesigroi(roiMatrix,sl+sr);

if isempty(roiMatrixOut)
    return;
end

% Shorten regions to left and right
if  slNew > 0 || srNew > 0
     roiMatrixOut(:,1) = roiMatrixOut(:,1) + slNew;
     roiMatrixOut(:,2) = roiMatrixOut(:,2) - srNew;
end