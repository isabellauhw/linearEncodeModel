function hax = findaxes(hObj, hg)
%FINDAXES Find the axes which contains HG

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This should be a private method

hax = hg(1);
while ~strcmpi(get(hax, 'Type'), 'axes') && hax
    hax = get(hax, 'Parent');
end

% [EOF]
