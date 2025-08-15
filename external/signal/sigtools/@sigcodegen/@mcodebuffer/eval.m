function eval(this)
%EVAL Evaluate the strings

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

eval(this.string);
w = whos;
w = {w.name};

for indx = 1:length(w)
    if ~strcmpi(w{indx}, 'this')
        assignin('caller', w{indx}, eval(w{indx}));
    end
end

% [EOF]
