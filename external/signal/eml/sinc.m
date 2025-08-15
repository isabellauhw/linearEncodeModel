function x = sinc(x)
%MATLAB Code Generation Library Function

% Copyright 1984-2016 The MathWorks, Inc.
%#codegen

THRESH = coder.const(realmin(class(x))/eps(class(x)));
for k = 1:numel(x)
    if abs(real(x(k))) < THRESH && abs(imag(x(k))) < THRESH
        x(k) = 1;
    else
        x(k) = pi*x(k);
        x(k) = sin(x(k))/x(k);
    end
end
