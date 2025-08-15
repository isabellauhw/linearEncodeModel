function [strs, lbls] = setstrs(h)
%SETSTRS Return the strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Get current magunits
magOpts = set(h,'MagUnits');
props   = allprops(h);

switch h.magUnits
case magOpts{1}
    strs = props(1:end/3);
case magOpts{2}
    strs = props(end/3+1:2*end/3);
case magOpts{3}
    strs = props(2*end/3+1:end);
end

lbls = cell(size(strs));
for indx = 1:length(strs)
    lbls{indx} = [strs{indx} ':'];
end

% [EOF]
