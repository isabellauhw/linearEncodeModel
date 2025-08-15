function roiMatrix = extendsigroi(roiMatrix,sl,sr,maxIdx)
%extendsigroi Extend signal regions of interest (ROI) to left and right
%   ROILIMSOUT = extendsigroi(ROILIMS,SL,SR,MAXIDX) extends regions to left
%   or right and limits extension to MAXIDX.
%
%   The function assumes an ROI matrix with integer, non-decreasing region
%   limits.
%
%   This function is for internal use only. It may change or be removed. 

%   Copyright 2020 The MathWorks, Inc.

%#codegen

if isempty(roiMatrix)
   roiMatrix = cast(zeros(0,2),'like', roiMatrix);
   return
end
roiMatrix = sortrows(roiMatrix);

% Cast to double to ensure we can concatenate limits horizontally as these
% values can have any numeric type
slNew = double(sl);
srNew = double(sr);

% Extend regions to left and right
if  slNew > 0 || srNew > 0
    roiMatrix = [...
        max(1,roiMatrix(:,1) - slNew),...
        min(maxIdx,roiMatrix(:,2) + srNew)];     
end


