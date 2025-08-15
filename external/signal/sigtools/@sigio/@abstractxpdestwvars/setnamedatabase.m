function setnamedatabase(this, db)
%SETNAMEDATABASE   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

set(this, 'PreviousLabelsAndNames', setstructfields(getnamedatabase(this), db));
formatnames(this);

% [EOF]
