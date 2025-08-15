function [b, errstr, errid, mssgObj] = issimulinkinstalled
%ISSIMULINKINSTALLED   Returns true if Simulink is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

b = license('test', 'SIMULINK') && ~isempty(ver('simulink'));

if b
    errstr = '';
    errid  = '';
    mssgObj = [];
else
    mssgObj = message('signal:issimulinkinstalled:noSimulink');
    errstr = getString(mssgObj);
    errid  = 'noSimulink';
end

% [EOF]
