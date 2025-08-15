function [o, m, units] = cellengunits(o, varargin)
%CELLENGUNITS Returns the engunits across a cell array

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

m = inf;
for indx = 1:length(o)
    [otemp, mtemp, unitstemp] = engunits(o{indx}, varargin{:});
    if mtemp < m
        m = mtemp;
        units = unitstemp;
    end
end

for indx = 1:length(o)
    o{indx} = o{indx}*m;
end

% [EOF]
