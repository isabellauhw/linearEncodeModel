function dialog_enable_listener(hDlg, varargin)
%DIALOG_ENABLE_LISTENER Listener to the Enable property

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

sigcontainer_enable_listener(hDlg, varargin{:});

% Cancel is never disabled.
% Apply is taken care of by isapplied_listener
h = rmfield(hDlg.DialogHandles, {'cancel', 'apply'});

setenableprop(convert2vector(h), hDlg.Enable);
isapplied_listener(hDlg, varargin{:});

% [EOF]
