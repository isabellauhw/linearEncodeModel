function thisdisp(this)
%DISP Object display.
  
%   Author: V. Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.


fn = fieldnames(this);

% Reorder the fields. NumSamplesProcessed, ResetStates and States in
% the end.
nidx = [5 1 2 3 4 8];

if this.PersistentMemory
    % display states
    nidx = [nidx, 6];
end
fn = fn(nidx);

siguddutils('dispstr', this, fn);

disp(this.filterquantizer)

% [EOF]
