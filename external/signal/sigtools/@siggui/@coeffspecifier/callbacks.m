function cbs = callbacks(hCoeff)
%IMPORT_CBS Callbacks for the Import Tool

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

cbs                = siggui_cbs(hCoeff);
cbs.importcoeff_eb = @importcoeff_eb;
cbs.clearpush_cb   = @clearpush_cb;


%-------------------------------------------------------------------------
function clearpush_cb(hcbo, eventStruct, hCoeff)
%CLEARPUSH_CB Callback for the "Clear" pushbuttons in the "Specify
%             Filter Coefficients" frame.

coeffs = getselectedcoeffs(hCoeff);
index  = get(hcbo, 'UserData');

coeffs{index} = '';

setselectedcoeffs(hCoeff,coeffs);


%-------------------------------------------------------------------------
function importcoeff_eb(hcbo, eventStruct, hCoeff)
%IMPORTCOEFF_EB  Get the coefficients from the Edit boxes (variables 
%                or values) and build the filter object.
    
coeffs = getselectedcoeffs(hCoeff);
index  = get(hcbo,'UserData');

coeffs{index} = get(hcbo,'String');

setselectedcoeffs(hCoeff, coeffs);

% [EOF]
