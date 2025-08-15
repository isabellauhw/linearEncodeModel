function varargout = window(this, varargin)
%WINDOW   FIR filter design using the window method.
%   WINDOW(D) FIR filter design using the window method.

%   Copyright 1999-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'window', varargin{:});
catch e
    throw(e);
end

% [EOF]
