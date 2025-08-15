function varargout = design(this, varargin)
%DESIGN   Design the filter.
%   DESIGN(D, M, VARARGIN) Design the filter using the method in the string
%   M on the specs D.  VARARGIN is passed to M.

%   Copyright 1999-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Suppress MFILT deprecation warning
w = warning('off', 'dsp:mfilt:mfilt:Obsolete');
restoreWarn = onCleanup(@() warning(w));

if nargout
    varargout{1} = superdesign(this, varargin{:});
else
    superdesign(this, varargin{:});
end

% [EOF]
