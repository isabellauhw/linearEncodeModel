function dist = euclidean2D(x,ix,y,iy,tol,nDim,~,~,~,~)
%#codegen

% Copyright 2019 The MathWorks, Inc.
sqsum = 0;
for i=1:nDim
    if isa(x,'double') || isa(y,'double')
        diff = double(x(i,ix))-double(y(i,iy));
    else
        diff = cast(x(i,ix) - y(i,iy),'double');
    end
    sqsum = sqsum + diff*diff;
end
dist = sqrt(sqsum) > tol;