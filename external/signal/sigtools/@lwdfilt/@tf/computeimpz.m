function [I, T] = computeimpz(this, varargin)
%COMPUTEIMPZ   Calculate the impulse response.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

[I, T] = impz(this.Numerator, this.Denominator, varargin{:});

% [EOF]
