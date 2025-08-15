function coeffs_listener(hCoeff, EventData)
%COEFFS_LISTENER Listener for the coefficients property
%   COEFFS_LISTENER Updates the edit boxes and labels

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

% Update the editboxes so that they match the properties
update_editboxes(hCoeff);
sendfiledirty(hCoeff);

% [EOF]
