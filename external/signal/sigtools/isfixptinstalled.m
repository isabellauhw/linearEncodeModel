function [b, errstr, errid] = isfixptinstalled
%ISFIXPTINSTALLED   Returns true if fixedpoint is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2019 The MathWorks, Inc.

persistent isinstalled

% Cache the results of ISTBXINSTALLED for performance
if isempty(isinstalled)
    isinstalled = istbxinstalled('fixedpoint','fixedpoint/fixedpoint');
end

b = isinstalled && istbxlicensed('Fixed_Point_Toolbox');
if b
    errstr = '';
    errid  = '';
else
    errstr = sprintf('%s\n%s','Fixed-Point Designer is not available.', ...
        'Make sure that it is installed and that a license is available.');
    errid  = 'noFixPt';
end
% [EOF]
