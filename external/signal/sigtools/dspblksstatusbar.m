function dspblksstatusbar(hFig)
%DSPBLKSSTATUSBAR Update FDATool's status bar when called by the DSP System Toolbox.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hFDA = getfdasessionhandle(hFig);
calledbydspblks = getflags(hFDA,'calledby','dspblks');

if calledbydspblks
    hFDA = getfdasessionhandle(hFig);
    data = getappdata(hFDA,'DSPBlks');
    hBlk = data.hBlk;
    name = get_param(hBlk,'Name');
    % Remove the carriage return (if it exists) from the block name
    name(name == newline) = ' ';

    msg = ['Filter coefficients have been sent to ' name ' block.'];
    status(hFDA,msg);
end

% [EOF]
