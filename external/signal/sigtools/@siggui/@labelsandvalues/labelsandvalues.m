function h = labelsandvalues(varargin)
%LABELSANDVALUES  Constructor for this class

%   Author(s): Z. Mecklai, J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

% built-in constructor
h = siggui.labelsandvalues;

set(h, varargin{:});

% Set the version and tag
set(h, 'Version', 1.0);
settag(h);

% [EOF]
