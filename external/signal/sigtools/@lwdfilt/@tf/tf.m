function this = tf(num, den)
%TF   Construct a TF object.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

this = lwdfilt.tf;

if nargin > 0
    set(this, 'Numerator', num);
    set(this, 'refnum', num);
    if nargin > 1
        set(this, 'Denominator', den);
        set(this, 'refden', den);
    end
end

% [EOF]
