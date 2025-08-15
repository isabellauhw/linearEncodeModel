function string = index2string(hSB, index)
%INDEX2STRING Convert the index to the matching string

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

% This will be a private method

labels    = get(hSB, 'Labels');

if index > length(labels)
    error(message('signal:siggui:sidebar:index2string:IdxOutOfBound'));
else
    string = labels{index};
end

% [EOF]
