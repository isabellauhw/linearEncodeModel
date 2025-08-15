function y = isunitgain(hTar, blockhandles, H)
%ISUNITGAIN Test for unity gain.

%    This should be a private method

%    Copyright 1995-2004 The MathWorks, Inc.

gainval = get_param(blockhandles, 'Gain');
y = str2double(gainval)==1;
        