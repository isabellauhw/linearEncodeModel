function varargout = thisdesign(this, method, varargin)
%THISDESIGN   Design the filter.

%   Copyright 1999-2005 The MathWorks, Inc.

[varargout{1:nargout}] = feval(method, this.CurrentSpecs, varargin{:});

% [EOF]
