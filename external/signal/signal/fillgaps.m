function y = fillgaps(x,maxlen,order)
%FILLGAPS Fill gaps via autoregressive modeling
%   Y = FILLGAPS(X) replaces NaN values of an input vector, X, by fitting
%   an autoregressive (AR) model that minimizes the Akaike information
%   criterion over the remaining samples.  Each NaN value is replaced by a
%   weighted average of the values estimated by forward and backward
%   prediction.  If X is a matrix, each column will be treated as an
%   independent channel.
%
%   Y = FILLGAPS(X, MAXLEN) specifies the maximum length in samples of the
%   regions immediately before and after each gap to consider when
%   performing autoregressive estimation.  Use this parameter when your
%   signal is non-stationary.  If MAXLEN is empty or unspecified, FILLGAPS
%   iteratively fits the AR model using all previous (or future) points
%   when performing forward (or backward) estimation.
%
%   Y = FILLGAPS(X, MAXLEN, ORDER) specifies the desired order, ORDER, of
%   the autoregressive model to use when reconstructing the gap regions.
%   The order is truncated when ORDER is infinite or when an insufficient
%   number of samples are available.  If ORDER is specified as 'aic', then
%   FILLGAPS selects the ORDER that minimizes the Akaike information
%   criterion.  The default value of ORDER is 'aic'.
%   
%   FILLGAPS(...) without output arguments plots the original samples and
%   the reconstructed signal.
%
%   % Example 1:
%   %   Reconstruct missing data in a sinusoid
%   x = sin(2*pi*5*(1:1024)/1024);   % Define a sinusoid
%   x(450:550) = NaN;
%   fillgaps(x);
%
%   % Example 2:
%   %   Reconstruct missing data in an audio signal
%   [y,fs] = audioread('guitartune.wav');
%   x = y(1:3500);
%   plot(x);
%   x(2000:2600) = NaN;
%   hold on
%   fillgaps(x)
%   legend('original signal','samples','reconstructed signal',...
%          'Location','best')
%
%   See also ARBURG, RESAMPLE.

% References:
%   S. Kay, MODERN SPECTRAL ESTIMATION, Prentice-Hall, 1988, Chapter 7
%   S. Orfanidis, OPTIMUM SIGNAL PROCESSING, 2nd Ed. Macmillan, 1988,
%      Chapter 5
%   H. Akaike, "fitting autoregressive models for prediction," Ann. Inst.
%      Stat. Math., vol 21, pp. 243-247, 1969.
%
%   Copyright 2015 The MathWorks, Inc.

narginchk(1,3)

% transform to column vector if row vector
wasrow = isrow(x);
if wasrow
  x = x(:);
end

% validate input signal:  only 'double' is supported (FILTIC).
validateattributes(x,{'double'},{'2d'}, ...
  'fillgaps','X');
validateattributes(x(~isnan(x)),{'double'},{'finite'}, ...
  'fillgaps','X');

% validate maximum segment length
if nargin<2 || isempty(maxlen)
  maxlen = Inf;
else
  validateattributes(maxlen,{'numeric'},{'scalar'}, ...
    'fillgaps','MAXLEN');
  if ~isinf(maxlen)
    validateattributes(maxlen,{'numeric'},{'integer','scalar','>',2}, ...
      'fillgaps','MAXLEN');
  end
end
maxlen = double(maxlen);

% validate maximum order
if nargin<3 || isempty(order)
  order = 'aic';
elseif ischar(order) || (isstring(order) && isscalar(order))
  order = validatestring(order,{'aic'},'fillgaps','ORDER');
else
  validateattributes(order,{'numeric'},{'positive','scalar'}, ...
    'fillgaps','ORDER');
  if ~isinf(order)
    validateattributes(order,{'numeric'},{'integer','positive','scalar'}, ...
      'fillgaps','ORDER');
    if order>maxlen
      error(getString(message('signal:fillgaps:OrderTooBig',num2str(order),num2str(maxlen))));
    end
  end
  order = double(order);
end

% perform fill in forward direction
[yf,wf] = arfill(x,maxlen,order);

% perform fill in backward direction
[yb,wb] = arfill(flipud(x),maxlen,order);
yb = flipud(yb);
wb = flipud(wb);

% perform weighted average
yfb = (yf.*wf + yb.*wb) ./ (wf + wb);

% assign and/or plot output
if nargout==0
  plotgaps(x, yfb);
elseif wasrow
  y = yfb.';
else
  y = yfb;
end

%-------------------------------------------------------------------------
function plotgaps(x, yfb)
if isreal(x)
  plot(1:size(x,1),x,'.', 1:size(yfb,1),yfb);
else
  plot3(1:size(x,1),real(x),imag(x),'.', ...
        1:size(yfb,1),real(yfb),imag(yfb));
end

%-------------------------------------------------------------------------
function [y,w] = arfill(x,maxlen,order)
y = x;
w = ones(size(x));
chanlen = size(x,1);
nchan = size(x,2);
for ichan=1:nchan
  igapstart = findnextgap(y,ichan);
  ifirstseg = findfirstseg(y,ichan);
  if ~isempty(ifirstseg)
    while ~isempty(igapstart)
      igapend = findgapend(y,ichan,igapstart,chanlen);
      istart = max(ifirstseg,igapstart-maxlen);
      gaplen = igapend-igapstart+1;
      seglen = igapstart-istart;
      if seglen > 1
        % predict from segment immediately prior to the gap
        yfuture = arpredict(y(istart:igapstart-1,ichan), gaplen, order);
        weights = getweights(gaplen,igapstart,igapend,chanlen);
      elseif igapstart > 1
        % prior segment is just one sample long.  predict a constant.
        yfuture = repmat(y(igapstart-1),gaplen,1);
        weights = getweights(gaplen,igapstart,igapend,chanlen);
      elseif igapend < chanlen
        % nothing to predict
        yfuture = zeros(gaplen,1);
        weights = zeros(gaplen,1);
      end
      w(igapstart:igapend,ichan) = weights;
      y(igapstart:igapend,ichan) = yfuture;
      igapstart = findnextgap(y,ichan);
    end
  end
end

%-------------------------------------------------------------------------
function istart = findfirstseg(y,ichan)
istart = find(~isnan(y(:,ichan)),1,'first');

%-------------------------------------------------------------------------
function istart = findnextgap(y,ichan)
istart = find(isnan(y(:,ichan)),1,'first');

%-------------------------------------------------------------------------
function iend = findgapend(y,ichan,istart,chanlen)
iend = istart+find(~isnan(y(istart:end,ichan)),1,'first')-2;
if isempty(iend)
  iend = chanlen;
end

%-------------------------------------------------------------------------
function y = arpredict(x, n, order)
xmean = mean(x);
xunbiased = x - xmean;
if strcmp(order,'aic')
  a = arburgaic(xunbiased);
else
  a = arburg(xunbiased, min(length(x)-1,order));
end

if any(isnan(a))
  y = repmat(xmean, n, 1);
else
  zi = filtic(1, a, flipud(xunbiased));
  y = xmean + filter(1, a, zeros(n,1), zi);
end

%-------------------------------------------------------------------------
function w = getweights(n, igapstart, igapend, chanlen)
if igapstart==1 || igapend==chanlen
  w = ones(n,1);
else
  w = (n:-1:1).';
end

%-------------------------------------------------------------------------
function a = arburgaic(x)
% define largest number of orders to search before selecting local minimum
postMax = 30;
% clear post-search delta order counter
postCount = 0;

n  = size(x,1);
pmax = n-1;

% Initialization
efp = x(2:end);
ebp = x(1:end-1);

% Initial error
logE = log(x'*x./n);
bestAIC = Inf;
bestA = [];
% By convention all polynomials are row vectors
a = zeros(1,pmax+1,class(x));
a(1) = 1;

for p=2:pmax+1
   % Calculate the next order reflection (parcor) coefficient
   k = (-2.*ebp'*efp) ./ (efp'*efp + ebp'*ebp);

   % Update the forward and backward prediction errors
   ef = efp(2:end)    + k  .* ebp(2:end);
   ebp = ebp(1:end-1) + k' .* efp(1:end-1);
   efp = ef;
   
   % Update the prediction error
   logE = logE + log(1 - k'.*k);
   newAIC = logE + 2*(p+1)/n;
   if newAIC < bestAIC
     bestAIC = newAIC;
     % set new termination condition to be 30 orders
     % or 25% beyond the current order (whichever is larger)
     postMax = max(30,floor(p/4));
     postCount = 0;
     bestA = [];
   else % newAIC is either NaN or higher than previous best
     postCount = postCount + 1;
     if isempty(bestA)
       bestA = a(1:p-1);
     end
     if isnan(k) || postCount > postMax
       break
     end
   end

   % Update the AR coeff.
   a(2:p) = a(2:p) + k .* conj(a(p-1:-1:1));
end

if ~isempty(bestA)
  a = bestA;
end