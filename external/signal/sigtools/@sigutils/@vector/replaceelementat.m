function replaceelementat(this, newvalue, indx)
%REPLACEELEMENTAT Replace the element at the indx
%   REPLACEELEMENTAT(H, DATA, INDEX)

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(3,3);
chkindx(this, indx);

% Replace the element at the specified index.
this.Data{indx} = newvalue;

sendchange(this, 'ElementReplaced', indx);

% [EOF]
