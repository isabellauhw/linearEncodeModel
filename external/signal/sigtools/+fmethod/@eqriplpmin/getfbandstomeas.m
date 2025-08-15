function [stopbands, passbands, Astop, Apass] = getfbandstomeas(this,hspecs)

%GETFBANDSTOMEASURE   Get frequency bands, and attenuation and ripple
%values from the filter specs in order to measure if specs are being met
%with the current order of the filter design. 

%   Copyright 1999-2015 The MathWorks, Inc.

stopbands = [hspecs.Fstop 1];
passbands = [0 hspecs.Fpass];

Astop = hspecs.Astop;
Apass = hspecs.Apass;

% [EOF]
