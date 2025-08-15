function s = thiscoeffs(this)
%THISCOEFFS   Returns the coefficients.

%   Author(s): M.Sprague
%   Copyright 1988-2018 The MathWorks, Inc.

fn = coefficientnames(this);

for j = 1:length(fn)
    s.(fn{j}) = get(this, fn{j});
end


% [EOF]
