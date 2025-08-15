function [P, W] = computephasedelay(this, N, varargin)
%PHASEDELAY   Calculate the phase delay.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.

if nargin < 2
    N = 8192;
end

[P, W] = phasedelay(this.Numerator, 1, N, varargin{:});


% [EOF]
