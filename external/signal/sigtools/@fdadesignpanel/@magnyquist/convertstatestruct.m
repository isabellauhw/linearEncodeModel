function sout = convertstatestruct(hObj, sin)
%CONVERTSTATESTRUCT Convert the state structure

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

sout = [];

if isfield(sin.mag, 'nyquist')
    sout.Tag       = class(hObj);
    sout.Version   = 0;
    sout.DesignType = sin.mag.nyquist.designtype;
end

% [EOF]
