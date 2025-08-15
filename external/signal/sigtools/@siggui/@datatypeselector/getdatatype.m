function datatype = getdatatype(this)
%GETDATATYPE Returns the C data type to export

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

% Determine whether the suggested datatype is selected
if strcmpi(this.Selection, 'suggested')
    datatype = get(this, 'SuggestedType');
else
    datatype = get(this, 'ExportType');
end

% [EOF]
