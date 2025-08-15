function revert(this)
%REVERT   Revert the filter to its reference.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

this.Filter    = this.refFilter;
this.isApplied = false;

data.filter = this.Filter;
data.mcode  = [];

send(this, 'NewFilter', ...
    sigdatatypes.sigeventdata(this, 'NewFilter', data));

% [EOF]
