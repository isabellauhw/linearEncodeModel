function dist = squared1D(x,ix,y,iy,~,~,~,~,~)
%#codegen

% Copyright 2019 The MathWorks, Inc.
if isa(x,'double') || isa(y,'double')
    diff = double(x(ix))-double(y(iy));
else
    diff = cast(x(ix)-y(iy),'double');
end
dist = diff*diff;