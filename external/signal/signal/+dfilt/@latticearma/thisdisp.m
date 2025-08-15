function thisdisp(this)
%DISP Object display.
  
%   Author: V. Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.


fn = fieldnames(this);

nidx = [4 3 2 1 7];
if this.PersistentMemory
    % display states
    nidx = [nidx, 5];
end

fn = fn(nidx);

siguddutils('dispstr', this, fn, 23);
disp(this.filterquantizer, 23)

% [EOF]
