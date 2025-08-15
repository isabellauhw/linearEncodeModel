function dist = absolute1D(x,ix,y,iy,tol,~,~,~,~,~)
%#codegen

% Copyright 2019 The MathWorks, Inc.
if isa(x,'double') || isa(y,'double')
    dist = abs(double(x(ix))-double(y(iy))) > tol;
else
    dist = cast(abs(x(ix)-y(iy)),'double') > tol;
end