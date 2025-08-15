function help(this)
%HELP   Generic help for butterworth designs.

%   Copyright 1999-2015 The MathWorks, Inc.

help_butter(this);
if isfdtbxinstalled
    help_sosscale(this);
end
help_examples(this);

% [EOF]
