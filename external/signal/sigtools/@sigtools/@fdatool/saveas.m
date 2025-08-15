function success = saveas(hFDA, file)
%SAVEAS Save the file

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

success = false;

% If a file isn't specified, bring up the dialog
if nargin == 1
    file = get(hFDA, 'FileName');
    [filename,pathname] = uiputfile('*.fda', ...
           getString(message('signal:sigtools:sigtools:SaveFilterDesignSession')), file);
    file = [pathname filename];
end

% Don't save if filename is 0
if filename ~= 0
    success = save(hFDA, file);
end

% [EOF]
