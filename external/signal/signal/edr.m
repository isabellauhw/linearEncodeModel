function [dist,ix,iy] = edr(x,y,tol,varargin) 
%EDR    Edit distance on real signals
%   DIST = EDR(X,Y,TOL) returns the edit distance between real sequences X
%   and Y.  EDR returns the minimum number of elements that must be
%   inserted into X, inserted into Y, or skipped in both X and Y so that
%   the remaining elements between X and Y are within the specified
%   tolerance, TOL, measured in Euclidean distance.
%
%   [DIST,IX,IY] = EDR(X,Y,TOL) additionally returns the warping path, IX
%   and IY, that minimizes the total edit distance between X(IX) and Y(IY)
%   when X and Y are vectors and between X(:,IX) and Y(:,IY) when X and Y
%   are matrices.
%
%   [DIST,IX,IY] = EDR(X,Y,TOL,MAXSAMP) additionally restricts insertion
%   operations so that they must be within MAXSAMP samples of a straight
%   line fit between X and Y.  If MAXSAMP is unspecified, IX and IY are
%   unrestricted.
%
%   [DIST,IX,IY] = EDR(X,Y,TOL,...,METRIC) performs comparisons using
%   the specified distance metric defined by METRIC, matching when the
%   distance metric is within the tolerance parameter specified by TOL.
%   The default is 'euclidean'.
%      'absolute'  the sum of the absolute (manhattan) differences
%      'euclidean' the root sum squared differences
%      'squared'   the squared Euclidean distance
%      'symmkl'    the symmetric Kullback-Leibler distance 
%   When data and signal are matrices, the distances are taken between
%   corresponding column vectors; when data and signal are vectors,
%   distances are taken between the corresponding elements.  Note that when
%   data and signal are vectors, 'absolute' and 'euclidean' are equivalent.
%
%   EDR(...) without output arguments plots the original and aligned
%   signals.  EDR displays the alignment of X and Y via a line plot when
%   they are vectors, and via horizontally aligned images when they are
%   matrices.  If the matrices are complex, the real and imaginary
%   portions appear in the top and bottom half of each image, respectively.
%   
%   % Example 1:
%   %   Compute and plot the best edit distance between real
%   %   chirp and sinusoidal signals that have significant outliers
%   x = chirp(0:999,0,1000,1/100);
%   y = cos(2*pi*5*(0:199)/200);
%   x(400:410) = 7;
%   y(100:115) = 7;
%   edr(x,y,.1)
%
%   % Example 2:
%   %   Compute and plot the best Euclidean distance between complex
%   %   chirp and sinusoidal signals that have significant outliers.
%   x = exp(2i*pi*(3*(1:1000)/1000).^2);
%   y = exp(2i*pi*9*(1:399)/400);
%   x(400:410) = 7;
%   y(100:115) = 7;
%   edr(x,y,.1)
%
%   % Example 3:
%   %   Align handwriting samples along the x-axis in the presence of a 
%   %   significant blotch
%   load blockletterex
%   MATLAB1(15:20,54:60) = 4000;
%   MATLAB2(15:20,84:96) = 4000;
%   edr(MATLAB1,MATLAB2,450);
%
%   See also DTW, ALIGNSIGNALS, FINDSIGNAL, FINDDELAY, XCORR.

%   References: 
%   * L. Chen, M. T. Ozsu, V. Oria, "Robust and Fast Similarity Search
%     for Moving Object Trajectories", Proc. ACM SIGMOD 2005, pp. 491-502.
%   * H. Sakoe and S. Chiba, "Dynamic Programming Algorithm Optimization
%     for Spoken Word Recognition" IEEE Transactions on Acoustics, Speech
%     and Signal Processing, Vol. ASSP-26, No. 1, Feb 1978, pp. 43-49.
%   * K.K. Paliwal, A. Agarwal and S.S. Sinha, "A Modification over Sakoe
%     and Chiba's dynamic time warping algorithm for isolated word
%     recognition" IEEE International Conference on ICASSP 1982., Vol. 7,
%     pp. 1259-1261.

%   Copyright 2016-2018 The MathWorks, Inc.

narginchk(3,5);

if nargin > 3
    [varargin{:}] = convertStringsToChars(varargin{:});
end

needsTranspose = iscolumn(x);

if iscolumn(x) && isvector(y)
  x = x.';
end

if iscolumn(y) && isvector(x)
  y = y.';
end

validateattributes(x,{'single','double'},{'nonnan','2d','finite'},'edr','X',1);
validateattributes(y,{'single','double'},{'nonnan','2d','finite'},'edr','Y',2);
validateattributes(tol,{'numeric'},{'finite','positive','scalar','real'},'edr','TOL',3)

if size(x,1) ~= size(y,1)
  error(message('signal:edr:RowMismatch'));
end

[metric, varargin] = getmutexclopt({'absolute','euclidean','squared','symmkl'},'euclidean',varargin);
if strcmp(metric,'symmkl')
  if ~isreal(x) || ~isreal(y) || any(x(:)<0) || any(y(:)<0)
    error(message('signal:edr:MustBeRealPositive'))
  end
end
chkunusedopt(varargin);

if ~isempty(x) && ~isempty(y)
  if isempty(varargin)
    C = unconstrainedCumulativeDistance(x, y, tol, metric);
  elseif numel(varargin)==1
    r = varargin{1};
    validateattributes(r,{'numeric'},{'finite','integer','positive','scalar','real'},'edr','MAXSAMP',4)
    C = constrainedCumulativeDistance(x, y, tol, double(r), metric);
  else
    error(message('signal:edr:TooManyInputArguments'))
  end
  dist=C(size(x,2),size(y,2));
  [ix,iy] = traceback(C);
else
  dist = max(size(x,2),size(y,2));
  ix = zeros(1,0);
  iy = zeros(1,0);
end

if nargout==0
  edrplot(x, y, ix, iy, dist)
elseif needsTranspose
  ix = ix';
  iy = iy';
end

%-------------------------------------------------------------------------
function C = unconstrainedCumulativeDistance(x, y, tol, metric)
if isreal(x) && isreal(y)
  C = edrmex(x, y, tol, metric);
else
  C = edrmex([real(x); imag(x)], [real(y); imag(y)], tol, metric);
end

%-------------------------------------------------------------------------
function C = constrainedCumulativeDistance(x, y, tol, r, metric)
m = size(x,2);
n = size(y,2);
if m<n
  if isreal(x) && isreal(y)
    C = edrmex(y, x, tol, r, metric)';
  else
    C = edrmex([real(y); imag(y)], [real(x); imag(x)], tol, r, metric)';
  end
elseif isreal(x) && isreal(y)
  C = edrmex(x, y, tol, r, metric);
else
  C = edrmex([real(x); imag(x)], [real(y); imag(y)], tol, r, metric);
end

%-------------------------------------------------------------------------
function [ix,iy] = traceback(C)
m = size(C,1);
n = size(C,2);

% pre-allocate to the maximum warping path size.
ix = zeros(m+n,1);
iy = zeros(m+n,1);

ix(1) = m;
iy(1) = n;

i = m;
j = n;
k = 1;

while i>1 || j>1
  if j == 1
    i = i-1;
  elseif i == 1
    j = j-1;
  else
    % trace back to the origin, ignoring any NaN value
    % prefer i in a tie between i and j
    cij = C(i-1,j-1);
    ci = C(i-1,j);
    cj = C(i,j-1);
    i = i - (ci<=cj | cij<=cj | cj~=cj);
    j = j - (cj<ci | cij<=ci | ci~=ci);
  end
  k = k+1;
  ix(k) = i;
  iy(k) = j;
end

ix = ix(k:-1:1);
iy = iy(k:-1:1);
