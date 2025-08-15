function [upperEnv,lowerEnv] = envelope(x,n,varargin)
%MATLAB Code Generation Library Function

%   Copyright 2015-2016 The MathWorks, Inc.
%#codegen

narginchk(1,3);
if nargout == 0
    % Plotting is not supported for code generation. If this is running in
    % MATLAB, just call MATLAB's ENVELOPE, else error.
    coder.internal.assert(coder.target('mex') || coder.target('Sfun'), ...
        'signal:codegeneration:PlottingNotSupported');
    if nargin < 2
        feval('envelope',x);
    else
        feval('envelope',x,n,varargin{:});
    end
    return
end
validateattributes(x,{'single','double'},{'2d','real','finite'},mfilename);
if nargin == 1
    [upperEnv,lowerEnv] = evaluateByColumns(@absHilb,x);
else
    coder.internal.prefer_const(n,varargin);
    validateattributes(n,{'numeric'},{'integer','scalar','positive'}, ...
        'envelope','N',2);
    method = parseMethod(varargin{:});
    ni = coder.internal.indexInt(n);
    if method == PEAK
        [upperEnv,lowerEnv] = evaluateByColumns(@envPeak,x,ni);
    elseif method == RMS
        [upperEnv,lowerEnv] = evaluateByColumns(@envRMS,x,ni);
    else % method == ANALYTIC
        firFilter = computeFirFilter(ni);
        [upperEnv,lowerEnv] = evaluateByColumns(@envFIR,x,firFilter);
    end
end

%--------------------------------------------------------------------------

function [a,b] = evaluateByColumns(f,x,varargin)
% Compute a 2-ouutput function f(x,varargin{:}) by columns, but also
% handle the row-vector special case.
coder.internal.prefer_const(varargin);
ncols = coder.internal.indexInt(size(x,2));
a = coder.nullcopy(zeros(size(x),'like',x));
b = coder.nullcopy(zeros(size(x),'like',x));
if isrow(x)
    [a(:),b(:)] = f(x(1,:).',varargin{:});
elseif ncols > 0
    a = coder.nullcopy(zeros(size(x),'like',x));
    b = coder.nullcopy(zeros(size(x),'like',x));
    for j = 1:ncols % good candidate for parfor
        [a(:,j),b(:,j)] = f(x(:,j),varargin{:});
    end
end

%--------------------------------------------------------------------------

function [upperEnv,lowerEnv] = absHilb(x)
% Assumes x is a real fixed-length or variable-length column vector.
upperEnv = coder.nullcopy(x);
lowerEnv = coder.nullcopy(x);
n = coder.internal.indexInt(size(x,1));
if n > 0
    xmean = mean(x,1);
    x = x - xmean;
    upperEnv = abs(hilbert(x)); % upperEnv temporarily stores the amplitude.
    lowerEnv = xmean - upperEnv;
    upperEnv = upperEnv + xmean;
end

%--------------------------------------------------------------------------

function firFilter = computeFirFilter(n)
% Construct ideal Hilbert filter truncated to desired length.
% t = fc/2 * ((1-n)/2:(n-1)/2)';
t = zeros(n,1);
tlo = (1 - double(n))/2;
nd2 = eml_rshift(n,coder.internal.indexInt(1));
for k = 1:nd2
    t(k) = (tlo + double(k - 1))/2;
    t(n - k + 1) = -t(k);
end
hfilt = sinc(t).*exp(1i*pi*t);
% multiply ideal filter with tapered window
beta = 8;
firFilter = hfilt.*kaiser(n,beta);
firFilter = firFilter/sum(real(firFilter));

%--------------------------------------------------------------------------

function [upperEnv,lowerEnv] = envFIR(x,firFilter)
% apply filter and take the magnitude
xmean = mean(x,1);
x = x - xmean;
upperEnv = abs(conv(x,firFilter,'same')); % upperEnv temporarily stores the amplitude.
lowerEnv = xmean - upperEnv;
upperEnv = upperEnv + xmean;

%--------------------------------------------------------------------------

function [upperEnv,lowerEnv] = envPeak(x,n)
upperEnv = envPeakUpLo(x,n,'upper');
lowerEnv = envPeakUpLo(x,n,'lower');

%--------------------------------------------------------------------------

function env = envPeakUpLo(x,n,uplo)
coder.internal.prefer_const(n,uplo);
nx = coder.internal.indexInt(length(x));
env = coder.nullcopy(zeros(size(x),'like',x));
if nx < 2
    env(:) = x;
    return
end
if nx > n + 1
    if coder.const(strcmp(uplo,'lower'))
        dx = double(-x);
    else
        dx = double(x);
    end
    % find local maxima separated by at least N samples
    [~,iPk] = findpeaks(dx,'MinPeakDistance',double(n));
    npeaks = coder.internal.indexInt(length(iPk));
    % smoothly connect the minima via a spline.
    if npeaks == 0
        X = [1;double(nx)];
        V = [x(1);x(nx)];
    elseif npeaks == 1
        % include the first and last points
        X = [1;iPk(1);double(nx)];
        V = [x(1);x(iPk(1));x(nx)];
    else
        X = iPk;
        V = x(iPk);
    end
else
    X = [1;double(nx)];
    V = [x(1);x(nx)];
end
Xq = double((1:nx).');
env(:) = interp1(X,V,Xq,'spline');

%--------------------------------------------------------------------------

function [upperEnv,lowerEnv] = envRMS(x,n)
xmean = mean(x,1);
x = x - xmean;
upperEnv = movrmsSame(x,n); % upperEnv temporarily stores the amplitude.
lowerEnv = xmean - upperEnv;
upperEnv = upperEnv + xmean;

%--------------------------------------------------------------------------

function y = movrmsSame(x,n)
% Simple implementation of movrms(x,n,'same') for a vector x.
ONE = coder.internal.indexInt(1);
nx = coder.internal.indexInt(length(x));
% nx = coder.internal.prodsize(x,'above',1);
nd2 = eml_rshift(n,ONE);
if eml_bitand(n,ONE) == 0
    n1 = nd2 - 1;
    n2 = nd2;
else
    n1 = nd2;
    n2 = nd2;
end
y = coder.nullcopy(zeros(size(x),'like',x));
for i = 1:nx
    k1 = max(i - n1,1);
    k2 = min(i + n2,nx);
    s = zeros('like',x);
    for k = k1:k2
        s = s + x(k)*x(k);
    end
    y(i) = sqrt(s/double(k2 - k1 + 1));
end

%--------------------------------------------------------------------------

function method = parseMethod(methodstr)
if nargin == 0
    method = ANALYTIC;
    return
end
method = validatestring(methodstr, ...
    {'analytic','rms','peaks'},mfilename,'method');
if strcmp(method,'peaks')
    method = PEAK;
elseif strcmp(method,'rms')
    method = RMS;
else
    method = ANALYTIC;
end

function y = ANALYTIC
coder.inline('always');
y = int8(1);

function y = RMS
coder.inline('always');
y = int8(2);

function y = PEAK
coder.inline('always');
y = int8(3);

%--------------------------------------------------------------------------
