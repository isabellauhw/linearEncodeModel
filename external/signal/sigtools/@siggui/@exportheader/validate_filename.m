function bool = validate_filename(hEH)
%VALIDATE_FILENAME Get a new filename

%   Author(s): J. Schickler
%   Copyright 1988-2012 The MathWorks, Inc.

% This should be private

bool = true;

[filename, pathname] = uiputfile( ...
    {'*.h;', getString(message('signal:sigtools:siggui:HeaderFilesDescription'))}, ...
    getString(message('signal:sigtools:siggui:SaveAs')), hEH.FileName);

% If filename is not 0 then a file has been chosen
if filename ~= 0
    
    % Make sure the user enters a file with the .h extension
    [file, ext] = strtok(filename,'.');
    if ~strcmpi(ext,'.h')
        filename = [file '.h'];
    end
    
    file = strcat(pathname,filename);
    set(hEH, 'FileName', file);
else
    bool = false;
end

% [EOF]
