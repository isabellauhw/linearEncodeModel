function Hd = reffilter(this)
%REFFILTER   Returns the double representation of the filter object.

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.

Hd = lwdfilt.symfir;
Hd.Numerator = this.refnum;
Hd.refnum = this.refnum;



% [EOF]
