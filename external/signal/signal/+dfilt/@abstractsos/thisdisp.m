function thisdisp(this)
%DISP Object display.
  
%   Author: V. Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.


fn = fieldnames(this);
nidx = [5 2 3 4 1 8];

if this.PersistentMemory
    % display states
    nidx = [nidx, 6];
end

fn = fn(nidx);

siguddutils('dispstr', this, fn, 24);

disp(this.filterquantizer, 24)

% [EOF]
