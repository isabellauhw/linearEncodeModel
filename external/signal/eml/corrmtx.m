function [X,R] = corrmtx(x,M,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1988-2020 The MathWorks, Inc.
%#codegen

narginchk(2,3);
method = get_method(varargin{:});
coder.internal.assert(isvector(x),'signal:corrmtx:SigMustBeVector');
N = length(x);
validateattributes(M,{'double'}, ...
    {'scalar','nonnegative','integer','<',N},'corrmtx','M');
n = coder.internal.indexInt(N);
m = coder.internal.indexInt(M);
nColsX = m + 1;
switch method
    case PREWINDOWED
        nRowsX = n;
        X = coder.nullcopy(zeros(nRowsX,nColsX,'like',x));
        t = sqrt(N);
        for i = 1:nRowsX
            X(i,1) = x(i)/t;
        end
        for j = 2:nColsX
            for i = 1:j - 1
                X(i,j) = 0;
            end
            for i = j:nRowsX
                X(i,j) = X(i - 1,j - 1);
            end
        end
    case POSTWINDOWED
        nRowsX = n;
        X = coder.nullcopy(zeros(nRowsX,nColsX,'like',x));
        t = sqrt(N);
        for i = 1:nRowsX
            X(i,nColsX) = x(i)/t;
        end
        K = nRowsX - nColsX;
        for j = m:-1:1
            nr = K + j;
            for i = 1:nr
                X(i,j) = X(i + 1,j + 1);
            end
            for i = nr + 1:nRowsX
                X(i,j) = 0;
            end
        end
    case AUTOCORRELATION        
        nRowsX = n + m;
        X = zeros(nRowsX,nColsX,'like',x);
        t = sqrt(N);
        for i = 1:n
            X(i,1) = x(i)/t;
        end 
        for j = 2:nColsX
            jm1 = j - 1;
            for i = 1:n
                X(jm1 + i,j) = X(jm1 - 1 + i,jm1);
            end
        end
    case MODIFIED
        nRowsXd2 = n - m;
        nRowsX = 2*nRowsXd2;
        X = coder.nullcopy(zeros(nRowsX,nColsX,'like',x));
        % Slight numerical differences versus MATLAB result from dividing
        % by sqrt(2*(N - M)) here versus dividing by sqrt(N - M) and then
        % subsequently dividing by sqrt(2).
        t = sqrt(2*(N - M));
        for i = 1:nRowsXd2
            X(i,1) = x(m + i)/t;
        end
        for j = 2:nColsX
            X(1,j) = x(nColsX + 1 - j)/t;
            for i = 2:nRowsXd2
                X(i,j) = X(i - 1,j - 1);
            end
        end
        for j = 1:nColsX
            srccol = nColsX + 1 - j;
            for i = 1:nRowsXd2
                X(nRowsXd2 + i,j) = conj(X(i,srccol));
            end
        end
    otherwise % COVARIANCE
        nRowsX = n - m;
        X = coder.nullcopy(zeros(nRowsX,nColsX,'like',x));
        t = sqrt(N - M);
        for i = 1:nRowsX
            X(i,1) = x(m + i)/t;
        end
        for j = 2:nColsX
            X(1,j) = x(nColsX + 1 - j)/t;
            for i = 2:nRowsX
                X(i,j) = X(i - 1,j - 1);
            end
        end
end
if nargout == 2
    R = X'*X;
    % Make sure it is exactly Hermitian.
    R = forceHermitian(R);
end

%---------------------------------------------------------------------------------------

function id = get_method(method)
%GET_METHOD  Match the user specified string to a known method.
if nargin == 0
    method = 'autocorrelation';
else
    coder.internal.prefer_const(method);
end
len = max(length(method),1);
if strncmpi(method,'autocorrelation',len)
    id = AUTOCORRELATION;
elseif strncmpi(method,'covariance',len)
    id = COVARIANCE;
elseif strncmpi(method,'modified',len)
    id = MODIFIED;
elseif strncmpi(method,'prewindowed',max(len,2))
    id = PREWINDOWED;
elseif strncmpi(method,'postwindowed',max(len,2))
    id = POSTWINDOWED;
else
    id = UNRECOGNIZED;
end
coder.internal.assert(id ~= UNRECOGNIZED, ...
    'signal:corrmtx:UnknMethod');

function id = UNRECOGNIZED
coder.inline('always');
id = int8(0);

function id = AUTOCORRELATION
coder.inline('always');
id = int8(1);

function id = COVARIANCE
coder.inline('always');
id = int8(2);

function id = MODIFIED
coder.inline('always');
id = int8(3);

function id = PREWINDOWED
coder.inline('always');
id = int8(4);

function id = POSTWINDOWED
coder.inline('always');
id = int8(5);

%---------------------------------------------------------------------------------------
