function varargout = apply(hDlg)
%APPLY The apply action for the dialog

%   Copyright 1988-2017 The MathWorks, Inc.

send(hDlg, 'DialogBeingApplied');

% Perform the action specified by the Sub-class
try

    success = action(hDlg);
catch ME
    
    % If the action failed don't close the dialog.  Clean up the message to
    % work around udd/mexception issue.

    throwAsCaller(MException(ME.identifier, cleanerrormsg(ME.message)));
end

if isrendered(hDlg) && strcmpi(hDlg.Visible, 'on')
    figure(hDlg.FigureHandle);
end

% Set the isApplied flag to 1, if AutoClose is 1.  If autoClose is 0 the figure 
% will not close because of an error so we do not want the applied flag to be 1.
if success
    set(hDlg,'IsApplied',1);
    resetoperations(hDlg);
    send(hDlg, 'DialogApplied', handle.EventData(hDlg, 'DialogApplied'));
end

if nargout
    varargout = {success};
end

% [EOF]
