function [b, errstr, errid, mssgObj] = isspblksinstalled
%ISSPBLKSINSTALLED   Returns true if Simulink and Signal Processing Blockset are installed.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

[b, errstr, errid, mssgObj] = issimulinkinstalled;

if b
    b = license('test', 'Signal_Blocks') && ~isempty(ver('dsp'));
    if b
        errstr = '';
        errid  = '';
        mssgObj = [];
    else
        mssgObj = message('signal:isspblksinstalled:noDSP');
        errstr = getString(mssgObj);
        errid  = 'noDSP';
    end
end

% [EOF]
