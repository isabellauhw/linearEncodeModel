function [Ph, W] = computephasedelay(this,N,varargin)
%COMPUTEPHASEDELAY   Calculate the phase delay of the filter.

%   Copyright 1988-2012 The MathWorks, Inc.

if nargin < 2
    N = 8192;
end

% Get SOS matrix, set embedScaleValues falg to false
sosMatrix = getsosmatrix(this,false);

[Ph, W] = phasedelay(sosMatrix, N, varargin{:});

