function [Gd, w] = computegrpdelay(this, N, varargin)
%COMPUTEGRPDELAY   

%   Copyright 1988-2012 The MathWorks, Inc.

if nargin < 2
    N = 8192;
end

% Get SOS matrix, set embedScaleValues falg to false
sosMatrix = getsosmatrix(this,false);

[Gd, w] = grpdelay(sosMatrix, N, varargin{:});
