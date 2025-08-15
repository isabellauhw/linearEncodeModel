function varargout = apply(hDlg)
%APPLY The apply action for the export 2 header dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Perform the action specified by the Sub-class
success = action(hDlg);

if isrendered(hDlg)
    if strcmpi(hDlg.Visible, 'on')
        figure(hDlg.FigureHandle);
    end
    
    % Only reset the operations if the action was a success.
    if success, resetoperations(hDlg); end
end

if nargout, varargout = {success}; end

% [EOF]
