function maxmnum = computeMaxM(FRF,f,fs,fidx)
%COMPUTEMAXM Compute the maximum number of modes 
% Compute the maximum number of modes (model order) possible.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016 The MathWorks, Inc.

% Compute the maximum modal order, mnum, based on the impulse response
% length.
import signal.internal.modal.* 
oFactor = 10;
fs = fs*sum(fidx)/length(fidx);
hLen = numel(computeIR(FRF(fidx,1,1),f(fidx),fs));
maxmnum = floor(hLen/(2*oFactor + 2));
