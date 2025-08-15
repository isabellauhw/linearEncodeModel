function strs = fixup_uiedit(hndls)
% FIXUP_UIEDIT Get the string from each edit box uicontrol, deblank
%              each string, then set the string back into the edit box.
% Input:
%    hndls - a vector of edit box handles.
%
% Output:
%    strs - cell array of "fixed" strings.

%   Author(s): R. Losada, P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

% Remove trailing spaces of all strs
strs = deblank(get(hndls,'String'));

if length(hndls) == 1
    strs = {strs};
end

for n = 1:length(hndls)
    % Remove individual leading spaces
    strs{n} = fliplr(deblank(fliplr(strs{n})));
    set(hndls(n),'String',strs{n});
end    

% [EOF] - fixup_uiedit.m

