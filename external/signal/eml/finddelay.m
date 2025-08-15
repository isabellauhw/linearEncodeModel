function d = finddelay(x,y,varargin)
%MATLAB Code Generation Library Function

%   Copyright 2006-2016 The MathWorks, Inc.
%#codegen

coder.inline('always');
narginchk(2,3);
% This wrapper will be inlined. This may help the compiler to keep the
% output d as an integer type rather than double precision floating point
% when the values in d are used in indexing operations.
di = FindDelay(x,y,varargin{:});
d = double(di);

%--------------------------------------------------------------------------

function d = FindDelay(x_in,y_in,varargin)
coder.inline('never');
coder.internal.assert(isnumeric(x_in), ...
    'signal:finddelay:firstInputNumeric');
coder.internal.assert(ismatrix(x_in) && ~isempty(x_in), ...
    'signal:finddelay:firstInputVectorMatrix');
coder.internal.assert(isnumeric(y_in), ...
    'signal:finddelay:secondInputNumeric');
coder.internal.assert(ismatrix(y_in) && ~isempty(y_in), ...
    'signal:finddelay:secondInputVectorMatrix');
ONE = coder.internal.indexInt(1);
ISVECTORX = coder.internal.isConst(isvector(x_in)) && isvector(x_in);
ISVECTORY = coder.internal.isConst(isvector(y_in)) && isvector(y_in);
if ~(ISVECTORX && ISVECTORY) && isrow(x_in) && isrow(y_in)
    % Here, variable-size matrix inputs become run-time row-vectors. A
    % side effect of supporting this is that it will not be possible to
    % return a result with a fixed number of columns when both inputs have
    % a variable number of rows.
    d = FindDelay(x_in(1,:),y_in(1,:),varargin{:});
    return
end
if ISVECTORX
    if ~isfloat(x_in)
        x = double(x_in(:));
    else
        x = x_in(:);
    end
    mx = coder.internal.indexInt(length(x));
    nx = ONE;
    cxx0 = sumsq(x);
else
    if ~isfloat(x_in)
        x = double(x_in);
    else
        x = x_in;
    end
    mx = coder.internal.indexInt(size(x,1));
    nx = coder.internal.indexInt(size(x,2));
end
if ISVECTORY
    if ~isfloat(y_in)
        y = double(y_in(:));
    else
        y = y_in(:);
    end
    my = coder.internal.indexInt(length(y));
    ny = ONE;
    cyy0 = sumsq(y);
else
    if ~isfloat(y_in)
        y = double(y_in);
    else
        y = y_in;
    end
    my = coder.internal.indexInt(size(y,1));
    ny = coder.internal.indexInt(size(y,2));
end
coder.internal.assert(ISVECTORX || ISVECTORY || nx == ny, ...
    'signal:finddelay:sameNumberColumns');
% Allocate the output.
if ISVECTORX && ISVECTORY
    dlen = ONE;
elseif ISVECTORX
    dlen = ny;
else
    dlen = nx;
end
d = coder.nullcopy(zeros(1,dlen,coder.internal.indexIntClass));
% Process third (optional) argument.
% By default maxlag is a scalar equal to max(MX,MY)-1.
if nargin < 3
    in3 = [];
else
    in3 = varargin{1};
end
if coder.internal.isConst(isempty(in3)) && isempty(in3)
    maxlag = max(mx,my) - 1;
    SCALARMAXLAG = true;
else
    SCALARMAXLAG = coder.internal.isConst(isscalar(in3)) && isscalar(in3);
    % maxlag must be numeric and real.
    coder.internal.assert(isnumeric(in3) && isreal(in3), ...
        'signal:finddelay:maxlagNumericReal');
    % maxlag must be a scalar or a vector.
    coder.internal.assert(isvector(in3), ...
        'signal:finddelay:maxlagScalarVector');
    % maxlag cannot be Inf or NaN.
    coder.internal.assert(~anyNonFinite(in3), ...
        'signal:finddelay:maxlagNanInf');
    % maxlag must be integer-valued.
    coder.internal.assert(allIntegerValued(in3), ...
        'signal:finddelay:maxlagInteger');
    if ~SCALARMAXLAG
        % Make sure the length is of non-scalar maxlag input is correct.
        % Each case checks the same thing, but the error message is
        % specific to the given case.
        lengthOK = length(in3) == dlen;
        if ISVECTORX && ISVECTORY
            coder.internal.assert(lengthOK, ...
                'signal:finddelay:maxlagScalar');
        elseif ISVECTORX
            coder.internal.assert(lengthOK, ...
                'signal:finddelay:maxlagLengthColumnsY');
        elseif ISVECTORY
            coder.internal.assert(lengthOK, ...
                'signal:finddelay:maxlagLengthColumnsX');
        else
            coder.internal.assert(lengthOK, ...
                'signal:finddelay:maxlagLengthColumnsXY');
        end
    end
    maxlag = coder.internal.indexInt(abs(in3));
end
% Process the columns.
for j = 1:dlen
    if ISVECTORX
        xj = x;
    else
        xj = x(:,j);
        cxx0 = sumsq(xj);
    end
    if ISVECTORY
        yj = y;
    else
        yj = y(:,j);
        cyy0 = sumsq(yj);
    end
    if SCALARMAXLAG
        maxlagj = maxlag;
    else
        maxlagj = maxlag(j);
    end
    [d(j),max_c] = vFindDelay(xj,yj,maxlagj,cxx0,cyy0);
    % Set to zeros estimated delays for which the normalized
    % cross-correlation values are below a given threshold (spurious peaks
    % due to FFT roundoff errors).
    if max_c < 1e-8
        d(j) = 0;
        if dlen == 1 && maxlagj ~= 0
            coder.internal.warning( ...
                'signal:finddelay:noSignificantCorrelationScalar');
        elseif isvector(d) && maxlagj ~= 0
            coder.internal.warning( ...
                'signal:finddelay:noSignificantCorrelationVector',j);
        end
    end
end

%--------------------------------------------------------------------------

function [d,max_c] = vFindDelay(x,y,maxlag,cxx0,cyy0)
% FINDDELAY for column vectors x and y.
% The inputs cxx0 and cyy0 should be:
%   cxx0 = sum(abs(x).^2);
%   cyy0 = sum(abs(y).^2);
% Initialize some constants.
ZERO = coder.internal.indexInt(0);
ONE = coder.internal.indexInt(1);
nc = 2*maxlag + 1;
d = ZERO;
max_c = coder.internal.scalarEg(x,y);
scale = sqrt(cxx0*cyy0);
% Quick return for trivial inputs. Empty inputs will have scale == 0.
if maxlag == 0 || scale == 0
    return
end
index_max = ZERO;
index_max_pos = ONE;
index_max_neg = ONE;
c = xcorr(x,y,maxlag);
% Process the negative lags in flipped order.
max_c_neg = abs(c(maxlag))/scale;
for k = 2:maxlag
    vneg = abs(c(maxlag - k + 1))/scale;
    if vneg > max_c_neg
        max_c_neg = vneg;
        index_max_neg = k;
    end
end
% Process the positive lags.
max_c_pos = abs(c(maxlag + 1))/scale;
for k = maxlag + 2:nc
    vpos = abs(c(k))/scale;
    if vpos > max_c_pos
        max_c_pos = vpos;
        index_max_pos = k - maxlag;
    end
end
if maxlag == 0
    % Case where MAXLAG is zero.
    index_max = index_max_pos;
elseif max_c_pos > max_c_neg
    % The estimated lag is positive or zero.
    index_max = maxlag + index_max_pos;
    max_c = max_c_pos;
elseif max_c_pos < max_c_neg
    % The estimated lag is negative.
    index_max = maxlag + 1 - index_max_neg;
    max_c = max_c_neg;
elseif max_c_pos == max_c_neg
    max_c = max_c_pos;
    if index_max_pos <= index_max_neg
        % The estimated lag is positive or zero.
        index_max = maxlag + index_max_pos;
    else
        % The estimated lag is negative.
        index_max = maxlag + 1 - index_max_neg;
    end
end
d = (maxlag + 1) - index_max;

%--------------------------------------------------------------------------

function s = sumsq(x)
% s = sum(abs(x).^2)
% The input x is assumed to be a vector.
s = zeros('like',real(x));
nx = coder.internal.indexInt(length(x));
if isreal(x)
    for k = 1:nx
        s = s + x(k)*x(k);
    end
else
    for k = 1:nx
        xk = abs(x(k));
        s = s + xk*xk;
    end
end

%--------------------------------------------------------------------------

function p = allIntegerValued(x)
% p = all(x == floor(x)) without creating temporary arrays.
p = true;
if isfloat(x)
    for k = 1:numel(x)
        p = p && (x(k) == floor(x(k)));
    end
end

%--------------------------------------------------------------------------

function p = anyNonFinite(x)
% p = all(isfinite(x(:))).
% Delete this function and use coder.internal.anyNonFinite when available.
p = false;
if isfloat(x)
    for k = 1:numel(x)
        p = p || isnan(x(k)) || isinf(x(k));
    end
end

%--------------------------------------------------------------------------
