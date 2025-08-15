function h = vector(limit, varargin)
%VECTOR Construct a vector

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = sigutils.vector;

if nargin > 0
    set(h, 'Limit', limit);
end

for i = 1:length(varargin)
    h.addelement(varargin{i});
end

% [EOF]
