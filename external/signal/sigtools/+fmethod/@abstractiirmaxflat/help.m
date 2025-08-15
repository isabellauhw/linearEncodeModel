function help(this)
%HELP   

%   Copyright 1999-2015 The MathWorks, Inc.

help_header(this, 'butter', 'generalized Butterworth', 'IIR');
if isfdtbxinstalled
    help_sosscale(this);
end
help_examples(this);

%[EOF]  