function [num, den] = tf(h)
%TF Create a Transfer Function from the poles and zeros

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

p = find(h, '-isa', 'sigaxes.pole');
z = find(h, '-isa', 'sigaxes.zero');

if isempty(z)
    num = 1;
else
    num = poly(double(z, 'conj'));
end

if isempty(p)
    den = 1;
else
    den = poly(double(p, 'conj'));
end

% [EOF]
