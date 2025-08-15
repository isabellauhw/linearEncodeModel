function editname(this)
%EDITNAME   Programmatically give focus to the name editbox.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

uicontrol(getappdata(this.Handles.popup, 'EditBox'));

% [EOF]
