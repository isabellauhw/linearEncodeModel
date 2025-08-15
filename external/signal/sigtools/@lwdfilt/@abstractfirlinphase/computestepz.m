function [S, T] = computestepz(this, varargin)
%STEPZ   Calculate the step response.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

[S, T] = stepz(this.Numerator, 1, varargin{:});

% [EOF]
