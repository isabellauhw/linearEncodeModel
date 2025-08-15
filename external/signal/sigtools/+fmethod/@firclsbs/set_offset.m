function offset = set_offset(this, offset)
%SET_OFFSET - Preset function for 'PassbandOffset' property.

%   Copyright 1999-2015 The MathWorks, Inc.

if (numel(offset) ~= 2)
    error(message('signal:fmethod:firclsbs:set_offset:InvalidPassbandOffset'));
end
