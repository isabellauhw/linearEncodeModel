function [istart_out,istop_out,dist_out] = findsignal(data,signal,varargin)
%FINDSIGNAL Find signal location(s) via similarity search
%   [ISTART,ISTOP] = FINDSIGNAL(DATA,SIGNAL) finds the starting and
%   stopping indices of a segment of the data vector, DATA, that best
%   matches the search vector, SIGNAL, by minimizing the squared Euclidean
%   distance between the segment and SIGNAL.
%
%   If DATA and SIGNAL are matrices, then they must contain the same number
%   of rows and ISTART and ISTOP correspond to the starting and stopping
%   columns of the region of DATA that best matches the search signal,
%   SIGNAL.
%
%   [ISTART,ISTOP,DIST] = FINDSIGNAL(DATA,SIGNAL) additionally returns the
%   minimum squared Euclidean distance, DIST, between the data segment and
%   the signal.
%
%   [ISTART,ISTOP,DIST] = FINDSIGNAL(...,'Normalization',NSTAT) will first
%   normalize the data and signal to constant parameter(s) before computing
%   the distance using the normalization statistic, NSTAT.  The default is
%   'none'.
%      'center' subtract mean
%      'zscore' subtract mean and divide by standard deviation
%      'power'  divide by mean
%      'none'   no normalization is performed
%   For matrices, 'center' and 'zscore' subtract the mean of each row
%   independently. The 'power' option is intended for signals with units in
%   power (e.g. Watts); it divides by the mean of all elements in the
%   matrix. 'zscore' divides by the standard deviation of all elements in
%   the matrix.
%
%   [ISTART,ISTOP,DIST] = FINDSIGNAL(...,'NormalizationLength',NLENGTH)
%   specifies the length of a sliding window over which to normalize each
%   sample in both the signal and data.  When the signal and data are
%   matrices, normalization is performed across NLENGTH columns.  If
%   unspecified, the full length of the signal and data are used.
%
%   [ISTART,ISTOP,DIST] = FINDSIGNAL(...,'MaxDistance',MAXDIST) returns the
%   start and stop indices of all segments whose distances from the signal
%   are both local minima and smaller than MAXDIST. The default value of
%   'MaxDistance' is +Inf.
%
%   [ISTART,ISTOP,DIST] = FINDSIGNAL(...,'MaxNumSegments',MAXSEG) locates
%   all segments whose distances from the signal are local minima and
%   returns up to MAXSEG segments with smallest distances. The default
%   value of 'MaxNumSegments' is +Inf when 'MaxDistance' is specified and 1
%   when it is not.
%
%   [ISTART,ISTOP,DIST] = FINDSIGNAL(...,'TimeAlignment',ALIGN) specifies
%   the time alignment technique used to compute the distance.  The default
%   value is 'fixed'
%       'fixed' do not stretch or repeat samples to minimize the distance
%       'dtw'   attempt to reduce distances by automatically repeating
%               consecutive samples in either the data or the signal.
%       'edr'   minimize the number of edits between the data segment and
%               signal that leaves all remaining samples within a tolerance
%               that must be specified by the 'EDRTolerance' parameter.
%               DIST returns the number of edits required.  An edit consists
%               of inserting or removing a single sample in either the data
%               or the signal, or skipping a pair of samples in data and
%               signal.  Use this option when the data or signal, or both,
%               have outliers.
%
%   [ISTART,ISTOP,DIST] = FINDSIGNAL(...,'EDRTolerance',TOL) specifies the
%   tolerance, TOL, used to find the signal when using the 'edr' option of
%   the 'TimeAlignment' parameter.
%
%   [ISTART,ISTOP,DIST] = FINDSIGNAL(...,'Metric',METRIC) finds the signal
%   by minimizing the specified distance metric defined by METRIC.  The
%   default is 'squared'.
%      'absolute'  the sum of the absolute (manhattan) differences
%      'euclidean' the root sum squared differences
%      'squared'   the squared Euclidean distance
%      'symmkl'    the symmetric Kullback-Leibler distance 
%   When data and signal are matrices, the distances are taken between
%   corresponding column vectors; when data and signal are vectors,
%   distances are taken between the corresponding elements.  Note that when
%   data and signal are vectors, 'absolute' and 'euclidean' are equivalent.
% 
%   FINDSIGNAL(...) without output arguments plots the unnormalized signal
%   and data, highlighting any identified signal(s) found in the data.
%   FINDSIGNAL displays the data as a line when it is a vector and as an
%   image when it is a matrix. If the matrix is complex, then the real and
%   imaginary portions appear in the top and bottom half of each image,
%   respectively.
%
%   FINDSIGNAL(...,'Annotate',PLOTSTYLE) annotates a plot of the signal
%   with PLOTSTYLE. If PLOTSTYLE is 'data' the data is plotted where
%   matches to the signal are highlighted. If PLOTSTYLE is 'signal' the
%   signal is additionally plotted in a small plot. If PLOTSTYLE is 'all'
%   the signal, data, and normalized signal and normalized data are all
%   plotted. 'Annotate' is ignored if called with output arguments. The
%   default value of PLOTSTYLE is 'signal'.
%
%   % Example 1:
%   %   Find the segment of the data that has the closest squared euclidean
%   %   distance to a signal consisting of one cycle of a sinusoid
%   data = exp(-((1:300)/100).^2).*cos(2*pi*(1:300)/100); 
%   signal = sin(2*pi*(1:100)/100);
%   findsignal(data,signal)
%
%   % Example 2:
%   %    Locate the two best locations of the letter "A" in a 
%   %    handwriting sample
%   load blockletterex
%   letterA = MATLAB2(:,55:90);
%   findsignal(MATLAB1,letterA,'MaxNumSegments',2);
%
%   % Example 3:
%   %   Find the two best matches in a handwriting sample to the letter 'p'
%   %   using dynamic time warping
%   load cursiveex
%   findsignal(data,signal,'TimeAlignment','dtw', ...
%              'Normalization','center', ...
%              'NormalizationLength',600, ...
%              'MaxNumSegments',2)
%
%   See also FINDDELAY, FINDPEAKS, DTW, EDR, ALIGNSIGNALS, FINDCHANGEPTS.

%   Copyright 2016-2019 The MathWorks, Inc.

narginchk(2,18);

if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

needsTranspose = iscolumn(data);

if iscolumn(data) && isvector(signal)
  data = data.';
end

if iscolumn(signal) && isvector(data)
  signal = signal.';
end

validateattributes(data,{'single','double'},{'nonnan','2d','finite'},'findsignal','DATA',1);
validateattributes(signal,{'single','double'},{'nonnan','2d','finite'},'findsignal','SIGNAL',2);

[nstat,nlength,maxseg,maxdist,align,tol,metric,annotate] = parseInput(data,signal,varargin);

if ~isempty(data) && ~isempty(signal)
  if size(data,1) ~= size(signal,1)
    error(message('signal:findsignal:RowMismatch'));
  end
  [ndata, nsignal] = normalize(data, signal, nstat, nlength);
  [istart, istop, dist] = getsegments(ndata,nsignal,align,tol,metric);
else
  dist = NaN(1,0);
  istart = zeros(1,0);
  istop = zeros(1,0);
  nsignal = [];
  ndata = [];
end

% remove segments that do not fit the matching criteria
[istart,istop,dist] = filtersegments(istart,istop,dist,maxseg,maxdist);

if nargout == 0
  findsignalplot(signal,data,nsignal,ndata,istart,istop,metric,maxseg,annotate);
elseif needsTranspose
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
function [istart,istop,dist] = filtersegments(istart,istop,dist,maxseg,maxdist)
% keep only the segments whose distances are within MAXDIST
if isfinite(maxdist)
  idx = find(dist <= maxdist);
  dist = dist(idx);
  istart = istart(idx);
  istop = istop(idx);
end

% sort results by output distance metric
[dist, idx] = sort(dist,'ascend');
istart = istart(idx);
istop = istop(idx);

% truncate list if MAXSEGS is specified
if numel(dist) > maxseg
  dist = dist(1:maxseg);
  istart = istart(1:maxseg);
  istop = istop(1:maxseg);
end

%-------------------------------------------------------------------------
function [istart,istop,dist] = getsegments(data,signal,align,tol,metric)

% split real/imag if needed
if ~isreal(data) || ~isreal(signal)
  data = [real(data); imag(data)];
  signal = [real(signal); imag(signal)];
end

if strcmp(align,'dtw')
  % seek segments such that:
  %   dist(k) == dtw(data(:,istart(k):istop(k)),sig,metric)
  %   warping paths may not overlap
  [istart, istop, dist] = dtwfindmex(data,signal,metric);
elseif strcmp(align,'edr')
  % seek segments such that:
  %   dist(k) == edr(data(:,istart(k):istop(k)),sig,tol,metric)
  %   warping paths may not overlap
  [istart, istop, dist] = edrfindmex(data,signal,tol,metric);
else %'fixed'
  % seek segments such that:
  %   dist(k) == dist([data(:,istart(k):istop(k)); sig],metric)
  %   segments must be local minima
  [istart, istop, dist] = finddistminima(data,signal,metric);
end

%-------------------------------------------------------------------------
function [ndata, nsignal] = normalize(data,signal,nstat,nlength)

if strcmp(nstat,'center')
  % remove constant bias
  ndata = data - movmean(mean(data,1),nlength,2);
  nsignal = signal - movmean(mean(signal,1),nlength,2);
elseif strcmp(nstat,'power')
  % divide input (power) by average.
  ndata = data ./ movmean(mean(data,1),nlength,2);
  nsignal = signal ./ movmean(mean(signal,1),nlength,2);
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

ndata = data ./ allstd;


%-------------------------------------------------------------------------
function [nstat,nlength,maxseg,maxdist,align,tol,metric,annotate] = parseInput(data,signal,optargs)
p = inputParser;
p.addParameter('Normalization','none');
p.addParameter('NormalizationLength',2*max(1,max(size(data,2),size(signal,2))));
p.addParameter('MaxNumSegments',Inf);
p.addParameter('MaxDistance',Inf);
p.addParameter('TimeAlignment','fixed');
p.addParameter('EDRTolerance',NaN);
p.addParameter('Metric','squared');
p.addParameter('Annotate','signal');
p.parse(optargs{:});

r = p.Results;
nstat = validatestring(r.Normalization,{'center','zscore','power','none'}, ...
                       'findsignal','Normalization');
align = validatestring(r.TimeAlignment,{'fixed','dtw','edr'}, ...
                       'findsignal','MaxDistance');
metric = validatestring(r.Metric,{'absolute','euclidean','squared','symmkl'}, ...
                        'findsignal','Metric');
annotate = validatestring(r.Annotate,{'data','signal','all'});

nlength = r.NormalizationLength;
validateattributes(nlength,{'numeric'},{'>',1,'integer','scalar','finite'}, ...
  'findsignal','NormalizationLength');

[maxseg,maxdist] = parseFilterSettings(p,r);

tol = parseTolerance(p,r);

% Ensure signal, data, and normalization are properly conditioned when
% using symmetric Kullback-Leibler distance
if strcmp(metric,'symmkl')
  validateSymmKL(data, signal, nstat);
end  


%-------------------------------------------------------------------------
function tol = parseTolerance(p,r)
% Ensure EDRTolerance is called with 'edr' flag.  Otherwise error out.
tol = r.EDRTolerance;
if strcmp(r.TimeAlignment,'edr') && ~ismember('EDRTolerance',p.UsingDefaults)
  validateattributes(tol,{'numeric'},{'nonnegative','real','scalar','finite'}, ...
    'findsignal','EDRTolerance');
elseif strcmp(r.TimeAlignment,'edr')
  error(message('signal:findsignal:MissingEDRTolerance'));
elseif ~ismember('EDRTolerance',p.UsingDefaults)
  error(message('signal:findsignal:InvalidEDRTolerance'));
end  


%-------------------------------------------------------------------------
function [maxseg,maxdist] = parseFilterSettings(p,r)
% get segment filter settings
maxdist = r.MaxDistance;
validateattributes(maxdist,{'numeric'},{'nonnegative','real','scalar','nonnan'}, ...
  'findsignal','MaxDistance');

maxseg = r.MaxNumSegments;
if ~isscalar(maxseg) || isfinite(maxseg) || isnan(maxseg)
  validateattributes(maxseg,{'numeric'},{'positive','integer','scalar','nonnan'}, ...
    'findsignal','MaxNumSegments');
end

% if neither setting is specified, just use the best segment
if all(ismember({'MaxNumSegments','MaxDistance'},p.UsingDefaults))
  maxseg = 1;
end

%-------------------------------------------------------------------------
function validateSymmKL(data, signal, nstat)
% Ensure signal, data, and normalization are properly conditioned for
% symmetric Kullback-Leibler distance

if ~any(strcmp(nstat,{'none','power'}))
  error(message('signal:findsignal:NonUnipolarNorm',nstat));
end

if ~isreal(data) || any(data(:)<0)
  error(message('signal:findsignal:DataCannotBeNegative'))
end

if ~isreal(signal) || any(signal(:)<0)
  error(message('signal:findsignal:SignalCannotBeNegative'))
end
