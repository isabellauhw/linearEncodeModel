function validateROIMatrix(roiMatrix,checkInteger)
%validateROIMatrix validate ROI matrix
%
% This function is for internal use only. It may be removed. 

%   Copyright 2020 The MathWorks, Inc.

%#codegen

if isempty(roiMatrix)
    return;
end
if checkInteger
    validateattributes(roiMatrix,{'numeric'},{'ncols',2,'integer','positive'},'','roiMatrix');
else    
    validateattributes(roiMatrix,{'numeric'},{'ncols',2,'real','finite','nonnegative'},'','roiMatrix');
    roiMatrix = round(roiMatrix);
end
% Verify matrix of indices has increasing intervals
if any(diff(roiMatrix,1,2) < 0)
    coder.internal.error('signal:internal:segmentation:NonDecreasingRegionLimits')
end


end