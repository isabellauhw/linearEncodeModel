function data = elementat(this, indx)
%ELEMENTAT Returns the component at the specified index

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(2,2);
chkindx(this, indx);

% Return the data at the requested index.
data = this.Data{indx};

% [EOF]
