function z = dtwImpl(x,y,varargin) 
%MATLAB Code Generation Private Function

%   Copyright 2019-2020 The MathWorks, Inc.
%#codegen
if ischar(varargin{1})
    r = Inf;
    metric = varargin{1};
else
    r = varargin{1};
    metric = varargin{2};
end

nx = size(x,2);
ny = size(y,2);
nDim = size(x,1);

if (~isfinite(r))
    switch metric
        case "euclidean"
            if (nDim==1)
                z=cumdist(x, nx, y, ny, nDim, @caldistEuclidean1D,false);
            else
                z=cumdist(x, nx, y, ny, nDim, @caldistEuclidean,false);
            end
            
        case "squared"
            if (nDim==1)
                z=cumdist(x, nx, y, ny, nDim, @caldistSquared1D,false);
            else
                z=cumdist(x, nx, y, ny, nDim, @caldistSquared,false);
            end
            
        case "absolute"
            if (nDim==1)
                z=cumdist(x, nx, y, ny, nDim, @caldistAbsolute1D,false);
            else
                z=cumdist(x, nx, y, ny, nDim, @caldistAbsolute,false);
            end
            
        case "symmkl"
            if (nDim==1)
                z=cumdist(x, nx, y, ny, nDim, @caldistSymmkl1D,false);
            else
                z=cumdist(x, nx, y, ny, nDim, @caldistSymmkl,true);
            end
            
        otherwise
            coder.internal.error('signal:dtw:BadDistance');
    end
    
elseif (nx<ny)
    coder.internal.error('signal:dtw:BadSizeOrder');
    
else
    switch metric
        case "euclidean"
            if (nDim==1)
                z=cumdistr(x, nx, y, ny, nDim, @caldistEuclidean1D, r,false);
            else
                z=cumdistr(x, nx, y, ny, nDim, @caldistEuclidean, r,false);
            end
            
        case "squared"
            if (nDim==1)
                z=cumdistr(x, nx, y, ny, nDim, @caldistSquared1D, r,false);
            else
                z=cumdistr(x, nx, y, ny, nDim, @caldistSquared, r,false);
            end
            
        case "absolute"
            if (nDim==1)
                z=cumdistr(x, nx, y, ny, nDim, @caldistAbsolute1D, r,false);
            else
                z=cumdistr(x, nx, y, ny, nDim, @caldistAbsolute, r,false);
            end
            
        case "symmkl"
            if (nDim==1)
                z=cumdistr(x, nx, y, ny, nDim, @caldistSymmkl1D,r,false);
            else
                z=cumdistr(x, nx, y, ny, nDim, @caldistSymmkl,r,true);
            end
            
        otherwise
            coder.internal.error('signal:dtw:BadDistance');
    end
end
end


%% Function for default r
function z = cumdist(x,nx,y,ny,nDim,fcn,flag)
outputClass = 'double';
if isa(x,'single') || isa(y,'single')
    outputClass = 'single';
end

% nothing to do if empty matrix
if (nx==0 || ny==0 || nDim==0)
    z = (zeros(0,0,outputClass));
    return;
end
z = coder.nullcopy(zeros(nx,ny,outputClass));

% pre-computation for Symmkl
if flag
    [xx,yy] = preSymmkl(x,y,nDim);
else
    xx=zeros(0,0);
    yy=zeros(0,0);
end

% integrate initial slice
sumz = cast(0,outputClass);
for ix=1:nx
    sumz = sumz+fcn(x,ix,y,1,nDim,xx,yy);
    z(ix) = sumz;
end

% compute distances from previous min slice.
iz = nx+1;
for iy=2:ny
    pmin = z(iz-nx);
    pdist = pmin;
    for ix=1:nx
        nmin = z(iz-nx);
        lmin = pmin;
        if nmin < pmin
            lmin = nmin;
        end
        if pdist < lmin
            lmin = pdist;
        end
        pdist = lmin + fcn(x,ix,y,iy,nDim,xx,yy);
        z(iz) = pdist;
        iz = iz + 1;
        pmin = nmin;
    end
end

end


%% Functions for finite r

function z = cumdistr(x,nx,y,ny,nDim,fcn,r,flag)
outputClass = 'double';
if isa(x,'single') || isa(y,'single')
    outputClass = 'single';
end

% nothing to do if empty matrix
if (~nx)
    z = (zeros(0,0,outputClass));
    return;
end

iy = 1;
s = (nx - 1)/(ny - 1);
[nextLower,nextUpper] = getBounds(s, nx, iy, r);
z = coder.nullcopy(zeros(nx,ny,outputClass));
sumz = cast(0,outputClass);

% pre-computation for Symmkl
if flag
    [xx,yy] = preSymmkl(x,y,nDim);
else
    xx=zeros(0,0);
    yy=zeros(0,0);
end

% integrate initial slice
for ix=nextLower:nextUpper
    sumz = sumz+fcn(x,ix,y,1,nDim,xx,yy);
    z(ix,1) = sumz;
end

% pad with NaN
tempNan = NaN('like',z);
z(nextUpper+1:nx,1)=tempNan;

for iy=2:ny
    prevUpper = nextUpper;
    [nextLower,nextUpper] = getBounds(s, nx, iy, r);
    z(1:nextLower-1,iy)=tempNan;
    
    ix = nextLower;
    if ix>1
        pmin = z(ix-1,iy-1);
    else
        pmin = z(ix,iy-1);
    end
    
    pdist = pmin;
    lmin = cast(0,outputClass); %#ok<NASGU>
    for ix=nextLower:prevUpper
        nmin = z(ix,iy-1);
        lmin = pmin;
        if nmin < lmin
            lmin = nmin;
        end
        if pdist < lmin
            lmin = pdist;
        end
        pdist = lmin + fcn(x,ix,y,iy,nDim,xx,yy);
        z(ix,iy) = pdist;
        pmin = nmin;
    end
    
    ix = prevUpper + 1;
    if ix<=nx
        lmin = pdist;
        if pmin < lmin
            lmin = pmin;
        end
        pdist = lmin + fcn(x,ix,y,iy,nDim,xx,yy);
        z(ix,iy) = pdist;
        
        % integrate to end of slice
        sumz = pdist;
        for ix = (prevUpper+2):nextUpper
            sumz = sumz + fcn(x,ix,y,iy,nDim,xx,yy);
            z(ix,iy) = sumz;
        end
        % final padding
        z(nextUpper+1:nx,iy)=tempNan;
    end
end
end


function [nextLower,nextUpper] = getBounds(s,nx,iy,r)
nextLower = ceil((iy-1)*s - r +1);
if nextLower<1
    nextLower = 1;
end
nextUpper = floor((iy-1)*s + r + 1);
if nextUpper>nx
    nextUpper = nx;
end
end



%% Functions for distance calculation

function d = caldistEuclidean1D(x,ix,y,iy,~,~,~)
d = abs(x(ix)-y(iy));
end

function d = caldistEuclidean(x,ix,y,iy,nDim,~,~)
% Euclidean distance with multiple dimensions
outputClass = 'double';
if isa(x,'single') || isa(y,'single')
    outputClass = 'single';
end
d = cast(0,outputClass);
for i = 1:nDim
    d = d + (x(i,ix)-y(i,iy))*(x(i,ix)-y(i,iy));
end
d = sqrt(d);
end

function d = caldistSquared1D(x,ix,y,iy,~,~,~)
d = (x(ix)-y(iy))*(x(ix)-y(iy));
end

function d = caldistSquared(x,ix,y,iy,nDim,~,~)
% Squared distance with multiple dimensions
d = (x(1,ix)-y(1,iy))*(x(1,ix)-y(1,iy));
for i = 2:nDim
    d = d + (x(i,ix)-y(i,iy))*(x(i,ix)-y(i,iy));
end
end

function d = caldistAbsolute1D(x,ix,y,iy,~,~,~)
d = abs(x(ix)-y(iy));
end

function d = caldistAbsolute(x,ix,y,iy,nDim,~,~)
% Absolute distance with multiple dimensions
d = abs(x(1,ix)-y(1,iy));
for i = 2:nDim
    d = d + abs(x(i,ix)-y(i,iy));
end
end


function [xx,yy] = preSymmkl(x,y,nDim)
% Pre-computing required variables for calculation of Symmkl distance metric
nx = size(x,2);
ny = size(y,2);
realminx = realmin(class(x));
xx = coder.nullcopy(zeros(1,2*nx*nDim,class(x)));

for i=1:nx*nDim
    sampx = x(i);
    if sampx < realminx
        sampx = realminx;
    end
    xx(2*i-1) = sampx;
    xx(2*i) = log(sampx);
end

realminy = realmin(class(y));
yy = coder.nullcopy(zeros(1,2*ny*nDim,class(y)));

for i=1:ny*nDim
    sampy = y(i);
    if sampy < realminy
        sampy = realminy;
    end
    yy(2*i-1) = sampy;
    yy(2*i) = log(sampy);
end
end


function d = caldistSymmkl(~,ix,~,iy,nDim,xx,yy)
idx = (ix-1)*nDim+1;
idy = (iy-1)*nDim+1;

d = cast(0,class(xx(1)-yy(1)));
for id=1:nDim
    d = d + (xx(2*(idx+id-1)-1)-yy(2*(idy+id-1)-1))*(xx(2*(idx+id-1))-yy(2*(idy+id-1)));
end
end


function d = caldistSymmkl1D(x,ix,y,iy,~,~,~)
xt = x(ix);
yt = y(iy);
if xt==0
    xt = realmin(class(x));
end
if yt==0
    yt = realmin(class(y));
end
diff = ((xt-yt)*log(xt/yt));

d = diff;
end
