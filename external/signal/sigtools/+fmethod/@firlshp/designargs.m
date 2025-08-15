function args = designargs(this, hs)
%DESIGNARGS   Return the design inputs.

%   Copyright 1999-2015 The MathWorks, Inc.

N = get(hs, 'FilterOrder');

args = {N, [0 hs.Fstop hs.Fpass 1], [0 0 1 1], [this.Wstop this.Wpass]};

% If the filter order requested is odd, we need to append 'h' to design a
% hilbert transformer and avoid erroring.
if rem(N, 2) == 1
    args{end+1} = 'h';
end

% [EOF]
