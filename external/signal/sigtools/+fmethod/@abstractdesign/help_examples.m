function help_examples(this)
%HELP_EXAMPLES   

%   Copyright 1999-2015 The MathWorks, Inc.

example_strs = getexamples(this);

for indx = 1:length(example_strs)
    disp(sprintf(['    %% ' getString(message('signal:sigtools:fmethod:Example')) ' #%d - %s'], indx, example_strs{indx}{1}));
    for jndx = 2:length(example_strs{indx})
        disp(sprintf('       %s', example_strs{indx}{jndx}));
    end
    disp(' ');
end

% [EOF]
