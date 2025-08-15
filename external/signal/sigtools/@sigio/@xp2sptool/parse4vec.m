function varargout = parse4vec(this, varargin)
%PARSE4VEC   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

if nargout
    [varargout{1:nargout}] = parse4obj(this, varargin{:});
else
    parse4obj(this, varargin{:});
end

% [EOF]
