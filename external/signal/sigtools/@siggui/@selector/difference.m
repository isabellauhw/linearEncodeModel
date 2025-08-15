function factor = difference(hSct, indx)
%DIFFERENCE Returns the difference between the # of tags and the # of strings.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

lbls = get(hSct, 'Strings');
tags = get(hSct, 'Identifiers');

factor = length(tags{indx}) - length(lbls{indx});

% [EOF]
