function success = action(hEH)
%ACTION Perform the action of the Export Header Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if validate_filename(hEH)
    success = true;
    
    % Create the header file
    createcfile(hEH, generate_exportdata(hEH));
    
else
    success = false;
end

% [EOF]
