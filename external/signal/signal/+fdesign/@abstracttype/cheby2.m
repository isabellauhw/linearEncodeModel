function varargout = cheby2(this, varargin)
%CHEBY2   Chebyshev Type II digital filter design.
%   H = CHEBY2(D) Design a Chebyshev Type II digital filter using the
%   specifications in the object D.
%
%   H = CHEBY2(D, MATCH) Design a filter and match one band exactly.  MATCH
%   can be either 'passband' or 'stopband' (default).  This flag is only
%   used when designing minimum order Chebyshev filters.

%   Copyright 1999-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'cheby2', varargin{:});
catch e
    throw(e);
end

% [EOF]
