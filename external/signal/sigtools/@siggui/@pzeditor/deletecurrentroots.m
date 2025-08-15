function deletecurrentroots(hObj)
%DELETECURRENTROOTS Delete the current Roots

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

% Remove the current roots from the list.
set(hObj, 'Roots', setdiff(get(hObj, 'Roots'), get(hObj, 'CurrentRoots')));

% Set the current roots to [].
set(hObj, 'CurrentRoots', []);

% [EOF]
