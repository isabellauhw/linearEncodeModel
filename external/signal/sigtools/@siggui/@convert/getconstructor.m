function str = getconstructor(hConvert)
%GETCONSTRUCTOR Get the constructor name for the new Filter Structure.
%                      
% Output:
%   str - Valid filter string for converting a dfilt object. 

%   Copyright 1988-2004 The MathWorks, Inc.

reffilt = get(hConvert,'Filter');

if isempty(reffilt)
    str = '';
    return;
end

struct  = get(hConvert,'TargetStructure');

[strs, targs] = getconvertstructchoices(hConvert);

indx = strcmpi(struct, strs);

str = targs{indx};

% [EOF]
