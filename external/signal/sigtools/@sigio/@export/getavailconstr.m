function out = getavailconstr(h,out)
%GETAVAILCONSTR GetFunction for AvailableConstructors property.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

out = get(h,'privAvailableConstructors');

% [EOF]