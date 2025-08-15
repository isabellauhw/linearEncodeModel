function setspecs(this, sps, varargin)
%SETSPECS Set the specs
%   OUT = SETSPECS(ARGS) <long description>

%   Copyright 2008-2018 The MathWorks, Inc.

if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargin < 2
    return;
end

if ischar(sps)
    error(message('signal:fdesign:abstractpulseshape:setspecs:invalidInput'));
end

this.SamplesPerSymbol = sps;

abstract_setspecs(this, varargin{:});

% [EOF]
