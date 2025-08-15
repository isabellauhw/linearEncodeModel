function validstructs = getvalidstructs(this)
%GETVALIDSTRUCTS   Get the validstructs.

%   Copyright 1999-2017 The MathWorks, Inc.


if isfdtbxinstalled
    validstructs = fdfvalidstructs(this);
else
    validstructs = {'df1sos','df2sos','df1tsos','df2tsos'};
end

% [EOF]
