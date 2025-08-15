function [H, W] = computefreqz(this, N, varargin)
%FREQZ   Calculate the frequency response of the filter.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if nargin < 2
    N = 8192;
end

[H, W] = freqz(this.Numerator, this.Denominator, N, varargin{:});

% [EOF]
