function Y = goertzel(X,INDVEC,DIM)
%GOERTZEL Second-order Goertzel algorithm.  
%   GOERTZEL(X,INDVEC) computes the discrete Fourier transform (DFT)
%   of X at indices contained in the vector INDVEC, using the
%   second-order Goertzel algorithm.  The indices can be integer or fractional values
%   from 1 to N where N is the length of the first non-singleton dimension.
%   If empty or omitted, INDVEC is assumed to be 1:N.
%
%   GOERTZEL(X,[],DIM) or GOERTZEL(X,INDVEC,DIM) computes the DFT along 
%   the dimension DIM.
%
%   In general, GOERTZEL is slower than FFT when computing all the possible
%   DFT indices, but is most useful when X is a long vector and the DFT 
%   computation is required for only a subset of indices less than
%   log2(length(X)).  Indices 1:length(X) correspond to the frequency span
%   [0, 2*pi) radians.
%
%   EXAMPLE:
%      % Resolve the 1.24 kHz and 1.26 kHz components in the following
%      % noisy cosine which also has a 10 kHz component.
%      Fs = 32e3;   t = 0:1/Fs:2.96;
%      x  = cos(2*pi*t*10e3)+cos(2*pi*t*1.24e3)+cos(2*pi*t*1.26e3)...
%           + randn(size(t));
%
%      N = (length(x)+1)/2;
%      f = (Fs/2)/N*(0:N-1);              % Generate frequency vector
%      indxs = find(f>1.2e3 & f<1.3e3);   % Find frequencies of interest
%      X = goertzel(x,indxs);
%      
%      plot(f(indxs)/1e3,20*log10(abs(X)/length(X)));
%      title('Mean Squared Spectrum');
%      xlabel('Frequency (kHz)');
%      ylabel('Power (dB)');
%      grid on;
%      set(gca,'XLim',[f(indxs(1)) f(indxs(end))]/1e3);
%
%   See also FFT, FFT2.

%   Copyright 1988-2018 The MathWorks, Inc.

%   Reference:
%     C.S.Burrus and T.W.Parks, DFT/FFT and Convolution Algorithms, 
%     John Wiley & Sons, 1985

%#codegen

narginchk(1,3);

if nargin < 2
    INDVEC = []; 
end

if nargin < 3
    DIM = coder.internal.constNonSingletonDim(X);
    coder.internal.assert(coder.internal.isConst(size(X,DIM)) || ...
        (isscalar(X) && DIM == 2) || ...
        size(X,DIM) ~= 1, ...
        'Coder:toolbox:autoDimIncompatibility');
else
    coder.internal.prefer_const(DIM);
    coder.internal.assert(coder.internal.isConst(DIM),'Coder:toolbox:dimNotConst');
    coder.internal.assertValidDim(DIM); 
end

    
% Check the input Data Type
if(isa(X,'single'))
    isInputSingle = true;
else
    isInputSingle = false;
end

isInputComplex = ~isreal(X);

coder.internal.errorIf(DIM > coder.internal.ndims(X),'signal:goertzel:InvalidDimensions');

validateattributes(X,{'single','double'},{'finite'},'goertzel','X');
validateattributes(INDVEC,{'numeric'},{'real','finite'},'goertzel','INDVEC');
validateattributes(DIM,{'numeric'},{'real','finite','integer'},'goertzel','DIM');
INDVEC = cast(INDVEC,'like',real(X));

isInMATLAB = coder.target('MATLAB');

if DIM == 1 && ~(coder.internal.isConst(isrow(X)) && isrow(X)) && ~ismatrix(X)
    %convert to a 2d matrix
    sz = size(X);
    Y1 = goertzel(reshape(X,sz(1),prod(sz(2:end))),INDVEC,1);
    if(~isempty(INDVEC))
        len = length(INDVEC);
        sz(DIM) = len;
    end
    Y = reshape(Y1,sz);
    
    return
end

if DIM > 1
    ONE = coder.internal.indexInt(1);
    if coder.internal.isConst(isrow(X)) && isrow(X)
        Y1 = goertzel(reshape(X,coder.internal.indexInt(size(X,2)),ONE),INDVEC,1);
        if isempty(INDVEC)
            Y = reshape(Y1,coder.internal.indexInt(size(X,1)),coder.internal.indexInt(size(X,2)));
        else
            Y = reshape(Y1,coder.internal.indexInt(size(INDVEC,1)),coder.internal.indexInt(size(INDVEC,2)));
        end
    else
        if (isInMATLAB)
            p = [DIM,1:DIM-1,DIM+1:ndims(X)];
        else
            p = coder.internal.dimToForePermutation(eml_max(DIM,coder.internal.ndims(X)),DIM);
        end
        X1 = permute(X,p);
        sz = size(X1);
        X2 = reshape(X1,sz(1),prod(sz(2:end)));
        % Recurse with the permuted input and dim == 1.
        Y1 = goertzel(X2,INDVEC,1);
        
        if(~isempty(INDVEC))
            len = length(INDVEC);
            sz(1) = len;
        end
        
        % Apply the inverse permutation to y1 to obtain y.
        Y3 = reshape(Y1,sz);
        Y = ipermute(Y3,p);
    end
    
    return
    
end

% Verify that the indices in INDVEC are valid.
siz = size(X);
if isempty(INDVEC)
    if isInputSingle
        INDVEC = single(1:siz(1))'; % siz(1) is the number of rows of X
    else
        INDVEC = 1:siz(1)';
    end
else
    INDVEC = INDVEC(:);
    if max(INDVEC) > siz(1)
        coder.internal.error('signal:goertzel:IdxGtBound');
    elseif min(INDVEC) < 1
        coder.internal.error('signal:goertzel:IdxLtBound');
    end
end


freqIndices = INDVEC-1;

Y = signal.internal.goertzel.callGoertzel(X,freqIndices,isInputComplex,isInputSingle,isInMATLAB);

end

% LocalWords:  allownumeric siz INDVEC
