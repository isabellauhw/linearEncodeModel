function y=sinc(x)
%SINC Sin(pi*x)/(pi*x) function for tall array X.
%   SINC(X)
%
%   See also TALL, SINC.

%   Copyright 2017 The MathWorks, Inc.

% SINC uses SIN, which only supports floats
x = tall.validateType(x, mfilename, {'double', 'single'}, 1);

% Simply call SINC on each partition
y = elementfun(@sinc, x);

% Output is always same type and size as input
y.Adaptor = x.Adaptor;

