function [istart,istop,dist] = dtwfind(data,sig,metric)
%#codegen

% Copyright 2019 The MathWorks, Inc.

nx = size(data,2);
ny = size(sig,2);
nDim = size(data,1);

if nDim == 1
    switch metric
        case 'euclidean'
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.euclidean1D,false);
        case 'absolute'
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.absolute1D,false);
        case 'squared'
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.squared1D,false);
        case 'symmkl'
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.symmkl1D,true);
        otherwise
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.squared1D,false);
    end
else
    switch metric
        case 'euclidean'
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.euclidean2D,false);
        case 'absolute'
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.absolute2D,false);
        case 'squared'
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.squared2D,false);
        case 'symmkl'
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.symmkl2D,true);
        otherwise
            [istart,istop,dist] = findstart(data,nx,sig,ny,nDim,...
                @signal.internal.codegenable.dtwdist.squared2D,false);
    end
end

end % function end
%--------------------------------------------------------------------------------------
function [istartOut,istopOut,distOut] = findstart(x,nx,y,ny,nDim,distFunc,sflag)

if isa(x,'single')  || isa(y,'single')
    TZ = 'single';
else
    TZ = 'double';
end

sum = cast(0,TZ);

% nothing to do if empty matrices
if ny == 0 || nx == 0 || nDim == 0
    istartOut = zeros(1,0);
    istopOut = zeros(1,0);
    distOut = cast(zeros(1,0),TZ);
    return;
end

istart = zeros(1,nx);
istop = zeros(1,nx);
z = zeros(1,nx,TZ);
nz = 1;

% rather than compute full distance matrix, toggle between two vectors
bank = zeros(2,ny,TZ);
ibank = zeros(2,ny);

if sflag
    if nDim == 1
        [xx,yy,lxx,lyy] = ...
            signal.internal.codegenable.psym.preSymmkl1D(x,y,nx,ny);
    else
        [xx,yy,lxx,lyy] = ...
            signal.internal.codegenable.psym.preSymmkl2D(x,y,nDim,nx,ny);
    end
else
    xx=zeros(0,0);
    yy=zeros(0,0);
    lxx=zeros(0,0);
    lyy=zeros(0,0);
end

% integrate initial slice
for iy=1:ny
    sum = sum + cast(distFunc(x,1,y,iy,nDim,xx,yy,lxx,lyy),TZ);
    bank(1,iy) = sum;
    ibank(1,iy) = 1;
end

% record starting/stopping indices and distance
istop(nz) = 1;
istart(nz) = 1;
z(nz) = bank(1,ny);
nz = nz + 1;

% compute distances from previous min slice.
for ix=2:nx
    if mod(ix,2) == 0
        readRow = 1;
        writeRow = 2;
    else
        readRow = 2;
        writeRow = 1;
    end
    
    % initialize both previous values to current index of X
    pmin = cast(0,TZ);
    ipmin = ix;
    pdist = cast(0,TZ);
    ipdist = ix;
    
    for iy=1:ny
        nmin = cast(bank(readRow,iy),TZ);
        inmin = ibank(readRow,iy);
        
        if nmin < pmin
            lmin = nmin;
            ilmin = inmin;
        else
            lmin = pmin;
            ilmin = ipmin;
        end
        
        if pdist < lmin
            lmin = pdist;
            ilmin = ipdist;
        end
        
        % add current distance to local minimum
        pdist = lmin + cast(distFunc(x,ix,y,iy,nDim,xx,yy,lxx,lyy),TZ);
        bank(writeRow,iy) = pdist;
        ipdist = ilmin;
        ibank(writeRow,iy) = ipdist;
        
        pmin = nmin;
        ipmin = inmin;
    end
    
    if ipdist ~= istart(nz-1)
        z(nz) = pdist;
        istart(nz) = ipdist;
        istop(nz) = ix;
        nz = nz + 1;
    elseif pdist < z(nz-1)
        z(nz-1) = pdist;
        istart(nz-1) = ipdist;
        istop(nz-1) = ix;
    end    
end
istartOut = istart(1:nz-1);
istopOut = istop(1:nz-1);
distOut = z(1:nz-1);
end
