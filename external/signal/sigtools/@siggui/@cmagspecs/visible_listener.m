function visible_listener(this, varargin)
%VISIBLE_LISTENER   Listener to the Visible property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

hall = get(this, 'Handles');
set(this, 'Handles', rmfield(hall, 'checkbox'));

sigcontainer_visible_listener(this, varargin{:});

set(this, 'Handles', hall);

labels_listener(this);

% [EOF]
