function dist = symmkl2D(~,ix,~,iy,nDim,xx,yy,lxx,lyy)
%#codegen

% Copyright 2019 The MathWorks, Inc.
dist = 0;
for i=1:nDim
    dist = dist + cast((xx(i,ix)-yy(i,iy))*(lxx(i,ix)-lyy(i,iy)),'double');
end