function offset = get_offset(this, offset)
%GET_OFFSET  Preget function for 'PassbandOffset' property

%   Copyright 1999-2015 The MathWorks, Inc.

if isempty(offset)
    offset = [0 0];
end

