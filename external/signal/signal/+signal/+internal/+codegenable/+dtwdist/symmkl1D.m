function dist = symmkl1D(~,ix,~,iy,~,xx,yy,lxx,lyy)
%#codegen

% Copyright 2019 The MathWorks, Inc.
dist = cast((xx(ix)-yy(iy))*(lxx(ix)-lyy(iy)),'double');
