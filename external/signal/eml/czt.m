function g = czt(x, k, w, a) 
%MATLAB Code Generation Library Function

% Copyright 2018 The MathWorks, Inc.
%#codegen

narginchk(1,4);

if nargin < 2
  k = length(x);
end

if nargin < 3
  % M cast to double to enforce precision rules
  Mtmp = signal.internal.sigcasttofloat(k,'double','czt','M','allownumeric');
  w = exp(-1i .* 2 .* pi ./ Mtmp); 
end

if nargin < 4
  a = 1;
end

% Checks if 'X', 'W' and 'A' are valid numeric data inputs
signal.internal.sigcheckfloattype(x,'','czt','X');
signal.internal.sigcheckfloattype(w,'','czt','W');
signal.internal.sigcheckfloattype(a,'','czt','A');

% check x cannot be ND-array
coder.internal.assert(ismatrix(x), 'signal:czt:InvalidSignalDimension');

% Cast to enforce precision rules
k = signal.internal.sigcasttofloat(k,'double','czt','M','allownumeric');

coder.internal.assert(isscalar(k) && isscalar(w) && isscalar(a), 'signal:czt:InvalidDimensions');
coder.internal.assert(isfinite(k), 'signal:czt:InvalidLength');

% check whether the input arguments are constant
allConst = true;

allConst = allConst && coder.internal.isConst(x);
allConst = allConst && coder.internal.isConst(k);
allConst = allConst && coder.internal.isConst(w);
allConst = allConst && coder.internal.isConst(a);

if allConst && coder.internal.isCompiled
    
    % codegeneration for constant input argument
    
    g = coder.const(feval('czt',x,k,w,a));
    return;
else
    
    % codegeneration for variable input
    
        % if x is a row vector, reshape it to a column vector 
        if coder.internal.isConst(isrow(x)) && isrow(x) && ~isscalar(x)
           ONE = coder.internal.indexInt(1);
           g2 = czt(reshape(x,coder.internal.indexInt(size(x,2)),ONE),k,w,a);
           g = reshape(g2,ONE,k);
           return
        end

    [m, n] = size(x);
    g = coder.nullcopy(complex(zeros(k,n,'like',real(x)),1));

    %------- Length for power-of-two fft.

    nfft = 2^nextpow2(m+k-1);

    %------- Premultiply data.

    maxDim = (max(k-1,m-1) - (-m+1))+1;
    kk = coder.nullcopy(zeros(maxDim,1));

    initVal = (-m+1);
    for i= 1:maxDim    
        kk(i) = (initVal^2)/2;
        initVal = initVal + 1;
    end

    ww = w .^ (kk); 

    aa= coder.nullcopy(complex(zeros(1,m,'like',real(x)),1));
    aa(1) = ww(m);

    for nn = 1:m-1
        aa(nn+1) = (a^-nn)* ww(m+nn);
    end

    y = coder.nullcopy(complex(zeros(m,n,'like',real(x)),1));

    for i=1:n
        for j =1:m
            y(j,i) = x(j,i) .* aa(j);
        end
    end

    %------- Fast convolution via FFT.

    fy = fft(  y, nfft );
    fv = fft( 1 ./ ww(1:(k-1+m)), nfft );   % <----- Chirp filter.

    for i=1:n
        for j =1:nfft
            fy(j,i) = fy(j,i) .* fv(j);
        end
    end

    g1  = ifft( fy );

    %------- Final multiply.

    for i=1:n
        idx = coder.internal.indexInt(1);
         for j=m:m+k-1
            g(idx,i) = g1(j,i) .* ww(j);
            idx = idx + 1;
         end
    end
end

end
