function varargout = ellip(this, varargin)
%ELLIP   Elliptic or Cauer digital filter design.
%   H = ELLIP(D) Design an Elliptic digital filter using the specifications
%   in the object D.
%
%   H = ELLIP(D, MATCH) Design a filter and match one band exactly.  MATCH
%   can be either 'passband' 'stopband' or 'both' (default).  This flag is
%   only used when designing minimum order Elliptic filters.

%   Copyright 1999-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'ellip', varargin{:});
catch e
    throw(e);
end

% [EOF]
