function args = designargs(this, hspecs)
%DESIGNARGS   Return the arguments for FIR1

%   Copyright 1999-2015 The MathWorks, Inc.


% If we are passed a window function, use it to calculate the window vector
win = calculatewin(this, hspecs.FilterOrder);

% Add scaling flag to the inputs
flag = getscalingflag(this);

args = {hspecs.FilterOrder, hspecs.Fcutoff, win{:}, flag};

% [EOF]
