function [hz, wz, phiz, opts] = computezerophase(this, N, varargin)
%COMPUTEZEROPHASE

%   Copyright 1988-2012 The MathWorks, Inc.

% This should be private

if nargin < 2
    N = 8192;
end

% Get SOS matrix with embedded scale values
sosMatrix = getsosmatrix(this);

[hz,wz,phiz,opts] = zerophase(sosMatrix, N, varargin{:});
