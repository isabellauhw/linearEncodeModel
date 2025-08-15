function thisdisp(this)
%DISP Object display.
  
%   Author: V. Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.


fn = fieldnames(this);

nidx = [3 2 1 6];
if this.PersistentMemory
     % display states
     nidx = [nidx, 4];
end
fn = fn(nidx);

siguddutils('dispstr', this, fn, 20);
disp(this.filterquantizer, 20)

% [EOF]
