function y = fftfilt(b,x,varargin)
%FFTFILT Overlap-add method for FIR filtering using FFT.
%   Y = FFTFILT(B,X) filters X, with the FIR filter specified by the vector
%   of coefficients B, using the overlap/add method, and internal
%   parameters (FFT size and block length) that guarantee efficient
%   execution.
%
%   Y = FFTFILT(B,X,N) allows you to have some control over the internal
%   parameters, by using an FFT of at least N points.
%
%   Y = FFTFILT(D,X,...) filters X with the FIR digital filter D. You
%   design a digital filter, D, by calling the <a href="matlab:help designfilt">designfilt</a> function.
%
%   If X is a matrix, FFTFILT filters its columns.  If B is a matrix,
%   FFTFILT applies the filter in each column of B to the signal vector X.
%   If B and X are both matrices with the same number of columns, then the
%   i-th column of B is used to filter the i-th column of X.
%
%   It is advantageous to use FFTFILT instead of FILTER when the signal is
%   relatively large.  FILTER performs N multiplications for each sample in
%   X where N is the filter length.  FFTFILT performs 2 FFT operations at
%   the cost of L*log2(L)/2 where L is the block length.  It then performs
%   L pointwise multiplications for a total cost of L*(1+log2(L))
%   multiplications.  The cost ratio is therefore L*(1+log2(L))/(N*L) =>
%   (1+log2(L))/N which is approximately log2(L)/N.  Therefore FFTFILT
%   becomes advantageous when log2(L) is less than N.
%
%   % Example 1:
%   %   Construct a Signal and filter it with a 10 point averaging filter
%   %   using fftfilt.
%
%   fs = 100;                               % Sampling frequency
%   t = 0:1/fs:1;                           % Time vector
%   x = sin(2*pi*t*3)+.25*sin(2*pi*t*40);   % Input Signal
%   b = ones(1,10)/10;  % 10 point averaging filter
%   y = fftfilt(b,x);   % FIR filtering using overlap-add method
%   plot(t,x,t,y,'--');
%   legend('Original Signal','Filtered Signal')
%
%   % Example 2:
%   %   Use the designfilt function to design a lowpass FIR digital filter
%   %   with order 350 and cutoff frequency of 150 Hz. The sample rate is
%   %   1.5 KHz. Filter a long vector of data using the overlap-add method
%   %   to increase speed.
%
%   D = designfilt('lowpassfir', 'FilterOrder', 350, ...
%    'CutoffFrequency', 150, 'SampleRate', 1500);
%
%   data = randn(10e6,1);
%   y = fftfilt(D,data);
%
%   See also FILTER, FILTFILT.

%   --- Algorithmic details ---
%   The overlap/add algorithm convolves B with blocks of X, and adds
%   the overlapping output blocks.  It uses the FFT to compute the
%   convolution.
%
%   Particularly for long FIR filters and long signals, this algorithm is
%   MUCH faster than the equivalent numeric function FILTER(B,1,X).
%
%   Y = FFTFILT(B,X) -- If you leave N unspecified:   (RECOMMENDED)
%       Usually, length(X) > length(B).  Here, FFTFILT chooses an FFT
%       length (N) and block length (L) which minimize the number of
%       flops required for a length-N FFT times the number of blocks
%       ceil(length(X)/L).
%       If length(X) <= length(B), FFTFILT uses a single FFT of length
%       nfft = 2^nextpow2(length(B)+length(X)-1), essentially computing
%       ifft(fft(B,nfft).*fft(X,nfft)).
%
%   Y = FFTFILT(B,X,N) -- If you specify N:
%       In this case, N must be at least length(B); if it isn't, FFTFILT
%       sets N to length(B).  Then, FFTFILT uses an FFT of length
%       nfft = 2^nextpow2(N), and block length L = nfft - length(B) + 1.
%       CAUTION: this can be VERY inefficient, if L ends up being small.

%   Author(s): L. Shure, 7-27-88
%              L. Shure, 4-25-90, revised
%              T. Krauss, 1-14-94, revised
%   Copyright 1988-2019 The MathWorks, Inc.

%   Reference:
%      A.V. Oppenheim and R.W. Schafer, Digital Signal
%      Processing, Prentice-Hall, 1975.
%#codegen
narginchk(2,3);

validateattributes(b,{'double'},{'2d'},'fftfilt','B',1);
validateattributes(x,{'double'},{'2d'},'fftfilt','X',2);
    
if coder.target('MATLAB')
    y = fftfiltImpl(b,x,varargin{:});
else
    allConst = coder.internal.isConst(b) && coder.internal.isConst(x);
    if nargin == 3
        allConst = allConst && coder.internal.isConst(varargin{1});
    end

    %%
    %use different implementation for GPU Code generation
    if ~allConst && coder.gpu.internal.isGpuEnabled
        y = fftfiltImpl_gpu(b,x, varargin{:});
    else % CPU code generation
        if allConst && coder.internal.isCompiled
            y = coder.const(@feval,'fftfilt',b,x,varargin{:});
        else
            y = fftfiltImpl(b,x,varargin{:});
        end
    end
end
end



function y = fftfiltImpl(b,x,varargin)

if isrow(x)
    nx = numel(x);
    xCol = reshape(x,nx,1);  %turn row vector input into a column vector
else
    xCol = x;
    nx = size(x,1);
end
if min(size(b)) > 1 
    coder.internal.errorIf((size(b,2) ~= size(xCol,2)) && size(xCol,2) > 1,...
        'signal:fftfilt:InvalidDimensions');
    bCol = b;
    nb = size(b,1);
else
    nb = numel(b);
    bCol = reshape(b,nb,1);   %turn row vector input into a column vector
end
if nargin < 3
    % figure out which nfft and L to use
    if nb >= nx || nb > 2^20              % take a single FFT in this case
        nfft = 2^nextpow2(nb + nx -1);
        L = nx;
    else
        fftflops = [ 18 59 138 303 660 1441 3150 6875 14952 32373 69762 ...
            149647 319644 680105 1441974 3047619 6422736 13500637 28311786 ...
            59244791 59244791*2.09];
        n = 2.^(1:21);
        nValid = n(n > nb-1);
        fftflopsValid = fftflops(n > nb-1);
        % minimize (number of blocks) * (number of flops per fft)
        L1 = nValid - (nb - 1);
        [~,ind] = min(ceil(nx./L1).*fftflopsValid);
        nfft = nValid(ind);               % must have nfft > (nb-1)
        L = L1(ind);
    end
else % nfft is given
    nfft = varargin{1};
    validateattributes(nfft,{'numeric'},{'real','scalar','nonempty','finite','integer'},...
        'fftfilt','N',3);
    nfft = double(nfft(1));               % Cast to enforce precision rules
    if nfft < nb
        nfft = nb;
    end
    nfft = 2.^(ceil(log(nfft)/log(2)));   % force this to a power of 2 for speed
    L = nfft - nb + 1;
end
B = fft(bCol,nfft,1);
if iscolumn(bCol)
    B1 = B(:,ones(1,size(xCol,2)));       % replicate the column B
else
    B1 = B;
end
if iscolumn(xCol)
    xCol1 = xCol(:,ones(1,size(bCol,2))); % replicate the column x
else
    xCol1 = xCol;
end
y1 = zeros(size(xCol1),'like',1+1i);
istart = 1;
while istart <= nx
    iend = min(istart+L-1,nx);
    if (iend - istart) == 0
        X = xCol1(istart(ones(nfft,1)),:);  % need to fft a scalar
    else
        X = fft(xCol1(istart:iend,:),nfft,1);
    end
    Y = ifft(X.*B1,[],1);
    yend = min(nx,istart+nfft-1);
    y1(istart:yend,:) = y1(istart:yend,:) + Y(1:(yend-istart+1),:);
    istart = istart + L;
end

if ~(any(imag(b),'all') || any(imag(x),'all'))
    y1 = real(y1);
end

if isrow(x) && iscolumn(y1)
    y = reshape(y1,1,numel(y1));           % turn column back into a row
else
    y = y1;
end
end





function y = fftfiltImpl_gpu(b,x,varargin)

if size(b,1)==0 || size(b,2)==0 || size(x,1)== 0 || size(x,2) == 0
    y = zeros(size(x));

else
if isrow(x)
    nx = numel(x);
    xCol = reshape(x,nx,1);  %turn row vector input into a column vector
else
    xCol = x;
    nx = size(x,1);
end
%if min(size(b)) > 1
if ~(isvector(b) || isempty(b))
    coder.internal.errorIf((size(b,2) ~= size(xCol,2)) && size(xCol,2) > 1,...
                           'signal:fftfilt:InvalidDimensions');
    bCol = b;
    nb = size(b,1);
else
    nb = numel(b);
    bCol = reshape(b,nb,1);   %turn row vector input into a column vector
end

if nargin < 3
    nfft = 2^nextpow2(nx + nb - 1);
else
    nfft = varargin{1};
    validateattributes(nfft,{'numeric'},{'real','scalar','nonempty','finite','integer'},...
        'fftfilt','N',3);
    nfft = double(nfft(1));   
    if nfft < nx + nb - 1
        nfft = nx + nb - 1;
    end
    
end
B = cwfft(bCol,nfft);
X = cwfft(xCol,nfft);

ncol = max(size(B,2),size(X,2));

y2 = coder.nullcopy(zeros(nfft,ncol,'like',1+1i));

if iscolumn(B) && ~iscolumn(X) %&& sizenotzero
    
    for ridx = 1:size(X,2)
        for cidx = 1:nfft
            y2(cidx,ridx) = B(cidx)*X(cidx,ridx);
        end
    end
    
elseif iscolumn(X) && ~iscolumn(B) %&& sizenotzero
    
    for ridx = 1:size(B,2)
        for cidx = 1:nfft
            y2(cidx,ridx) = X(cidx)*B(cidx,ridx);
        end
    end
    
else
    
    y2 = B.*X;
    
end
    

y1 = coder.nullcopy(zeros(size(y2),'like',1+1i));
plan = gpucoder.internal.cufft.createcuFFTPlan(1, size(y2, 1), size(y2,1), 1, size(y2,1),...
    size(y2,1), 1, size(y2,1), 'CUFFT_Z2Z', size(y2, 2));
y1 = gpucoder.internal.cufft.executecuFFT(y2, y1, plan, 'i');

y1 = y1(1:nx,:) / nfft;

if isreal(b) && isreal(x)
    y1 = real(y1);
end

if isrow(x) && iscolumn(y1)
    y = reshape(y1,1,numel(y1));           % turn column back into a row
else
    y = y1;
end

end
end

function x = cwfft(y,nfft)

y2 = zeros(nfft,size(y,2),'like',1+1i);
y2(1:size(y,1),:) = y;

x = coder.nullcopy(zeros(size(y2),'like',1+1i));
if ~isreal(y2)
    plan = gpucoder.internal.cufft.createcuFFTPlan(1, size(y2, 1), size(y2,1), 1, size(y2,1), size(y2,1), 1, size(y2,1), 'CUFFT_Z2Z', size(y2, 2));
    x = gpucoder.internal.cufft.executecuFFT(y2, x, plan, 'f');
else
    plan = gpucoder.internal.cufft.createcuFFTPlan(1, size(y2, 1), size(y2,1), 1, size(y2,1), size(y2,1), 1, size(y2,1), 'CUFFT_D2Z', size(y2, 2));
    x = gpucoder.internal.cufft.executecuFFT(y2, x, plan, 'f');
end
end

% LocalWords:  designfilt th pointwise fs lowpassfir nfft nextpow Shure Krauss
% LocalWords:  Oppenheim Schafer
