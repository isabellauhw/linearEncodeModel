function dist = symmkl2D(~,ix,~,iy,tol,nDim,xx,yy,lxx,lyy)
%#codegen

% Copyright 2019 The MathWorks, Inc.
symsum = 0;
for i=1:nDim
    symsum = symsum + cast((xx(i,ix)-yy(i,iy))*(lxx(i,ix)-lyy(i,iy)),'double');
end
dist = symsum > tol;