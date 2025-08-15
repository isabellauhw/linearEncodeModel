function [xx,yy,lxx,lyy] = preSymmkl2D(x,y,nDim,nx,ny)
%#codegen

% Copyright 2019 The MathWorks, Inc.
if isa(x,'double') || isa(y,'double')
    mClass = 'double';
else
    mClass = 'single';
end

realminX = realmin(class(x));
realminY = realmin(class(y));
xx = coder.nullcopy(zeros(nDim,nx,mClass));
lxx = coder.nullcopy(zeros(nDim,nx,mClass));
yy = coder.nullcopy(zeros(nDim,ny,mClass));
lyy = coder.nullcopy(zeros(nDim,ny,mClass));
for i=1:nDim
    for j=1:nx
        sampx = x(i,j);
        if sampx < realminX
            sampx = realminX;
        end
        xx(i,j) = cast(sampx,mClass);
        lxx(i,j) = log(cast(sampx,mClass));
    end
    for j=1:ny
        sampy = y(i,j);
        if sampy < realminY
            sampy = realminY;
        end
        yy(i,j) = cast(sampy,mClass);
        lyy(i,j) = log(cast(sampy,mClass));
    end
end