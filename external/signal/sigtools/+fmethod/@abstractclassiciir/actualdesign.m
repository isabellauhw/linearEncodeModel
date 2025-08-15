function coeffs = actualdesign(this,hs)
%ACTUALDESIGN   Design the filter and return the coefficients.

%   Copyright 1999-2015 The MathWorks, Inc.

% Compute analog filter specs object
has = analogspecs(this,hs);

% Compute 'c' parameter 
c = cparam(hs);

% Design digital filter from analog response object using bilinear
% transformation
[s,g] = bilineardesign(this,has,c);

coeffs = {s,g};

% [EOF]
