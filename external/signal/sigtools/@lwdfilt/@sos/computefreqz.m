function [h, w] = computefreqz(this, N, varargin)
%COMPUTEFREQZ   

%   Copyright 1988-2012 The MathWorks, Inc.

if nargin < 2
    N = 8192;
end

% Get SOS matrix with embedded scale values
sosMatrix = getsosmatrix(this);

[h, w] = freqz(sosMatrix, N, varargin{:});
