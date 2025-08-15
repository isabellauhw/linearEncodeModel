function dist = squared2D(x,ix,y,iy,nDim,~,~,~,~)
%#codegen

% Copyright 2019 The MathWorks, Inc.
dist = 0;
for i=1:nDim
    if isa(x,'double') || isa(y,'double')
        diff = double(x(i,ix))-double(y(i,iy));
    else
        diff = cast(x(i,ix)-y(i,iy),'double');
    end
    dist = dist + diff*diff;
end