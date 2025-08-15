function Hd = reffilter(this)
%REFFILTER   Returns the double representation of the filter object.

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.

Hd = lwdfilt.sos;
Hd.sosMatrix = this.refsosMatrix;
Hd.refsosMatrix = this.refsosMatrix;
Hd.ScaleValues = this.refScaleValues;
Hd.refScaleValues = this.refScaleValues;

% [EOF]
