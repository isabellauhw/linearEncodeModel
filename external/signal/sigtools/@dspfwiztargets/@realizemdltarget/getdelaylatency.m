function delay = getdelaylatency(hTar, blockhandle)
%GETDELAYLATENCY Get the latency of the Delay block.

%    Copyright 1995-2017 The MathWorks, Inc.

b = isspblksinstalled;
if b
    % Use DSP System Toolbox block
    delay = get_param(blockhandle, 'delay');
else
    % Use Simulink block
    delay = get_param(blockhandle, 'NumDelays');
end

        
