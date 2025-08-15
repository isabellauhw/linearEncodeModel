function thisdisp(this)
%DISP Object display.
  
%   Author: V. Pellissier
%   Copyright 1999-2017 The MathWorks, Inc.


fn = fieldnames(this);

nidx = [4 1 2 3 7];
if this.PersistentMemory
    % display states
    nidx = [nidx, 5];
end
fn = fn(nidx);

siguddutils('dispstr', this, fn);

disp(this.filterquantizer)

% [EOF]
