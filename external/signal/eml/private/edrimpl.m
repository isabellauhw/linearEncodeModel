function z = edrimpl(x,y,tol,metric,varargin)
%#codegen

%   Copyright 2019 The MathWorks, Inc.

% Get XY Signal Dimensions
if isvector(x)
    nDim = 1;
    nx = length(x);
    ny = length(y);
else
    nDim = size(x,1);
    nx = size(x,2);
    ny = size(y,2);
end

% Switch to appropriate function
if nDim == 1
    switch metric
        case 'euclidean'
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.euclidean1D,false);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.euclidean1D,false);
            end
        case 'absolute'
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.absolute1D,false);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.absolute1D,false);
            end
        case 'squared'
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.squared1D,false);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.squared1D,false);
            end
        case 'symmkl'
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.symmkl1D,true);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.symmkl1D,true);
            end
        otherwise
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.euclidean1D,false);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.euclidean1D,false);
            end
    end
else
    switch metric
        case 'euclidean'
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.euclidean2D,false);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.euclidean2D,false);
            end
        case 'absolute'
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.absolute2D,false);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.absolute2D,false);
            end
        case 'squared'
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.squared2D,false);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.squared2D,false);
            end
        case 'symmkl'
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.symmkl2D,true);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.symmkl2D,true);
            end
        otherwise
            if nargin == 4
                z = solveUnconstrained(x,y,tol,nDim,nx,ny,@signal.internal.codegenable.edrdist.euclidean2D,false);
            else
                z = solveConstrained(x,y,tol,varargin{1},nDim,nx,ny,@signal.internal.codegenable.edrdist.euclidean2D,false);
            end
    end
end
end % function end
%-------------------------------------------------------------------------
function z = solveUnconstrained(x,y,tol,nDim,nx,ny,distFuncHandle,sflag)

% Initialize distance matrix
if isa(x,'single') || isa(y,'single')
    zDatatype = 'single';
else
    zDatatype = 'double';
end
z = coder.nullcopy(zeros(nx,ny,zDatatype));

if sflag
    if nDim == 1
        [xx,yy,lxx,lyy] = signal.internal.codegenable.psym.preSymmkl1D(x,y,nx,ny);
    else
        [xx,yy,lxx,lyy] = signal.internal.codegenable.psym.preSymmkl2D(x,y,nDim,nx,ny);
    end
else
    xx=zeros(0,0);
    yy=zeros(0,0);
    lxx=zeros(0,0);
    lyy=zeros(0,0);
end
% fill first column of distance matrix
pmin = cast(0,zDatatype);
for ix=1:nx
    lmin = cast(ix-1 + distFuncHandle(x,ix,y,1,tol,nDim,xx,yy,lxx,lyy),zDatatype);
    pmin = pmin + 1;
    if pmin < lmin
        lmin = pmin;
    end
    z(ix) = lmin;
    pmin = lmin;
end

% fill 2:end columns of distance matrix
iz = nx+1;
for iy=2:ny
    pmin = cast(iy-1,zDatatype);
    pdist = cast(iy,zDatatype);
    for ix=1:nx
        nmin = z(iz-nx);
        lmin = pmin + distFuncHandle(x,ix,y,iy,tol,nDim,xx,yy,lxx,lyy);
        if nmin < pdist
            pdist = nmin + 1;
        else
            pdist = pdist + 1;
        end
        if lmin < pdist
            pdist = lmin;
        end
        z(iz) = pdist;
        iz = iz + 1;
        pmin = nmin;
    end
end
end % function end
%-------------------------------------------------------------------------
function z = solveConstrained(x,y,tol,r,nDim,nx,ny,distFuncHandle,sflag)

% Initialize distance matrix
if isa(x,'single') || isa(y,'single')
    zDatatype = 'single';
else
    zDatatype = 'double';
end
z = coder.nullcopy(zeros(nx,ny,zDatatype));

% Sakoe-Chiba bound calculations
iy = 1;
s = (nx-1)/(ny-1);
[nextLower, nextUpper] = getbounds(s,nx,iy,r);

if sflag
    if nDim == 1
        [xx,yy,lxx,lyy] = signal.internal.codegenable.psym.preSymmkl1D(x,y,nx,ny);
    else
        [xx,yy,lxx,lyy] = signal.internal.codegenable.psym.preSymmkl2D(x,y,nDim,nx,ny);
    end
else
    xx=zeros(0,0);
    yy=zeros(0,0);
    lxx=zeros(0,0);
    lyy=zeros(0,0);
end
% fill first column of distance matrix
sTotal = cast(0,zDatatype);
for ix = nextLower:nextUpper
    pmin = cast(ix - 1 + distFuncHandle(x,ix,y,1,tol,nDim,xx,yy,lxx,lyy),zDatatype);
    sTotal = sTotal +1;
    if pmin < sTotal
        sTotal = pmin;
    end
    z(ix) = sTotal;
end
for ix = (nextUpper+1):nx
    z(ix) = cast(NaN,zDatatype);
end

% fill 2:end columns of distance matrix
for iy = 2:ny
    prevUpper = nextUpper;
    [nextLower, nextUpper] = getbounds(s,nx,iy,r);
    for ix=1:nextLower-1
        z(ix,iy) = cast(NaN,zDatatype);
    end
    ix = nextLower;
    if ix > 1
        pmin = z(ix-1,iy-1);
    else
        pmin = cast(iy-1,zDatatype);
    end
    pdist = pmin + 1;
    for ix = nextLower:prevUpper
        nmin = z(ix,iy-1);
        lmin = pmin + distFuncHandle(x,ix,y,iy,tol,nDim,xx,yy,lxx,lyy);
        if nmin < pdist
            pdist = nmin + 1;
        else
            pdist = pdist + 1;
        end
        if lmin < pdist
            pdist = lmin;
        end
        z(ix,iy) = pdist;
        pmin = nmin;
    end
    ix = prevUpper+1;
    if ix <= nx
        lmin = pmin + distFuncHandle(x,ix,y,iy,tol,nDim,xx,yy,lxx,lyy);
        pdist = pdist+1;
        if lmin < pdist
            pdist = lmin;
        end
        z(ix,iy) = pdist;
        sTotal = pdist;
        for ix = (prevUpper+2):nextUpper
            sTotal = sTotal + distFuncHandle(x,ix,y,iy,tol,nDim,xx,yy,lxx,lyy);
            z(ix,iy) = sTotal;
        end
        
        for ix = (nextUpper+1):nx
            z(ix,iy) = cast(NaN,zDatatype);
        end
    end
end
end % function end
%-------------------------------------------------------------------------
function [nextLower, nextUpper]= getbounds(s,nx,iy,r)
nextLower = ceil((iy-1)*s - r + 1);
nextUpper = floor((iy-1)*s + r + 1);
if nextLower < 1
    nextLower = 1;
end
if nextUpper > nx
    nextUpper = nx;
end
end % function end