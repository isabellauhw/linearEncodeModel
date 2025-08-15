function warning(hDlg, Title)
%WARNING Manager for dialog warnings

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if nargin == 1
    Title = 'Warning';
end

% Create a warning and save its handle to be deleted later
h = get(hDlg, 'DialogHandles');
h.warn(end+1) = warndlg(lastwarn, Title);
set(hDlg, 'DialogHandles', h);

% [EOF]
