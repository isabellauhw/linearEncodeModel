function varargout = iirls(this,varargin)
%IIRLS   

%   Copyright 2005-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'iirls', varargin{:});
catch e
    throw(e);
end

% [EOF]
