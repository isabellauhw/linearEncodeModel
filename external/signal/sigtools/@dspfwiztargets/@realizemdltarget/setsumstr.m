function setsumstr(hTar, blockhandles, str)
%SETSUMSTR Set the string of signs of the adder.

%    This should be a private method

%    Copyright 1995-2004 The MathWorks, Inc.

set_param(blockhandles, 'Inputs', str);
        