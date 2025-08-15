function [Ph, w] = computephasez(this, N, varargin)
%COMPUTEPHASEZ   Calculate the phase response.

%   Copyright 1988-2012 The MathWorks, Inc.

if nargin < 2
    N = 8192;
end

% Get SOS matrix, set embedScaleValues falg to false
sosMatrix = getsosmatrix(this,false);

[Ph, w] = phasez(sosMatrix, N, varargin{:});

