function str = updateexportmode(this,idx)
%UPDATEEXPORTMODE Update export mode according to the selection

%   Copyright 2011 The MathWorks, Inc.

validString = {'C header file', 'Write directly to memory'};

str = validString{idx};

% [EOF]
