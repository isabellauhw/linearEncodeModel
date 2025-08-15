function args = designargs(this, hspecs)
%DESIGNARGS   Return the arguments for FIR1

%   Copyright 1999-2015 The MathWorks, Inc.

N = get(hspecs,'FilterOrder');

% If we are passed a window function, use it to calculate the window vector
win = calculatewin(this, N);

% Add scaling flag to the inputs
flag = getscalingflag(this);
args = {N, hspecs.Fcutoff, 'high', win{:}, flag};

% If the filter order requested is odd, we need to append 'h' to design a
% hilbert transformer and avoid erroring.
if rem(N, 2) == 1
    args{end+1} = 'h';
end

% [EOF]
