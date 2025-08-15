function s = savemetadata(this)
%SAVEMETADATA   Save any meta data.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.

s.fdesign      = getfdesign(this);
s.fmethod      = getfmethod(this);
s.measurements = this.privMeasurements;
s.designmethod = this.privdesignmethod;

% [EOF]
