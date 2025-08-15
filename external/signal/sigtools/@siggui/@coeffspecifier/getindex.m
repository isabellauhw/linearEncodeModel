function index = getindex(hCoeff)
%GETINDEX Returns the selected index to the popup
%   GETINDEX(hCoeff) Returns the index to the popup associated with the
%   selected Filter Structure.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

% This will be a private method

s_struct = get(hCoeff,'SelectedStructure');
if isempty(s_struct)
    index = [];
else
    a_struct = get(hCoeff,'AllStructures');
    index = find(strcmpi(s_struct, a_struct.strs));
end

% [EOF]
