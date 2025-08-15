function args = designargs(this, hspecs)
%DESIGNARGS   Return the arguments for FIR1

%   Copyright 1999-2015 The MathWorks, Inc.

N = get(hspecs, 'FilterOrder');

% If we are passed a window function, use it to calculate the window vector
win = calculatewin(this, N);

% Add scaling flag to the inputs
flag = getscalingflag(this);

args = {N, [hspecs.Fcutoff1 hspecs.Fcutoff2], 'stop', win{:}, flag};

if rem(N, 2)
    args{end+1} = 'h';
end

% [EOF]
