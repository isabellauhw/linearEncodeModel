function b = rcoswindesign(this, hspecs, shape)
%RCOSWINDESIGN Design a raised cosine filter

%   Copyright 1999-2015 The MathWorks, Inc.

args = designargs(this, hspecs);

N = args{1};
beta = args{2};
sps = args{3};

h = rcosdesign(beta, N/sps, sps, shape);
if strcmp(shape,'normal')
    h = h / max(h) / sps;
else
    h = h / max(h) * ((-1 ./ (pi.*sps) .* (pi.*(beta-1) - 4.*beta)));
end

b = {h};

% [EOF]
