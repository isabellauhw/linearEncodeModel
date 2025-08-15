function lblStrs = getcurrentlabels(h)
%GETCURRENTLABELS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

labels  = get(h,'Labels');
lblStrs = labels.(getshortstruct(h));

% [EOF]
