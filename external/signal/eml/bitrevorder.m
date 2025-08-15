function [y,idx] = bitrevorder(x)
%MATLAB Code Generation Library Function

%   Limitations:  Returns zeros(1,0) for idx in situations where MATLAB
%   returns [], e.g. [y,idx] = bitrevorder(zeros(0,1))

%   Copyright 2002-2011 The MathWorks, Inc.
%#codegen

eml_invariant(nargin > 0, ...
    eml_message('Coder:MATLAB:minrhs'));
eml_invariant(ndims(x) <= 2, ...
    eml_message('signal:digitrevorder:InvalidDimensions'));
if nargout == 2
    coder.inline('always');
    [y,iidx] = local_bitrevorder(x);
    idx = double(iidx);
else
    y = local_bitrevorder(x);
end

%--------------------------------------------------------------------------

function [y,iidx] = local_bitrevorder(x)
if nargout == 2
    coder.inline('never');
end
ucls = eml_unsigned_class(eml_index_class);
ONE = ones(ucls);
ZERO = zeros(ucls);
% Find first non-singleton dimension of X.
dim = eml_nonsingleton_dim(x);
n = cast(size(x,dim),ucls);
y = coder.nullcopy(x);
iidx = coder.nullcopy(zeros(n,1,ucls));
if n == 0
elseif n == 1
    y = x;
    iidx(1) = 1;
else
    eml_invariant(eml_size_ispow2(n), ...
        eml_message('signal:digitrevorder:MustBeInteger','2'));
    radixpow = local_ilog2(n);
    nx = cast(eml_numel(x),ucls);
    if n < nx
        npages = cast(eml_prodsize_except_dim(x,dim),ucls);
    elseif nx == ZERO
        npages = ZERO;
    else
        npages = ONE;
    end
    % Compute flipped digit indices.  Do this by casting to uint and
    % then shifting indices up to radixpow.
    for k1 = ONE:n
        i1 = eml_minus(k1,ONE,ucls,'spill'); % 1-based to 0-based.
        i2 = ZERO;
        for k2 = ONE:radixpow
            i2 = eml_bitor(eml_lshift(i2,ONE),eml_bitand(i1,ONE));
            i1 = eml_rshift(i1,ONE);
        end
        i2 = eml_plus(i2,ONE,ucls,'spill');
        if nargout == 2
            iidx(k1) = i2;
        end
        if npages > ZERO
            y(k1) = x(i2);
            if npages > ONE
                for k = ONE:eml_minus(npages,ONE,ucls,'spill')
                    y(eml_plus(k1,eml_times(k,n,ucls,'spill'),ucls,'spill')) = ...
                        x(eml_plus(i2,eml_times(k,n,ucls,'spill'),ucls,'spill'));
                end
            end
        end
    end
end

%--------------------------------------------------------------------------

function logn = local_ilog2(n)
%   floor(log2(n)) for positive integer n.
%   There is no error checking on the assumption n >= 1.
%   There is no error checking on the assumption that n is an integer.

eml_prefer_const(n);
if isa(n,'float')
    logn = floor(log2(n));
elseif eml_is_const(n)
    logn = eml_const(cast(floor(log2(double(n))),class(n)));
elseif eml_isa_uint(n)
    logn = local_unsigned_ilog2(n);
elseif isinteger(n)
    logn = cast( ...
        local_unsigned_ilog2(cast(n,eml_unsigned_class(class(n)))), ...
        class(n));
else
    eml_assert(false,['Unsupported input type: ',class(n)]);
end

%--------------------------------------------------------------------------

function logn = local_unsigned_ilog2(n)
% floor(log2(n)) for unsigned integer n.
logn = zeros(class(n));
nbits = eml_const(eml_int_nbits(class(n)));
its = eml_const(cast(log2(double(nbits)),class(n)));
for k = coder.unroll(1:its)
    M = eml_const(eml_rshift(nbits,k));
    if n >= eml_const(eml_lshift(ones(class(n)),M))
        n = eml_rshift(n,M);
        logn = eml_plus(logn,M,class(n),'spill');
    end
end
