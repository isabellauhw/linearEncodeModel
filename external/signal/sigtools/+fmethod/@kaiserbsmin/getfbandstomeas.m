function [stopbands, passbands, Astop, Apass] = getfbandstomeas(this,hspecs)

%GETFBANDSTOMEASURE   Get frequency bands, and attenuation and ripple
%values from the filter specs in order to measure if specs are being met
%with the current order of the filter design. 

%   Copyright 1999-2015 The MathWorks, Inc.

stopbands = [hspecs.Fstop1 hspecs.Fstop2];
passbands = [0 hspecs.Fpass1; hspecs.Fpass2 1];

Astop = hspecs.Astop;
Apass = [hspecs.Apass1 hspecs.Apass2];

% [EOF]
