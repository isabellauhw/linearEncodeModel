function dist = absolute1D(x,ix,y,iy,~,~,~,~,~)
%#codegen

% Copyright 2019 The MathWorks, Inc.
if isa(x,'double') || isa(y,'double')
    dist = abs(double(x(ix))-double(y(iy)));
else
    dist = cast(abs(x(ix)-y(iy)),'double');
end