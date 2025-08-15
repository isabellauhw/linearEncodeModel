function [b, errstr, errid] = isfdhdlcinstalled
%ISFDHDLCINSTALLED   Returns true if the FIlter Design HDL Coder is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

b = license('test', 'Filter_Design_HDL_Coder') && ~isempty(ver('hdlfilter'));

if b
    errstr = '';
    errid  = '';
else
    errstr = sprintf('%s\n%s', 'Filter Design HDL Coder is not available.', ...
        'Make sure that it is installed and that a license is available.');
    errid  = 'noHDLCoder';
end

% [EOF]
