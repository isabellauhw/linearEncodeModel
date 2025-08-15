function [s,g] = bilineardesign(h,has,c)
%BILINEARDESIGN  Design digital filter from analog specs. using bilinear. 

%   Copyright 1999-2015 The MathWorks, Inc.

% Call the lowpass method
[s,g] = thisbilineardesign(h,has,c);

% Change sign of a1 and b1
s(:,2) = -s(:,2);
s(:,5) = -s(:,5);

% [EOF]
