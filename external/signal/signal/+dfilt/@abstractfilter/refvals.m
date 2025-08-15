function v = refvals(this)
%REFVALS   Return the reference values.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

% Default refvals just gets the coefficients
c = coefficientnames(this);
v = cell(size(c));
for ii = 1:length(v)
    v{ii} = this.(c{ii});
end

% [EOF]
