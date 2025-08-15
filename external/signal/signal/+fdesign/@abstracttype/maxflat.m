function varargout = maxflat(this, varargin)
%MAXFLAT   FIR filter design using the maxflat method
%   MAXFLAT(D) FIR filter design using the maxflat method.

%   Copyright 2008-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'maxflat', varargin{:});
catch ME
    throwAsCaller(ME);
end

% [EOF]
