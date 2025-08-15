function thisdisp(this)
%DISP   Display this object.

%   Author(s): R. Losada
%   Copyright 2005-2017 The MathWorks, Inc.


fn = fieldnames(this);

% Reorder the fields. NumSamplesProcessed, ResetStates and States in
% the end.
nidx = [2, 1, 5];
if this.PersistentMemory
    nidx = [nidx, 3];
end
fn = fn(nidx);

siguddutils('dispstr', this, fn);

% [EOF]
