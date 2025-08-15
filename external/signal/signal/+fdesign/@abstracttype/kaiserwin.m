function varargout = kaiserwin(this, varargin)
%KAISERWIN   Design a filter using a kaiser window.
%   KAISERWIN(D) Design a filter using a kaiser window and the
%   specifications in the object D.

%   Copyright 1999-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = privdesigngateway(this, 'kaiserwin', varargin{:});
catch e
    throw(e);
end

% [EOF]
