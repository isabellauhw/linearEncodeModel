function [b,a,n,m] = eqtflength(num,den)
%EQTFLENGTH   Equalize the length of a discrete-time transfer function.
%   [B,A] = EQTFLENGTH(NUM,DEN) forces NUM and DEN to be of the same
%   length by appending zeros to either one as necessary.  If both NUM
%   and DEN have common trailing zeros, they are removed from both of
%   them.
%
%   EQTFLENGTH is intended to be used with discrete-time transfer
%   functions expressed in terms of negative powers of Z only.
%
%   [B,A,N,M] = EQTFLENGTH(NUM,DEN) returns the numerator order N and
%   the denominator order M, not including trailing zeros.

%   Author(s): R. Losada
%   Copyright 1988-2018 The MathWorks, Inc.

%#codegen

narginchk(2,2);
if coder.target('MATLAB')
    [b,a,n,m] = eqtflengthImpl(num,den);
else
    if coder.internal.isConst(num) && coder.internal.isConst(den) && coder.internal.isCompiled
        [b,a,n,m] = coder.const(@feval,'eqtflength',num,den);
    else
        [b,a,n,m] = eqtflengthImpl(num,den);
    end
end

end

function [b,a,n,m] = eqtflengthImpl(num,den)

if isempty(num) && isnumeric(num)
    num1 = zeros(1,1,class(num));
else
    num1 = num;
end

validateattributes(num1,{'numeric'},{'vector'},'eqtflength','num',1);
validateattributes(den, {'numeric'},{'vector','nonempty'},'eqtflength','den',2);
% Catch cases when the den is zero
% Divide by zero not allowed
if (max(abs(den(:)))==0)
    coder.internal.error('signal:eqtflength:InvalidRange')
end
% First make num1 and den rows
y = num1(:).';
x = den(:).';

% Then make them of equal length
x1 = [x zeros(1,max(0,length(y)-length(x)))];
y1 = [y zeros(1,max(0,length(x)-length(y)))];

% Now remove trailing zeros, but only if present in both x1 and y1
i = find(x(:),1,'last');
j = find(y(:),1,'last');
% Get the orders of the numerator and denominator
m = i(1) - 1;

% If the numerator is all zeros, j will be empty, catch this case
% note that i will never be empty, if x is all zeros, an error is
% returned above.
if isempty(j)
    n = 0;
else
    n = j(1) - 1;
end

% Get the index of the largest negative order nonzero element
range = max(m+1,n+1);

a = x1(1:range);
b = y1(1:range);
end

% [EOF] - eqtflength.m
