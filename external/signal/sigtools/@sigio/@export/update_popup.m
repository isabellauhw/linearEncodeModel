function update_popup(hXP)
%UPDATE_POPUP Update the Export Popup

% This should  be a private method

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.

hndls = get(hXP,'Handles');
avDest = get(hXP,'AvailableDestinations');
currDest = get(hXP,'CurrentDestination');
indx = strmatch(currDest, avDest);

set(hndls.xp2popup, 'Value', indx);

% [EOF]
