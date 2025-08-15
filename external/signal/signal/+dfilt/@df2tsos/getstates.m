function z = getstates(Hd,dummy)
%GETSTATES Overloaded get for the States property.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

zh = Hd.HiddenStates;

if ~isempty(zh)
    % Reshape to what users see
    [M,N] = size(zh);
    nsecs = nsections(Hd);
    ns = 2*nsecs;
    z = reshape(zh,ns/nsecs,M*N/(ns/nsecs));
else
    z = [];
end

