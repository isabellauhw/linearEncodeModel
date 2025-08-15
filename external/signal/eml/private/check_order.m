function [n_out,trivialwin] = check_order(n_in)
%MATLAB Code Generation Private Function

%   Copyright 1988-2019 The MathWorks, Inc.
%#codegen

trivialwin = false;

if(coder.internal.isConst(isempty(n_in)) && isempty(n_in))
    n_out = coder.internal.indexInt(0);
    trivialwin = true;
    return
end

n_in = n_in(1);

coder.internal.assert(isnumeric(n_in) && isfinite(n_in), ...
    'signal:check_order:InvalidOrderFinite','N')
coder.internal.assert(isreal(n_in) , ...
    'signal:check_order:InvalidOrderComplex','N');
% Special case of negative orders:
coder.internal.assert(n_in >= 0, ...
    'signal:check_order:InvalidOrderNegative');
% Check if order is already an integer or empty
% If not, round to nearest integer.
if ~isfloat(n_in) || n_in == floor(n_in)
    n_out = coder.internal.indexInt(n_in);
else
    n_out = coder.internal.indexInt(round(n_in));
    coder.internal.warning('signal:check_order:InvalidOrderRounding');
end

end
