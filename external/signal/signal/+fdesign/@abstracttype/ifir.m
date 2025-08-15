function varargout = ifir(this, varargin)
%IFIR   Design a two-stage FIR filter using the IFIR method.
%   IFIR(D) designs a two-stage equiripple filter using the specifications
%   in the object D.

%   Copyright 2005-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'ifir', varargin{:});
catch e
    throw(e);
end

% [EOF]
