function [istart,istop,dist] = finddistminima(data,sig,metric)
%#codegen

% Copyright 2019 The MathWorks, Inc.

nx = size(data,2);
ny = size(sig,2);
nDim = size(data,1);

if isa(data,'single')  || isa(sig,'single')
    TZ = 'single';
else
    TZ = 'double';
end

% nothing to do if empty matrices or data length (nx) is less than signal
% length (ny)
if ny == 0 || nx == 0 || nx < ny || nDim == 0
    istart = zeros(1,0);
    istop = zeros(1,0);
    dist = cast(zeros(1,0),TZ);
    return;
end

if ~any(strcmp(metric,{'squared','symmkl'}))
    % use direct implementation and find local minima
    if nDim == 1
        if strcmp(metric,'euclidean')
            [istart,istop,dist] = finddist(data,nx,sig,ny,nDim,TZ,@signal.internal.codegenable.dtwdist.euclidean1D);
        else
            [istart,istop,dist] = finddist(data,nx,sig,ny,nDim,TZ,@signal.internal.codegenable.dtwdist.absolute1D);
        end
    else
        if strcmp(metric,'euclidean')
            [istart,istop,dist] = finddist(data,nx,sig,ny,nDim,TZ,@signal.internal.codegenable.dtwdist.euclidean2D);
        else
            [istart,istop,dist] = finddist(data,nx,sig,ny,nDim,TZ,@signal.internal.codegenable.dtwdist.absolute2D);
        end
    end
    
else
    % use correlation-based implementations
    if strcmp(metric,'symmkl')
        sdist = distsymmkl(data,sig);
    else % 'squared' (default)
        sdist = distsquared(data,sig);
    end
    
    % find all local minima (including endpoints)
    if ~isempty(sdist)
        [dist,iloc] = findpeaks(-[Inf sdist Inf]);
        istart = iloc - 1;
        istop = istart + size(sig,2) - 1;
        dist = -dist;
    else
        dist = sdist;
        istart = [];
        istop = [];
    end
end
end % function end
%--------------------------------------------------------------------------
function sdist = distsquared(data,signal)
ndata = size(data,2);
nsignal = size(signal,2);

% compute total data power E(x*x')
datapwr = movsum(sum(data.*data,1),nsignal,2,'Endpoints','discard');

% compute total signal power E(y*y')
signalpwr = sum(signal(:).*signal(:));

% compute cross power via corr: E(x*y')
if isa(data,'single')  || isa(signal,'single')
    crosspwr = zeros(1,ndata-nsignal+1,'single');
else
    crosspwr = zeros(1,ndata-nsignal+1);
end
for i=1:size(data,1)
    crosspwr = crosspwr + conv(data(i,:),signal(i,end:-1:1),'valid');
end

% E((x-y)*(x-y)') == E(x*x' + y*y' - x*y' - x'*y)
%  complex case can be supported via x*x' + y*y' - 2*real(x*y').
%  if rotational invariance is desired use abs() instead of real().
sdist = abs(signalpwr + datapwr - 2*crosspwr);
end % function end
%--------------------------------------------------------------------------
function sdist = distsymmkl(data,signal)
% E(x*log(x/y) + y*log(y/x)) == E((x-y)*(log(x)-log(y))
% Some definitions use arithmetic or geometric mean or another base for
% the logarithmic terms

ndata = size(data,2);
nsignal = size(signal,2);

logdata = log(max(data,realmin));
logsignal = log(max(signal,realmin));

% compute data terms: E(x*log(x))
dataterms = movsum(sum(data.*logdata,1),nsignal,2,'Endpoints','discard');

% compute signal terms: E(y*log(y))
signalterms = sum(signal(:).*logsignal(:));

% compute cross terms: E(x*log(y) + log(x)*y)
if isa(data,'single')  || isa(signal,'single')
    crossterms = zeros(1,ndata-nsignal+1,'single');
else
    crossterms = zeros(1,ndata-nsignal+1);
end
for i=1:size(data,1)
    crossterms = crossterms + ....
        conv(data(i,:),logsignal(i,end:-1:1),'valid') ...
        + conv(logdata(i,:),signal(i,end:-1:1),'valid');
end

% E((x-y)*(log(x)-log(y)) == E(x*log(x) + y*log(y) - x*log(y) - y*log(x))
sdist = abs(signalterms + dataterms - crossterms);
end % function end
%--------------------------------------------------------------------------
function [istartOut,istopOut,distOut] = finddist(x,nx,y,ny,nDim,TZ,distfunc)


istart = zeros(1,nx);
istop = zeros(1,nx);
z = zeros(1,nx,TZ);

nz = 1;

lastdist = cast(NaN,TZ);
descending  = false;

% start search at first position
for ix=1:nx-ny+1
    
    % compute distance for offset ix
    
    dist = cast(0,TZ);
    for iy=1:ny
        dist = dist + cast(distfunc(x,ix+iy-1,y,iy,nDim),TZ);
    end
    
    if (~descending && dist < lastdist) || ...
            (lastdist ~= lastdist && dist == dist)
        % insert point when a new descent is detected
        istart(nz) = ix;
        istop(nz) = ix + ny -1;
        z(nz) = dist;
        nz = nz + 1;
        descending = true;
    elseif descending && dist < lastdist
        % clobber point when descent is extended
        istart(nz-1) = ix;
        istop(nz-1) = ix + ny -1;
        z(nz-1) = dist;
        descending = true;
    elseif lastdist < dist || dist ~= dist
        descending = false;
    end
    lastdist = dist;
end
istartOut = istart(1:nz-1);
istopOut = istop(1:nz-1);
distOut = z(1:nz-1);
end % function end
