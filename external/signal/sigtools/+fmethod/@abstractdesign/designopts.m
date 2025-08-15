function s = designopts(this, varargin)
%DESIGNOPTS Abstract method.

%   Copyright 1999-2015 The MathWorks, Inc.

addsysobjdesignopt(this);

s = get(this);

s = rmfield(s, 'DesignAlgorithm');

s = thisdesignopts(this, s, varargin{:});

% Let subclass reorder design options if needed.
s = reorderdesignoptsstruct(this,s,varargin{:});


% [EOF]
