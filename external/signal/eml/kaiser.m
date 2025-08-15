function w = kaiser(N,BTA)
%MATLAB Code Generation Library Function

%   Copyright 1988-2016 The MathWorks, Inc.
%#codegen

narginchk(1,2);
coder.internal.prefer_const(N);
% Cast to enforce Precision Rules
n = signal.internal.sigcasttofloat(N, ...
    'double','kaiser','N','allownumeric');
if nargin < 2 || (coder.internal.isConst(isempty(BTA)) && isempty(BTA)) 
    bta = 0.500; % default value for bta parameter.
else
    coder.internal.prefer_const(BTA);
    bta = signal.internal.sigcasttofloat(BTA,'double','kaiser','BTA',...
        'allownumeric');
end
% For backward compatibility, force a constant output if the inputs are
% constant.
if coder.internal.isConst(n) && coder.internal.isConst(bta) && ...
    coder.internal.isCompiled
    w = coder.const(feval(mfilename,n,bta));
    return
end
if coder.internal.isConst(bta)
    bestmp = coder.const(feval('besseli',0,bta));
    bes = coder.const(abs(bestmp));
else
    bes = abs(besseli(0,bta));
end
ONE = coder.internal.indexInt(1);
nw = check_order(n);
% Allocate w.
w = coder.nullcopy(zeros(nw,1));
if nw <= 1
    w(:) = 1;
    return
end
% Fill the second half of w.
iseven = ONE - eml_bitand(nw,ONE);
mid = eml_rshift(nw,ONE);
maxxi = double(nw) - 1;
midp1 = mid + 1;
for k = midp1:nw
    xi = iseven + 2*(k - midp1);
    r = double(xi)/maxxi;
    z = bta*sqrt((1 - r)*(1 + r));
    w(k) = abs(besseli(0,z)/bes);
end
% Flip the second half into the first half.
for k = 1:mid
    w(k) = w(nw - k + 1);
end
