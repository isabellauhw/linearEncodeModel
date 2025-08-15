function setname(this, indx, name)
%SETNAME   Set the name.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

d = get(this, 'Data');

% Get the structure at the specified index.
s = d.elementat(indx);

% Replace the name.
s.currentName = name;

% Reset the structure.
d.replaceelementat(s, indx);

% Send the NewData event so that the listbox will update.
send(this, 'NewData');

% [EOF]
