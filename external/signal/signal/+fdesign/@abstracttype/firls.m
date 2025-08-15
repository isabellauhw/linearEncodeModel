function varargout = firls(this, varargin)
%FIRLS   Design a least-squares filter.   

%   Copyright 1999-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'firls', varargin{:});
catch e
    throw(e);
end

% [EOF]
