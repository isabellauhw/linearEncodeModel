function removeelementat(this, indx)
%REMOVEELEMENTAT Removes the element at the vector index

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(2,2);
chkindx(this, indx);

% Cache the old data at the index to delete.
olddata = this.data{indx};
this.data(indx) = [];

sendchange(this, 'ElementRemoved', olddata);

% [EOF]
