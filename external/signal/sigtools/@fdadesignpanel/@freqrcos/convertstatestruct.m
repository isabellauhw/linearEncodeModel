function sout = convertstatestruct(hObj, sin)
%CONVERTSTATESTRUCT Convert the old state structure

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

sout = [];

if isfield(sin.freq, 'rcos')
    
    sin = sin.freq.rcos;
    
    sout.Tag       = class(hObj);
    sout.Version   = 0;
    sout.freqUnits = sin.units;
    sout.Fs        = sin.fs;
    sout.Fc        = sin.cutoff{1};
    sout.TransitionMode = sin.freqspectype;
    sout.Bandwidth = sin.bandwidth;
    sout.Rolloff   = sin.rolloff;
    
end

% [EOF]
