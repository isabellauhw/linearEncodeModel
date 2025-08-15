function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Copyright 1999-2017 The MathWorks, Inc.

order = hs.FilterOrder;

if ~rem(order,2)
    error(message('signal:fmethod:firlsdifford:designargs:invalidSpec'));
end

args = {order, [0 1], [0 pi],'differentiator'};

% [EOF]
