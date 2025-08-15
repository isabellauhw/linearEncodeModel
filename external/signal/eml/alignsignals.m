function [xa,ya,dd] = alignsignals(x,y,varargin)
%MATLAB Code Generation Library Function

%   Copyright 2006-2016 The MathWorks, Inc.
%#codegen

narginchk(2,4);
coder.internal.prefer_const(varargin);
coder.internal.assert(isnumeric(x), ...
    'signal:alignsignals:firstInputNumeric');
coder.internal.assert(isvector(x), ...
    'signal:alignsignals:firstInputVector','IfNotConst','Fail');
coder.internal.assert(isnumeric(y), ...
    'signal:alignsignals:secondInputNumeric');
coder.internal.assert(isvector(y), ...
    'signal:alignsignals:secondInputVector','IfNotConst','Fail');
ONE = coder.internal.indexInt(1);
lx = coder.internal.indexInt(length(x));
ly = coder.internal.indexInt(length(y));
ISROWX = coder.internal.isConst(isrow(x)) && isrow(x);
ISROWY = coder.internal.isConst(isrow(y)) && isrow(y);
% The only valid 4th input is 'truncate'.
TRUNCATE = (nargin == 4);
coder.internal.assert(~TRUNCATE || strcmp(varargin{2},'truncate'), ...
    'signal:alignsignals:invalidOption');
% Estimate delay between X and Y.
if nargin < 3
    di = coder.internal.indexInt(finddelay(x,y));
else
    maxlag_default = max(lx,ly) - 1;
    maxlag = process_maxlag_input(varargin{1},maxlag_default);
    di = coder.internal.indexInt(finddelay(x,y,maxlag));
end
% Determine the initial index.
if di == 0
    % Signals are already aligned. Start copying into index = 1.
    ix0 = ONE;
    iy0 = ONE;
elseif di > 0
    % X is delayed wrt Y. Shift X to the right by di.
    ix0 = di + 1;
    iy0 = ONE;
else
    % Y is delayed wrt X. Shift Y to the right by abs(di).
    ix0 = ONE;
    iy0 = 1 - di;
end
% Determine the output lengths.
if TRUNCATE
    lxa = lx;
    lya = ly;
    if ix0 > lx
        coder.internal.warning('signal:alignsignals:firstInputTruncated');
    end
    if iy0 > ly
        coder.internal.warning('signal:alignsignals:secondInputTruncated');
    end
else
    lxa = lx + ix0 - 1;
    lya = ly + iy0 - 1;
end
% Allocate the output arrays.
if ISROWX
    xa = zeros(1,lxa,'like',x);
else
    xa = zeros(lxa,1,'like',x);
end
if ISROWY
    ya = zeros(1,lya,'like',y);
else
    ya = zeros(lya,1,'like',y);
end
% Copy the data.
for k = ix0:lxa
    xa(k) = x(k - ix0 + 1);
end
for k = iy0:lya
    ya(k) = y(k - iy0 + 1);
end
% Cast di to double for third output.
dd = double(di);
  
%--------------------------------------------------------------------------

function maxlag = process_maxlag_input(arg,maxlag_default)
coder.internal.prefer_const(arg,maxlag_default);
% maxlag must be numeric and real.
% maxlag must be a scalar (or empty).
% maxlag cannot be Inf or NaN.
% maxlag must be integer-valued.
coder.internal.assert(isnumeric(arg) && isreal(arg), ...
    'signal:alignsignals:maxlagNumericReal');
coder.internal.assert( ...
    (coder.internal.isConst(isscalar(arg)) && isscalar(arg)) || ...
    (coder.internal.isConst(isempty(arg)) && isempty(arg)), ...
    'signal:alignsignals:maxlagScalar','IfNotConst','Fail');
if isempty(arg)
    maxlag = maxlag_default;
else
    coder.internal.assert(isfinite(arg), ...
        'signal:alignsignals:maxlagNanInf');
    coder.internal.assert(arg == floor(arg), ...
        'signal:alignsignals:maxlagInteger');
    maxlag = coder.internal.indexInt(abs(arg));
end

%--------------------------------------------------------------------------
