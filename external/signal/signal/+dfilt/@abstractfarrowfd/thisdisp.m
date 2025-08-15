function thisdisp(this)
%DISP   Display this object.

%   Author(s): V. Pellissier
%   Copyright 2005-2017 The MathWorks, Inc.


fn = fieldnames(this);

nidx = [4 3 1 2 7];
if this.PersistentMemory
     % display states
     nidx = [nidx, 5];
end

fn = fn(nidx);

siguddutils('dispstr', this, fn, 25);

disp(this.filterquantizer, 25);

% [EOF]
