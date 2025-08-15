function [istart_out,istop_out,dist_out] = ...
findsignal(data,signal,varargin)
% MATLAB Code Generation Library Function

% Copyright 2019 The MathWorks, Inc.
%#codegen

narginchk(2,18); 
optargs = cell(size(varargin));
if nargin > 2
    [optargs{:}] = convertStringsToChars(varargin{:});
end

needsTranspose = iscolumn(data) && ~isscalar(data);

if  iscolumn(data) && isvector(signal) && ~isscalar(data) 
    DATA = data.';
else
    DATA = data;
end

if iscolumn(signal) && isvector(data) && ~isscalar(signal)
    SIGNAL = signal.';
else
    SIGNAL = signal;
end

validateattributes(DATA,{'single','double'},{'nonnan','2d','finite'},...
    'findsignal','DATA',1);
validateattributes(SIGNAL,{'single','double'},{'nonnan','2d','finite'},...
    'findsignal','SIGNAL',2);

% not considering the 'Annotate' name-value pair
[nstat,nlength,maxseg,maxdist,align,tol,metric,~] = ...
    parseInput(DATA,SIGNAL,optargs{:});

if ~isempty(DATA) && ~isempty(SIGNAL)
    coder.internal.errorIf(size(DATA,1) ~= ...
        size(SIGNAL,1),'signal:findsignal:RowMismatch');
    [ndata, nsignal] = normalize(DATA, SIGNAL, nstat, nlength);
    [istart, istop, dist] = getsegments(ndata,nsignal,align,tol,metric);
else
    if isa(DATA,'single')  || isa(SIGNAL,'single')
        dist = zeros(1,0,'single');
    else
        dist = zeros(1,0);
    end
    istart = zeros(1,0);
    istop = zeros(1,0);
end

% remove segments that do not fit the matching criteria
[istart,istop,dist] = filtersegments(istart,istop,dist,maxseg,maxdist);
coder.internal.errorIf(nargout == 0, 'signal:findsignal:NeedOneOpCodeGen');
if needsTranspose
    % flip orientation to match input vector
    dist_out = dist.';
    istart_out = istart.';
    istop_out = istop.';
else
    dist_out = dist;
    istart_out = istart;
    istop_out = istop;
end

%-------------------------------------------------------------------------
function [istartOut,istopOut,distOut] = ...
    filtersegments(istartIn,istopIn,distIn,maxseg,maxdist)
% keep only the segments whose distances are within MAXDIST
if isfinite(maxdist)
    idx1 = find(distIn <= maxdist);
    dist1 = distIn(idx1);
    istart1 = istartIn(idx1);
    istop1 = istopIn(idx1);
else
    dist1 = distIn;
    istart1 = istartIn;
    istop1 = istopIn;
end

% sort results by output distance metric
[dist2, idx2] = sort(dist1,'ascend');
istart2 = istart1(idx2);
istop2 = istop1(idx2);

% truncate list if MAXSEGS is specified
if numel(dist2) > maxseg
    distOut = dist2(1:maxseg);
    istartOut = istart2(1:maxseg);
    istopOut = istop2(1:maxseg);
else
    distOut = dist2;
    istartOut = istart2;
    istopOut = istop2;
end

%-------------------------------------------------------------------------
function [istart,istop,dist] = getsegments(data,signal,align,tol,metric)

% split real/imag if needed
if ~isreal(data) || ~isreal(signal)
    DATA = [real(data); imag(data)];
    SIGNAL = [real(signal); imag(signal)];
else
    DATA = data;
    SIGNAL = signal;
end

if strcmp(align,'dtw') && isempty(tol)
    % seek segments such that:
    %   dist(k) == dtw(data(:,istart(k):istop(k)),sig,metric)
    %   warping paths may not overlap
    [istart, istop, dist] = dtwfind(DATA,SIGNAL,metric);
elseif strcmp(align,'edr') && ~isempty(tol)
    % seek segments such that:
    %   dist(k) == edr(data(:,istart(k):istop(k)),sig,tol,metric)
    %   warping paths may not overlap
    [istart, istop, dist] = edrfind(DATA,SIGNAL,tol,metric);
else %'fixed'
    % seek segments such that:
    %   dist(k) == dist([data(:,istart(k):istop(k)); sig],metric)
    %   segments must be local minima
    [istart, istop, dist] = finddistminima(DATA,SIGNAL,metric);
end

%-------------------------------------------------------------------------
function [ndata, nsignal] = normalize(data,signal,nstat,nlength)
%#codegen
if strcmp(nstat,'center')
    % remove constant bias
    ndata = bsxfun(@minus,data,movmean(mean(data,1),nlength,2));
    nsignal = bsxfun(@minus,signal,movmean(mean(signal,1),nlength,2));
elseif strcmp(nstat,'power')
    % divide input (power) by average.
    ndata = bsxfun(@rdivide,data,movmean(mean(data,1),nlength,2));
    nsignal = bsxfun(@rdivide,signal,movmean(mean(signal,1),nlength,2));
elseif strcmp(nstat,'zscore')
    % standardize each row to zero mean and unit norm
    ndata = lzscore(data,nlength);
    nsignal = lzscore(signal,nlength);
else % 'none'
    ndata = data;
    nsignal = signal;
end

%-------------------------------------------------------------------------
function ndata = lzscore(data,n)
data = data - movmean(data,n,2);
rowvar = movvar(data,n,1,2);
m = size(data,1);
% use unbiased estimate
allstd = sqrt(n * sum(rowvar,1) / max(1,m*n-1));
ndata = bsxfun(@rdivide,data,allstd);

%-------------------------------------------------------------------------
function [nstat,nlength,maxseg,maxdist,align,tol,metric,annotate] = ...
    parseInput(data,signal,varargin)

parms = struct(...
    'Normalization',uint32(0), ...
    'NormalizationLength',uint32(0), ...
    'MaxNumSegments',uint32(0), ...
    'MaxDistance',uint32(0), ...
    'TimeAlignment',uint32(0), ...
    'EDRTolerance',uint32(0), ...
    'Metric',uint32(0), ...
    'Annotate',uint32(0));

poptions = struct( ...
    'CaseSensitivity',false, ...
    'PartialMatching','unique', ...
    'StructExpand',false, ...
    'IgnoreNulls',true);

pstruct = coder.internal.parseParameterInputs(parms,poptions,varargin{:});

nstat1 = coder.internal.getParameterValue(pstruct.Normalization,'none',...
    varargin{:});
nlength = coder.internal.getParameterValue(pstruct.NormalizationLength,...
    2*max(1,max(size(data,2),size(signal,2))),varargin{:});
maxseg = coder.internal.getParameterValue(pstruct.MaxNumSegments,...
    Inf,varargin{:});
maxdist = coder.internal.getParameterValue(pstruct.MaxDistance,...
    Inf,varargin{:});
align1 = coder.internal.getParameterValue(pstruct.TimeAlignment,...
    'fixed',varargin{:});
tol = coder.internal.getParameterValue(pstruct.EDRTolerance,...
    [],varargin{:});
metric1 = coder.internal.getParameterValue(pstruct.Metric,...
    'squared',varargin{:});
annotate1 = coder.internal.getParameterValue(pstruct.Annotate,...
    'signal',varargin{:});

nstat = validatestring(nstat1,{'center','zscore','power','none'}, ...
    'findsignal','Normalization');
align = validatestring(align1,{'fixed','dtw','edr'}, ...
    'findsignal','MaxDistance');
metric = validatestring(metric1,{'absolute','euclidean',...
    'squared','symmkl'},'findsignal','Metric');
annotate = validatestring(annotate1,{'data','signal','all'},...
    'findsignal','Annotate');
validateattributes(nlength,{'numeric'},...
    {'>',1,'integer','scalar','finite'}, ...
    'findsignal','NormalizationLength');
validateattributes(maxdist,{'numeric'},...
    {'nonnegative','real','scalar','nonnan'}, ...
    'findsignal','MaxDistance');
if ~isscalar(maxseg) || isfinite(maxseg) || isnan(maxseg)
    validateattributes(maxseg,{'numeric'},...
        {'positive','integer','scalar','nonnan'}, ...
        'findsignal','MaxNumSegments');
end

% if neither maxdist or maxseg is specified, just use the best segment
if ~isfinite(maxdist) && ~isfinite(maxseg)
    maxseg = 1;
end

coder.internal.errorIf(strcmp(align,'edr') && isempty(tol),...
    'signal:findsignal:MissingEDRTolerance');
coder.internal.errorIf(~strcmp(align,'edr') && ~isempty(tol),...
    'signal:findsignal:InvalidEDRTolerance');
if strcmp(align,'edr') && ~isempty(tol)
    validateattributes(tol,{'numeric'},...
        {'nonnegative','real','scalar','finite'}, ...
        'findsignal','EDRTolerance');
end

% Ensure signal, data, and normalization are properly conditioned when
% using symmetric Kullback-Leibler distance
coder.internal.errorIf(strcmp(metric,'symmkl') ...
    && ~strcmp(nstat,'none') && ~strcmp(nstat,'power'),...
    'signal:findsignal:NonUnipolarNorm',nstat);
coder.internal.errorIf(strcmp(metric,'symmkl') && ...
    (~isreal(data) || coder.internal.vAllOrAny('any',data,@(x)x<0)),...
    'signal:findsignal:DataCannotBeNegative');
coder.internal.errorIf(strcmp(metric,'symmkl') && ...
    (~isreal(signal) || coder.internal.vAllOrAny('any',signal,@(x)x<0)),...
    'signal:findsignal:SignalCannotBeNegative');