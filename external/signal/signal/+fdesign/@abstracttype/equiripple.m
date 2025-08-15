function varargout = equiripple(this, varargin)
%EQUIRIPPLE   Design an equiripple filter.
%   EQUIRIPPLE(D) designs an equiripple filter using the specifications in
%   the object D.

%   Copyright 1999-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'equiripple', varargin{:});
catch e
    throw(e);
end

% [EOF]
