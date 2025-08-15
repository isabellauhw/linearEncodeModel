function help(this)
%HELP   

%   Copyright 1999-2015 The MathWorks, Inc.

help_equiripple(this);
help_densityfactor(this);
fprintf('%s\n', ['    ' getString(message('signal:sigtools:fmethod:NoticeThatTheFilterOrderMustBeEven'))]);
disp(' ');

help_examples(this);


% [EOF]
