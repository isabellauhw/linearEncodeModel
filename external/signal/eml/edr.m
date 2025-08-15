function [dist,ix,iy] = edr(x,y,tol,varargin)
%#codegen

%   Copyright 2019 The MathWorks, Inc.
narginchk(3,5);
coder.internal.errorIf(nargout == 0, 'signal:edr:NeedOneOpCodeGen');
nargoutchk(1,3);

newVar = cell(size(varargin));
if nargin > 3
    [newVar{:}] = convertStringsToChars(varargin{:});
end

validateattributes(x,{'single','double'},{'nonnan','2d','finite'},'edr','X',1);
validateattributes(y,{'single','double'},{'nonnan','2d','finite'},'edr','Y',2);
validateattributes(tol,{'numeric'},{'finite','positive','scalar','real'},'edr','TOL',3)

% Check if signals have same spatial dimensions (same number of rows)
if isvector(x)
    coder.internal.errorIf(~isvector(y), 'signal:edr:RowMismatch');
else
    coder.internal.errorIf(size(x,1) ~= size(y,1), 'signal:edr:RowMismatch');
end

if nargin == 3
    metric = 'euclidean';
    hasr = false;
elseif nargin == 4
    if ischar(newVar{1})
        hasr = false;
        metric = getmetric(newVar{1});
        coder.internal.errorIf(isempty(metric), 'signal:chkunusedopt:UnrecognizedOption',newVar{1});
    else
        hasr = true;
        metric = 'euclidean';
        r = newVar{1};
        validateattributes(r,{'numeric'},{'finite','integer','positive','scalar','real'},'edr','MAXSAMP',4);
    end
else
    hasr = true;
    coder.internal.errorIf(~ischar(newVar{1}) && ~ischar(newVar{2}), 'signal:edr:TooManyInputArguments');
    metric1 = getmetric(newVar{1});
    metric2 = getmetric(newVar{2});
    coder.internal.errorIf(~isempty(metric1) && ~isempty(metric2), 'signal:getmutexclopt:ConflictingOptions',metric1,metric2);
    coder.internal.errorIf(~ischar(newVar{1}) && isempty(metric2), 'signal:chkunusedopt:UnrecognizedOption',newVar{2});
    coder.internal.errorIf(~ischar(newVar{2}) && isempty(metric1), 'signal:chkunusedopt:UnrecognizedOption',newVar{1});
    coder.internal.errorIf(isempty(metric1) && isempty(metric2), 'signal:chkunusedopt:UnrecognizedOption',newVar{1});
    
    if ~ischar(newVar{1})
        r = newVar{1};
        metric = getmetric(newVar{2});
    else
        r = newVar{2};
        metric = getmetric(newVar{1});
    end
    validateattributes(r,{'numeric'},{'finite','integer','positive','scalar','real'},'edr','MAXSAMP',4);
end

coder.internal.errorIf( strcmp(metric,'symmkl') &&(~isreal(x) || ~isreal(y) || checkanyneg(x) || checkanyneg(y)), 'signal:edr:MustBeRealPositive');

if ~isempty(x) && ~isempty(y)
    tbFlag = 0;
    if hasr
        [C,tbFlag] = constrainedCumulativeDistance(x, y, tol, double(r), metric);
    else
        C = unconstrainedCumulativeDistance(x, y, tol, metric);
    end
    dist=C(end,end);
    if tbFlag
        [iy1,ix1] = traceback(C);
    else
        [ix1,iy1] = traceback(C);
    end
else
    if isa(x,'single') || isa(y,'single')
        dist = cast(max(size(x,2),size(y,2)),'single');
    else
        dist = max(size(x,2),size(y,2));
    end
    ix1 = zeros(1,0);
    iy1 = zeros(1,0);
end

if iscolumn(x)
    ix = ix1';
    iy = iy1';
else
    ix = ix1;
    iy = iy1;
end

end % function edr ends
%-------------------------------------------------------------------------
function metric = getmetric(arg)
coder.internal.prefer_const(arg)
lArg = length(arg);
if strncmpi(arg, 'euclidean', lArg)
    metric = 'euclidean';
elseif strncmpi(arg, 'absolute', lArg)
    metric = 'absolute';
elseif strncmpi(arg, 'squared', lArg)
    metric = 'squared';
elseif strncmpi(arg, 'symmkl', lArg)
    metric = 'symmkl';
else
    metric = '';
end
end % function end
%-------------------------------------------------------------------------
function C = unconstrainedCumulativeDistance(x, y, tol, metric)

if isreal(x) && isreal(y)
    C = edrimpl(x, y, tol, metric);
else
    C = edrimpl([real(x); imag(x)], [real(y); imag(y)], tol, metric);
end
end % function end
%-------------------------------------------------------------------------
function [C,tbFlag] = constrainedCumulativeDistance(x, y, tol, r, metric)
% Constrained EDR needs input 1 to be longer than input 2

tbFlag = 0;
if isvector(x)
    m = length(x);
    n = length(y);
else
    m = size(x,2);
    n = size(y,2);
end

if m < n
    tbFlag = 1;
    if isreal(x) && isreal(y)
        C = edrimpl(y, x, tol, metric,r);
    elseif ~isreal(x) || ~isreal(y)
        C = edrimpl([real(y); imag(y)], [real(x); imag(x)], tol, metric, r);
    end
elseif isreal(x) && isreal(y)
    C = edrimpl(x, y, tol, metric, r);
else
    C = edrimpl([real(x); imag(x)], [real(y); imag(y)], tol, metric, r);
end
end % function end
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
end % function end
%-------------------------------------------------------------------------
function symmklFlag = checkanyneg(x)
symmklFlag = false;
for i=coder.internal.indexInt(1):coder.internal.indexInt(numel(x))
    if x(i) < 0
        symmklFlag = true;
        break;
    end
end
end % function end
%-------------------------------------------------------------------------