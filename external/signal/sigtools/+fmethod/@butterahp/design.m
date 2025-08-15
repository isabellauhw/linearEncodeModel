function Ha = design(h,hs)
%DESIGN   

%   Copyright 1999-2015 The MathWorks, Inc.

Ha = sosabutterhp(h,hs);

%------------------------------------------------------------------
function Ha = sosabutterhp(h,hs)
%SOSABUTTHP Highpass analog Butterworth filter second-order sections.

% Compute corresponding lowpass
hlp = fdmethod.butteralp;
hslp = fspecs.alpcutoff(hs.FilterOrder,1/hs.Wcutoff);
Halp = design(hlp,hslp);

% Transform to highpass
[shp,ghp] = lp2hp(Halp);
Ha = afilt.sos(shp,ghp);

% [EOF]
