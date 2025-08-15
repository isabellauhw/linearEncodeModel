function MPF = computeModalPeaksFunction(FRF)
%COMPUTEMODALPEAKSFUNCTION Compute a modal peaks function from FRFs.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016 The MathWorks, Inc.

if numel(size(FRF))>2
  MPF = sum(abs(FRF).^2,3);
else
  MPF = abs(FRF).^2;
end
MPF = sum(MPF,2);