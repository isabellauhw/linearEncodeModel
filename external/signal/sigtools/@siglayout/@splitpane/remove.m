function remove(this, position)
%REMOVE   Remove the component from a location.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

switch lower(position)
    case {'east', 'south'}
        position = 'southeast';
    case {'west', 'north'}
        position = 'northwest';
end

this.(position) = [];

% [EOF]
