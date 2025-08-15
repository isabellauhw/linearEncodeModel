function [xx,yy,lxx,lyy] = preSymmkl1D(x,y,nx,ny)
%#codegen

% Copyright 2019 The MathWorks, Inc.
if isa(x,'double') || isa(y,'double')
    mClass = 'double';
else
    mClass = 'single';
end

realminX = realmin(class(x));
realminY = realmin(class(y));
xx = coder.nullcopy(zeros(1,nx,mClass));
lxx = coder.nullcopy(zeros(1,nx,mClass));
yy = coder.nullcopy(zeros(1,ny,mClass));
lyy = coder.nullcopy(zeros(1,ny,mClass));
for i=1:nx
    sampx = x(i);
    if sampx == 0
        sampx = realminX;
    end
    xx(i) = cast(sampx,mClass);
    lxx(i) = log(cast(sampx,mClass));
end
for i=1:ny
    sampy = y(i);
    if sampy == 0
        sampy = realminY;
    end
    yy(i) = cast(sampy,mClass);
    lyy(i) = log(cast(sampy,mClass));
end