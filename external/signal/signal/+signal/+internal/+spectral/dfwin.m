function Wdf = dfwin(w,Fs)
%DFWIN differentiate window in frequency domain
%   This function is for internal use only. It may be removed in the future.
%
%   See also DTWIN.
%

%   Copyright 2016-2019 The MathWorks, Inc.

%   multiply by time ramp to implement differentiation in frequency domain
%#codegen

n = numel(w);
Wdf = w .* ((1-n)/2:(n-1)/2)'/Fs;

% LocalWords:  DTWIN
