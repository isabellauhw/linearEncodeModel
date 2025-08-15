function [props, descs] = getbuttonprops(h)
%GETBUTTONPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

[props, descs] = abstract_getbuttonprops(h);

dp = get(h, 'DisabledProps');

for idx = 1:length(dp)
    indx = strcmpi(dp(idx), props);
    if ~isempty(indx)
        props(indx) = [];
        descs(indx) = [];
    end
end

% [EOF]
