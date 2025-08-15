function varargout = design(this, varargin)
%DESIGN   Design the filter and return an object.

%   Copyright 1999-2015 The MathWorks, Inc.

[varargout{1:nargout}] = designcoeffs(this, varargin{:});

% Put it into a structure.
Hd = createobj(this,varargout{1});

Hd.setfmethod(this);

varargout{1} = Hd;

% [EOF]
