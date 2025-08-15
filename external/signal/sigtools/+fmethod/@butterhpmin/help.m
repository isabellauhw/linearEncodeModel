function help(this)
%HELP   Help for the Highpass minimum order butterworth design.

%   Copyright 1999-2015 The MathWorks, Inc.

help_butter(this);
help_matchexactly(this);
if isfdtbxinstalled
    help_sosscale(this);
end
help_examples(this);

% [EOF]
