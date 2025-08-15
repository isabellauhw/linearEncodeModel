function out = setavailconstr(h,out)
%SETAVAILCONSTR SetFunction for AvailableConstructors property.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

if isempty(out)
    return;
else
    set(h,'privAvailableConstructors',out);
end

out = [];

% [EOF]
