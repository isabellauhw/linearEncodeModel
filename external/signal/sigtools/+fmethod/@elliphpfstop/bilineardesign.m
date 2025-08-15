function [s,g] = bilineardesign(h,has,c)
%BILINEARDESIGN  Design digital filter from analog specs. using bilinear. 

%   Copyright 1999-2015 The MathWorks, Inc.


% Call lowpass design
[s,g] = mybilineardesign(h,has,c);

% Change required signs
s(:,[2,5]) = -s(:,[2,5]);

% [EOF]
