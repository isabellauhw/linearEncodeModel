function [P, W] = computephasedelay(this, N, varargin)
%PHASEDELAY   Calculate the phase delay.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if nargin < 2
    N = 8192;
end

[P, W] = phasedelay(this.Numerator, this.Denominator, N, varargin{:});


% [EOF]
