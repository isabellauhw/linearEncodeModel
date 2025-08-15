function dist = absolute2D(x,ix,y,iy,tol,nDim,~,~,~,~)
%#codegen

% Copyright 2019 The MathWorks, Inc.
absum = 0;
for i=1:nDim
    if isa(x,'double') || isa(y,'double')
        diff = abs(double(x(i,ix))-double(y(i,iy)));
    else
        diff = cast(abs(x(i,ix)-y(i,iy)),'double');
    end
    absum = absum + diff;
end
dist = absum > tol;