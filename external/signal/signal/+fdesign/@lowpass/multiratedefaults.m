function multiratedefaults(this, maxfactor)
%MULTIRATEDEFAULTS   Setup the lowpass object for multirate.

%   Copyright 2005 The MathWorks, Inc.

% Put Fstop at the band point so that there is no aliasing back into the
% transition width.
fs =  1/maxfactor;
fp = .8/maxfactor;

% Scale by the sampling frequency.
if ~this.NormalizedFrequency
    fp = fp*this.Fs/2;
    fs = fs*this.Fs/2;
end

this.Fpass = fp;
this.Fstop = fs;

% [EOF]
