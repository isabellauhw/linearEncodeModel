function roiMatrix = binmask2sigroi(mask)
%binmask2sigroi Get signal regions of interest (ROI) limits from logical mask
%   ROILIMS = binmask2sigroi(MASK) converts a logical vector mask, MASK,
%   that points to region of interest samples of a signal, to a matrix with
%   signal ROI limits, ROILIMS.
%
%   This function is for internal use only. It may change or be removed. 


%#codegen

% Reshape to ensure 0x2 when empty
roiMatrix = reshape([find(diff([0; mask(:)]) > 0),find(diff([mask(:); 0]) < 0)],[],2);
