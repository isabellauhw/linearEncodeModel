function varargout = designmethods(this, varargin)
%DESIGNMETHODS   Returns a cell of design methods.

%   Copyright 2008-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargout
    varargout = {designmethods(this.PulseShapeObj, varargin{:})};
else
    designmethods(this.PulseShapeObj, varargin{:})
end
% [EOF]
