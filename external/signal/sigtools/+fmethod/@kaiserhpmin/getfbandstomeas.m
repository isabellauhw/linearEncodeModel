function [stopbands, passbands, Astop, Apass] = getfbandstomeas(this,hspecs)

%GETFBANDSTOMEASURE   Get frequency bands, and attenuation and ripple
%values from the filter specs in order to measure if specs are being met
%with the current order of the filter design. 

%   Copyright 1999-2015 The MathWorks, Inc.

stopbands = [0 hspecs.Fstop];
passbands = [hspecs.Fpass 1];

Astop = hspecs.Astop;
Apass = hspecs.Apass;

% [EOF]
