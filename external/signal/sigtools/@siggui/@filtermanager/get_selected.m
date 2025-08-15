function selected = get_selected(this, selected)
%GET_SELECTED   PreGet function for the 'selected' property.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

selected = get(this, 'privSelectedFilters');

% [EOF]
