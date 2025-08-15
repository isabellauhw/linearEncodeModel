function [P, W] = computephasez(this, N, varargin)
%PHASEZ   Return the phase response.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if nargin < 2
    N = 8192;
end

[P, W] = phasez(this.Numerator, this.Denominator, N, varargin{:});


% [EOF]
