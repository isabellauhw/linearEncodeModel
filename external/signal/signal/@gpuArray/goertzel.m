function Y = goertzel(X,INDVEC,DIM)
%GOERTZEL Second-order Goertzel algorithm.
%   GOERTZEL(X,INDVEC)
%   GOERTZEL(X,[],DIM)
%   GOERTZEL(X,INDVEC,DIM) 
%
%   See also FFT, FFT2.

%   Copyright 2020 The MathWorks, Inc.

narginchk(1,3);

if nargin < 2
    INDVEC = [];
end

if nargin < 3
    DIM = coder.internal.constNonSingletonDim(X);
    coder.internal.assert((isscalar(X) && DIM == 2) || ...
        size(X,DIM) ~= 1, ...
        'Coder:toolbox:autoDimIncompatibility');
else
    coder.internal.assertValidDim(DIM);
end

% Dispatch to in-memory if X is not on the GPU
if ~isa(X,"gpuArray")
    Y = goertzel(X,gather(INDVEC),gather(DIM));
    return;
end

% Casting to a consistent type
oneCastProtoType = real(cast(1,"like",X));
INDVEC = cast(INDVEC,"like",oneCastProtoType);
DIM = cast(DIM,"like",oneCastProtoType);

% Validate inputs
validateattributes(X,{'single','double'},{'finite'},'goertzel','X');
validateattributes(INDVEC,{'numeric'},{'real','finite'},'goertzel','INDVEC');
validateattributes(DIM,{'numeric'},{'real','finite','integer'},'goertzel','DIM');
coder.internal.errorIf(DIM > coder.internal.ndims(X),'signal:goertzel:InvalidDimensions');

% Convert to a 2d matrix if goertzel along row but input isn't a row
if DIM == 1 && ~isrow(X) && ~ismatrix(X)
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
    if isrow(X)
        szX = size(X);
        Y1 = goertzel(reshape(X,szX(2),1),INDVEC,1);
        if isempty(INDVEC)
            Y = reshape(Y1,szX(1),szX(2));
        else
            szI = size(INDVEC);
            Y = reshape(Y1,szI(1),szI(2));
        end
    else
        p = [DIM,1:DIM-1,DIM+1:ndims(X)];
        
        X1 = permute(X,p);
        szX1 = size(X1);
        X2 = reshape(X1,szX1(1),prod(szX1(2:end)));
        
        % Recurse with the permuted input and dim == 1.
        Y1 = goertzel(X2,INDVEC,1);
        
        if(~isempty(INDVEC))
            len = length(INDVEC);
            szX1(1) = len;
        end
        
        % Apply the inverse permutation to y1 to obtain y.
        Y3 = reshape(Y1,szX1);
        Y = ipermute(Y3,p);
    end
    
    return
    
end

% Verify that the indices in INDVEC are valid.
szX = size(X);

if isempty(INDVEC)
    INDVEC = (oneCastProtoType:szX(1))';
else
    INDVEC = INDVEC(:);
    if max(INDVEC) > szX(1)
        coder.internal.error('signal:goertzel:IdxGtBound');
    elseif min(INDVEC) < 1
        coder.internal.error('signal:goertzel:IdxLtBound');
    end
end

freqIndices = INDVEC-1;

Y = goertzelImpl(X,freqIndices);

end