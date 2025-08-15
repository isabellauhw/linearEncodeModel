function y = sgolayfilt(x,order,framelen,weights,dim)
%MATLAB Code Generation Library Function

%   Copyright 1988-2016 The MathWorks, Inc.
%#codegen

narginchk(3,5);
coder.internal.prefer_const(order,framelen);
% Check if the input arguments are valid
coder.internal.assert(floor(framelen) == framelen, ...
    'signal:sgolayfilt:MustBeIntegerFrameLength');
coder.internal.assert(rem(framelen,2) == 1, ...
    'signal:sgolayfilt:SignalErr');
coder.internal.assert(floor(order) == order, ...
    'signal:sgolayfilt:MustBeIntegerPolyDegree');
coder.internal.assert(order < framelen, ...
    'signal:sgolayfilt:InvalidRangeDegree');
% Process DIM input, if any.
if nargin < 5
    dim = coder.internal.nonSingletonDim(x);
else
    coder.internal.prefer_const(dim);
    coder.internal.assert(nargin < 5 || dim <= ndims(x), ...
        'signal:sgolayfilt:InvalidDimensionsInput','X');
end
% Process WEIGHTS input, if any.
if nargin < 4
    weights = [];
elseif ~(coder.internal.isConst(isempty(weights)) && isempty(weights))
    % Check for right length of WEIGHTS
    coder.internal.assert(length(weights) == framelen, ...
        'signal:sgolayfilt:InvalidDimensionsWeight');
    % Check to see if all elements are positive
    coder.internal.assert(min(weights(:)) > 0, ...
        'signal:sgolayfilt:InvalidRangeWeight');
end
% Check the input data type. Single precision is not supported.
chkinputdatatype(x,weights);
coder.internal.assert(size(x,dim) >= framelen, ...
    'signal:sgolayfilt:InvalidDimensionsTooSmall');
% Compute the projection matrix B.
B = sgolay(order,framelen,weights);
% Apply filter
flen = coder.internal.indexInt(framelen);
if coder.internal.isConst(dim) && dim == 1
    % Avoid permutation
    y = SavitzkyGolayFilterColumns(B,x,flen);
else
    % Put DIM in the first dimension (this matches the order
    % that the built-in filter function uses)
    idim = coder.internal.indexInt(dim);
    nd = coder.internal.indexInt(eml_ndims(x));
    % perm = [idim,1:idim-1,idim+1:nd];
    perm = 1:nd;
    perm(1) = idim;
    for k = 2:idim
        perm(k) = k - 1;
    end
    xp = permute(x,perm);
    % Apply filter
    yp = SavitzkyGolayFilterColumns(B,xp,flen);
    % Convert Y to the original shape of X
    y = ipermute(yp,perm);
end

%--------------------------------------------------------------------------

function y = SavitzkyGolayFilterColumns(B,x,framelen)
% Savitzky-Golay filter on the columns of x.
coder.internal.prefer_const(framelen);
% Various integer/index values
nx = coder.internal.indexInt(size(x,1));
mb = coder.internal.indexInt(size(B,1));
mbd2 = (mb - 1)/2;
ssRow = mbd2 + 1;
nchan = coder.internal.prodsize(x,'above',1);
% Since B will be accessed in reverse row order, go ahead and flip it.
B = flipud(B);
% Allocate output.
y = zeros(size(x),'like',x);
% Allocate storage for a temporary to store parts of x.
xtmp = coder.nullcopy(zeros(mb,nchan,'like',x));
% Compute the transient on
% xtmp = x(flen:-1:1,:);
for j = 1:nchan
    for i = 1:framelen
        xtmp(i,j) = x(mb - i + 1,j);
    end
end
% Calculate B(1:mbd2,:)*xtmp and store the result in y(1:mbd2,:).
y(1:mbd2,:) = B(1:mbd2,:)*xtmp;
% Compute the steady state output
ycenter = filter(B(ssRow,:),1,x);
ihi = nx - mbd2;
for j = 1:nchan
    for i = ssRow:ihi
        y(i,j) = ycenter(i + mbd2,j);
    end
end
% Compute the transient off
% xtmp = x(end:-1:end-(mb-1),:);
for j = 1:nchan
    for i = 1:mb
        xtmp(i,j) = x(nx - i + 1,j);
    end
end
% Calculate B(ssRow+(1:mbd2),:)*xtmp and store the result in
% y(nx-mbd2+1:nx,:).
y(nx - mbd2 + (1:mbd2),:) = B(ssRow + (1:mbd2),:)*xtmp;

%--------------------------------------------------------------------------
