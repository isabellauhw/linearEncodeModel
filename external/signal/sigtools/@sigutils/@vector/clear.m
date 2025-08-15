function clear(h)
%CLEAR Removes all of the elements from the vector

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

% Clear out the vector.
set(h, 'Data', {});

sendchange(h, 'VectorCleared', []);

% [EOF]
