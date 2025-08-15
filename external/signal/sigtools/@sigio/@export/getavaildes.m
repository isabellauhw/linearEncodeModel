function out = getavaildes(h,out)
%GETAVAILDES GetFunction for AvailableDestinations property.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

out = get(h,'privAvailableDestinations');

% [EOF]