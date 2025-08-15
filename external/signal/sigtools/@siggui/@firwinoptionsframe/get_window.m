function window = get_window(this, window)
%GET_WINDOW   PreGet function for the 'window' property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

window = get(this.privWindow, 'Name');

% [EOF]
