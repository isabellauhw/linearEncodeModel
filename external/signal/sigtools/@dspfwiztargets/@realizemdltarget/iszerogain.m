function y = iszerogain(hTar, blockhandles, H)
%ISZEROGAIN Test for zero gains.

%    This should be a private method

%    Copyright 1995-2004 The MathWorks, Inc.

gainval = get_param(blockhandles, 'Gain');
y = str2double(gainval)==0;
