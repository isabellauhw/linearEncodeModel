function flag = getscalingflag(this)
%GETSCALINGFLAG   Get the scalingflag.

%   Copyright 1999-2015 The MathWorks, Inc.

if this.ScalePassband
    flag = 'scale';
else
    flag = 'noscale';
end

% [EOF]
