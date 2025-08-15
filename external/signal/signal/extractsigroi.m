function sigs = extractsigroi(x,roiMatrix,concatFlag)
%extractsigroi Extract signal regions of interest (ROI)
%   SIGROI = extractsigroi(X,ROILIMS) extracts regions of interest of the
%   input signal vector X based on the ROI limits specified in the matrix
%   ROILIMS. ROILIMS is a two-column positive integer matrix with region
%   limits. The i-th row of ROILIMS contains nondecreasing indices
%   corresponding to the beginning and end of the i-th region. The length
%   of input signal X must be greater than or equal to the largest region
%   limit in ROILIMS. Output SIGROI is a cell array. The i-th element of
%   SIGROI contains the signal samples corresponding to the region in the
%   i-th row of ROILIMS.
%
%   SIGROI = (X,ROILIMS,CONCATFLAG) extracts signal regions of interest and
%   concatenates them when CONCATFLAG is true. In this case, SIGROI is a
%   vector containing all concatenated extracted signal samples. If
%   omitted, CONCATFLAG defaults to false.
%
%   % EXAMPLE 1:
%      % Extract signal samples from three regions of interest.
%      x = randn(45,1);
%      roiMatrix = [5 10; 15 25; 30 35];
%      sigCell = extractsigroi(x,roiMatrix)
%
%   % EXAMPLE 2:
%      % Extract signal samples from three regions of interest. Get a
%      % vector with the concatenated signal segments.
%      x = (1:40);
%      roiMatrix = [5 10; 15 25; 30 35];
%      sigVect = extractsigroi(x,roiMatrix,true)'
%
%   See also signalMask, extendsigroi, shortensigroi, mergesigroi,
%   removesigroi, sigroi2binmask, binmask2sigroi.

%   Copyright 2020 The MathWorks, Inc.

%#codegen

narginchk(2,3);

if nargin < 3
    concatFlag = false;
else
    validateattributes(concatFlag,{'logical','numeric'},{'scalar','real','finite'},'extractsigroi','CONCATFLAG');
    concatFlag = logical(concatFlag);
end

L = 0;
if ~isempty(x)
    validateattributes(x,{'numeric'},{'vector'},'extractsigroi','X');    
    L = length(x);
end
signal.internal.segmentation.validateROIMatrix(roiMatrix,true);
coder.internal.errorIf( any(any(roiMatrix > L)) ,'signal:internal:segmentation:SignalTooShortForExtractROI');

sigs = signal.internal.segmentation.extractsigroi(x,roiMatrix,concatFlag);

