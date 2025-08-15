function thisdisp(this)
%DISP   Display this object.

%   Author(s): V. Pellissier
%   Copyright 2005-2017 The MathWorks, Inc.

fn = fieldnames(this);
N = length(fn);
% Reorder the fields. NumSamplesProcessed, ResetStates and States in
% the end.

nidx = [4 3 2 7];
if this.PersistentMemory
     % display states
     nidx = [nidx, 5];
end
fn = fn(nidx);

siguddutils('dispstr', this, fn, 20);

disp(this.filterquantizer, 20);

% [EOF]
