function [G, W] = computegrpdelay(this, N, varargin)
%GRPDELAY   Calculate the group delay.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if nargin < 2
    N = 8192;
end

[G, W] = grpdelay(this.Numerator, this.Denominator, N, varargin{:});

% [EOF]
