function status(hFDA, str, warningflag)
%STATUS Display a status in FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,3);

if ~ischar(str)
    error(message('signal:sigtools:fdatool:status:MustBeAString'));
end

if nargin < 3
    warningflag = 0;
end

if warningflag
    color = [1 0 0];
else
    color = [0 0 0];
end

if isrendered(hFDA)
    
    indx = strfind(str, newline);
    if ~isempty(indx)
        str(indx) = ' ';
    end
    indx = strfind(str, char(13));
    if ~isempty(indx)
        str(indx) = ' ';
    end
    
    update_statusbar(hFDA.FigureHandle, str, 'ForegroundColor', color);
end

% [EOF]
