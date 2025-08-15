function siggui_enable_listener(this, ~)
%SIGGUI_ENABLE_LISTENER   The listener for the enable property.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

enabState = get(this, 'Enable');
hall      = get(this, 'Handles');

if isfield(hall, 'framewlabel')
    set(this, 'Handles', rmfield(hall, 'framewlabel'));
end

h         = handles2vector(this);

set(this, 'Handles', hall);

if isempty(h), return; end

% Eliminate objects that cannot be disabled
h(~isprop(h, 'Enable')) = [];

setenableprop(h,enabState);

% If there are any links in the enable database, make sure they are
% updated properly.
db = get(this, 'LinkDatabase');
for indx = 1:length(db)
    enablelink_listener(this, db(indx).prop, db(indx).enabvalue, db(indx).linkedprops{:});
end

% [EOF]
