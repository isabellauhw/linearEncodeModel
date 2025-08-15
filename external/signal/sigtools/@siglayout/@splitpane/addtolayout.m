function addtolayout(this, h, position)
%ADD   Add a component to the BorderLayout.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

switch lower(position)
    case {'east', 'south'}
        position = 'southeast';
    case {'west', 'north'}
        position = 'northwest';
end

set(this, position, h);

% [EOF]
