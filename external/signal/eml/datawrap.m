function y = datawrap(x,nfft)
%MATLAB Code Generation Library Function

% Copyright 2009-2016 The MathWorks, Inc.
%#codegen

narginchk(2,2);
coder.internal.prefer_const(nfft);
coder.internal.assert(isvector(x),'signal:datawrap:InvalidInput');
IMIN = coder.internal.indexInt(1);
IMAX = intmax(coder.internal.indexIntClass);
coder.internal.assert(isnumeric(nfft) && isscalar(nfft) && ...
    isreal(nfft) && nfft >= 1 && nfft <= IMAX && ...
    floor(nfft) == nfft, ...
    'Coder:MATLAB:NonIntegerInput',IMIN,IMAX);
% Perform the data wrapping.
nx = coder.internal.indexInt(length(x));
ny = coder.internal.indexInt(nfft);
% Output class follows the default SUM rule: single if single, else double.
if isa(x,'single')
    yzero = zeros('like',x);
else
    yzero = zeros('like',double(x));
end
if isrow(x)
    y = zeros(1,ny,'like',yzero);
else
    y = zeros(ny,1,'like',yzero);
end
nFullPasses = coder.internal.indexDivide(nx,ny); % rounds down
% Initialize part of y with the part of x that belongs to the last pass.
remainder = nx - nFullPasses*ny;
offset = nFullPasses*ny;
for k = 1:remainder
    y(k) = x(offset + k);
end
% Initialize the rest of y to zero.
for k = remainder+1:ny
    y(k) = 0;
end
% Add in the full passes, if any.
for j = 1:nFullPasses
    offset = (j - 1)*ny;
    for k = 1:ny
        y(k) = y(k) + x(offset + k);
    end
end
