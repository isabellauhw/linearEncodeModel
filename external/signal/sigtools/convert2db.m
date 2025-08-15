function HdB = convert2db(H)
%CONVERT2DB Convert to decibels (dB).

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.

ws = warning; % Cache warning state
warning off   % Avoid "Log of zero" warnings
HdB = db(H);  % Call the Convert to decibels engine
warning(ws);  % Reset warning state

% [EOF]
