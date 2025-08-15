function c = cconv(a,b,N)
%CCONV Modulo-N circular convolution.
%   C = CCONV(A, B, N) circularly convolves vectors A and B.  The resulting
%   vector is length N. If omitted, N defaults to LENGTH(A)+LENGTH(B)-1.
%   When N = LENGTH(A)+LENGTH(B)-1, the circular convolution is equivalent
%   to the linear convolution computed by CONV.
%
%   % Example #1: Mod-4 circular convolution
%   a = [2 1 2 1];
%   b = [1 2 3 4];
%   c = cconv(a,b,4)
%
%   % Example #2: Circular convolution as a fast linear convolution
%   a = [1 2 -1 1];
%   b = [1 1 2 1 2 2 1 1];
%   c = cconv(a,b,11)
%   cref = conv(a,b)
%
%   % Example #3: Circular cross-correlation
%   a = [1 2 2 1]+1i;
%   b = [1 3 4 1]-2*1i;
%   c = cconv(a,conj(fliplr(b)),7)
%   cref = xcorr(a,b)
%
%   See also CONV, XCORR

%   Copyright 2006-2019 The MathWorks, Inc.

%   Reference:
%     Sophocles J. Orfanidis, Introduction to Signal Processing,
%     Prentice-Hall, 1996
%#codegen

narginchk(2,3)

na = length(a);
nb = length(b);

isReal = isreal(a)&&isreal(b);

% Using length == numel allows N-D inputs that are vector-like in having
% only one dimension with size other than 1.
coder.internal.assert(na == numel(a) && nb == numel(b), ...
    'signal:cconv:AorBNotVector');

if nargin < 3
    N = na + nb - 1;
end

% Make orientations of the outputs of DATAWRAP consistent.
if isempty(coder.target)
    aw = datawrap(a,N);
    bw = datawrap(b,N);
    if isrow(aw) ~= isrow(bw)
        bw = bw.';
    end
else
    ISROWA = coder.const( ...
        coder.internal.isConst(isrow(a)) && isrow(a) && ...
        ~(coder.internal.isConst(isscalar(a)) && isscalar(a)));
    ISROWB = coder.const( ...
        coder.internal.isConst(isrow(b)) && isrow(b) && ...
        ~(coder.internal.isConst(isscalar(b)) && isscalar(b)));
    % This formulation takes into account cases where A or B are not
    % necessarily generalized vector types (i.e. when more than one
    % dimension is variable in length).
    if ISROWA
        aw = datawrap(a,N);
        if ISROWB
            bw = datawrap(b,N); 
        else
            bw = datawrap(b(:),N).';
        end
    else
        aw = datawrap(a(:),N);
        bw = datawrap(b(:),N);
    end
end

x = ifft(fft(aw,N).*fft(bw,N));

if isReal
   c = real(x);
else
   c = x;
end


% [EOF]
