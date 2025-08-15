function [b, errstr, errid] = isccslinkinstalled
%ISCCSLINKINSTALLED   Returns true if the Embedded Coder is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

b = exist('ecoderinstalled.m','file')==2 && ecoderinstalled;

if b
    errstr = '';
    errid  = '';
else
    errstr = sprintf('%s\n%s', 'Embedded Coder(TM) is not available.', ...
        'Make sure that it is installed and that a license is available.');
    errid  = 'noEmbeddedCoder';
end

% [EOF]

