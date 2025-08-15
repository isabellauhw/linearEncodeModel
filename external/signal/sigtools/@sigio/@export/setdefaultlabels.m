function deflabels = setdefaultlabels(this, deflabels)
%SETDEFAULTLABELS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

set(find(this, '-isa', 'sigio.abstractxpdestwvars'), 'DefaultLabels', deflabels);

% [EOF]
