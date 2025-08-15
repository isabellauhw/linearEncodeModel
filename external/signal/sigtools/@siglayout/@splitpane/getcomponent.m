function component = getcomponent(this, position)
%GETCOMPONENT   Get the component.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

switch lower(position)
    case {'east', 'south'}
        position = 'southeast';
    case {'west', 'north'}
        position = 'northwest';
end

component = get(this, position);

% [EOF]
