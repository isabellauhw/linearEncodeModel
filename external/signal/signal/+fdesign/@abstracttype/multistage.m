function varargout = multistage(this, varargin)
%MULTISTAGE   Design a multistage FIR filter using the equiripple method.
%   MULTISTAGE(D) designs a multistage equiripple filter using the specifications
%   in the object D.

%   Copyright 2005-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'multistage', varargin{:});
catch e
    throw(e);
end

% [EOF]
