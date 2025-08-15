function setspecs(this, varargin)
%SETSPECS   Set the specs.

%   Copyright 2005-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

abstract_setspecs(this, varargin{:});

% [EOF]
