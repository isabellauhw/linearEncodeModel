function [I, T] = computeimpz(this, varargin)
%IMPZ   Calculate the impulse response.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

[I, T] = impz(this.Numerator, 1, varargin{:});

% [EOF]
