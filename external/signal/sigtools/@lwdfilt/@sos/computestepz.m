function [S, T] = computestepz(this, varargin)
%COMPUTESTEPZ   

%   Copyright 1988-2012 The MathWorks, Inc.

% Get SOS matrix with embedded scale values
sosMatrix = getsosmatrix(this);

[S, T] = stepz(sosMatrix,varargin{:});

