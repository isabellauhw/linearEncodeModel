function update_editboxes(hCoeff, eventData)
%UPDATE_EDITBOXES Update the coefficient edit boxes

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

% Update the editboxes

if ~isrendered(hCoeff), return; end

% Get the Coefficients
h      = get(hCoeff,'Handles');
coeffs = getselectedcoeffs(hCoeff);

% Set the strings of the edit boxes
for i = 1:length(coeffs)
    set(h.ebs(i),'String',coeffs{i});
end

% [EOF]