function [I, T] = computeimpz(this, varargin)
%COMPUTEIMPZ   Compute impulse response
% [I, T] = computeimpz(this, N, Fs)

%   Copyright 1988-2012 The MathWorks, Inc.


% Get SOS matrix with embedded scale values
sosMatrix = getsosmatrix(this);

[I, T] = impz(sosMatrix,varargin{:});